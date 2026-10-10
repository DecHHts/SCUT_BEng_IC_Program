#!/bin/bash
#==============================================================================
# 7_StarRC : 版图寄生参数提取, 输出三个工艺角的 SPEF 到 reports_spef/
#   有 StarRC 工艺文件 (nxtgrd + 映射文件, 在 flow.cfg 里填路径) -> 跑 StarRC
#   没有 -> 用布局布线工具 (ICC2) 布线后提取并导出的 SPEF 代替
#==============================================================================
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
mkdir -p reports_spef
INN=../$PNR_DIR/postlayout

if [ -n "$STARRC_NXTGRD_TYP" ] && [ -e "$STARRC_NXTGRD_TYP" ] && [ -e "$STARRC_MAPFILE" ]; then
    for c in wst typ bst; do
        C=$(echo $c | tr a-z A-Z)
        eval GRD=\$STARRC_NXTGRD_$C; eval T=\$TEMP_$C
        sed -e "s|@TOP@|$TOP|g" -e "s|@CORNER@|$c|g" -e "s|@GRD@|$GRD|g" \
            -e "s|@MAP@|$STARRC_MAPFILE|g" -e "s|@TEMP@|$T|g" \
            -e "s|@LEF@|$LEF_FILES|g" -e "s|@DEF@|$INN/$TOP.def|g" \
            tcl/starrc.cmd.tpl > tcl/$c.cmd
        echo "==== StarRC: $c ===="
        StarXtract -clean tcl/$c.cmd 2>&1 | tee starrc_$c.log
    done
else
    echo "没有 StarRC 工艺文件, 使用布局布线工具导出的 SPEF."
    # 有的工具只导出一个 <top>.spef; ICC2 每个工艺角导出一个, 文件名带温度后缀 (如 <top>.tlu_typ_125.spef)
    # 按优先顺序找: 带这个温度后缀的 -> 不带后缀的 -> 随便一个 (ls 会按字母排序, 不能合在一条里)
    pick() { for f in $INN/$TOP*_$1.spef $INN/$TOP.spef $INN/$TOP*.spef; do [ -e "$f" ] && { echo $f; return; }; done; }
    W=$(pick $TEMP_WST); B=$(pick $TEMP_BST)
    if [ -z "$W" ]; then echo "$INN 下找不到 SPEF, 先完成布局布线的导出步骤"; ls $INN; exit 1; fi
    echo "wst, typ <- $W"; echo "bst      <- $B"
    cp $W reports_spef/${TOP}_wst.spef; cp $W reports_spef/${TOP}_typ.spef; cp $B reports_spef/${TOP}_bst.spef
fi
ls -l reports_spef/*.spef
