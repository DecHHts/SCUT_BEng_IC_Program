#!/bin/bash
#==============================================================================
# 5_LVS : 版图与网表一致性检查
#   有 Calibre LVS 规则 -> v2lvs 把带电源地的门级网表转成 SPICE, 再跑 Calibre nmLVS
#   没有                -> 以布局布线工具的连通性检查结果为准
#==============================================================================
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
POST=$(cd ../$PNR_DIR/postlayout && pwd)
GDS=$POST/$TOP.gds; NL=$POST/${TOP}_pg.v
[ -e "$GDS" ] && [ -e "$NL" ] || { echo "缺 $GDS 或 $NL"; exit 1; }

if [ -n "$CALIBRE_LVS_RULE" ] && [ -e "$CALIBRE_LVS_RULE" ]; then
    SUB=${CELL_CDL:-$CELL_SPICE}
    [ -n "$SUB" ] && [ -e "$SUB" ] || { echo "LVS 需要标准单元的 SPICE/CDL 网表 (common/env.sh 的 CELL_CDL)"; exit 1; }
    # 门级网表 -> SPICE.  -lsp: 按单元 SPICE 网表里的引脚顺序例化;  -s: 生成 .INCLUDE
    INC="-s $SUB"; [ -n "$LVS_SOURCE_ADDED" ] && [ -e "$LVS_SOURCE_ADDED" ] && INC="$INC -s $LVS_SOURCE_ADDED"
    v2lvs -v $NL -o $TOP.sp -lsp $SUB $INC -s0 $GND_PIN -s1 $PWR_PIN 2>&1 | tee v2lvs.log
    # 填充, 阱接触这类纯物理单元里没有器件, 单元 SPICE 库里也没有它们的子电路
    # (v2lvs 报 "No module declaration"). 版图一侧它们提取不出任何东西, 所以网表一侧
    # 直接把这些例化行删掉, 否则会被算成 "网表多出来的器件".
    grep -o 'No module declaration for module [A-Za-z0-9_]*' v2lvs.log | awk '{print $NF}' | sort -u > phys_cells.txt
    if [ -s phys_cells.txt ]; then
        awk 'NR==FNR{c[$1]=1; next} !(/^X/ && ($2 in c))' phys_cells.txt $TOP.sp > $TOP.sp.tmp
        echo "从 LVS 网表里去掉物理单元: $(($(wc -l < $TOP.sp) - $(wc -l < $TOP.sp.tmp))) 个例化 ($(tr '\n' ' ' < phys_cells.txt))"
        mv $TOP.sp.tmp $TOP.sp
    fi

    if [ "$CALIBRE_STYLE" = embedded ]; then
        sed -e "s|^\(LAYOUT PATH\).*|\1 \"$GDS\"|" \
            -e "s|^\(LAYOUT PRIMARY\).*|\1 \"$TOP\"|" \
            -e "s|^\(SOURCE PATH\).*|\1 \"$PWD/$TOP.sp\"|" \
            -e "s|^\(SOURCE PRIMARY\).*|\1 \"$TOP\"|" \
            -e "s|^\(LVS REPORT\) \".*|\1 \"$TOP.lvs.report\"|" \
            -e "s|^\(LVS HEAP DIRECTORY\).*|\1 \"$PWD\"|" \
            "$CALIBRE_LVS_RULE" > lvs.runset
    else
        cat > lvs.runset <<EOT
LAYOUT PATH    "$GDS"
LAYOUT PRIMARY "$TOP"
LAYOUT SYSTEM  GDSII
SOURCE PATH    "$TOP.sp"
SOURCE PRIMARY "$TOP"
SOURCE SYSTEM  SPICE
LVS REPORT "$TOP.lvs.report"
LVS REPORT MAXIMUM 50
INCLUDE "$CALIBRE_LVS_RULE"
EOT
    fi
    # 电源地的文字标签 (布局布线导出步骤生成)
    [ -e $POST/pg_text.svrf ] && { echo; cat $POST/pg_text.svrf; } >> lvs.runset
    # Verilog 区分大小写, SPICE 默认不区分: 网表里同一模块内的 N12 和 n12 是两条线,
    # 不加这一句 Calibre 会把它们当成同一条 (等于网表一侧短路), 比对必然不过.
    sed -i -e '/^[[:space:]]*SOURCE[[:space:]]\+CASE/d' lvs.runset
    echo 'SOURCE CASE YES' >> lvs.runset
    calibre -lvs -hier -turbo lvs.runset 2>&1 | tee calibre_lvs.log
    echo; echo "==== 结果 ===="; grep -m3 -E "CORRECT|INCORRECT|NOT COMPARED" $TOP.lvs.report
else
    echo "没有 Calibre LVS 规则文件."
    echo "连通性结论以布局布线工具的内置检查为准: ../$PNR_DIR/work/reports/"
    cp ../$PNR_DIR/work/reports/*connectivity* ../$PNR_DIR/work/reports/*check_lvs* . 2>/dev/null
fi
