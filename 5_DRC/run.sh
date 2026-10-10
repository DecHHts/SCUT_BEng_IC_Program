#!/bin/bash
#==============================================================================
# 5_DRC : 版图设计规则检查
#   有 Calibre 规则文件 -> Calibre nmDRC 批处理 (主规则 + 天线规则)
#   没有                -> LIB=gf180mcu 且装了 klayout 时用 PDK 的 KLayout 规则;
#                          否则以布局布线工具内置检查的结果为准
#==============================================================================
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
GDS=$(cd ../$PNR_DIR/postlayout && pwd)/$TOP.gds
[ -e "$GDS" ] || { echo "找不到 $GDS"; exit 1; }

# 把自带 LAYOUT 语句的规则文件拷一份, 改成本设计的路径和开关 (原文件不动)
#   $1 规则文件  $2 输出的副本  $3 结果文件名前缀
make_deck() {
    sed -e "s|^\(LAYOUT PATH\).*|\1 \"$GDS\"|" \
        -e "s|^\(LAYOUT PRIMARY\).*|\1 \"$TOP\"|" \
        -e "s|^\(DRC RESULTS DATABASE\).*|\1 \"$3.results\" ASCII|" \
        -e "s|^\(DRC SUMMARY REPORT\).*|\1 \"$3.summary\" REPLACE HIER|" \
        -e "s|^\(DRC MAXIMUM RESULTS\).*|\1 1000|" \
        -e "s|^#DEFINE THICK_20K|//#DEFINE THICK_20K|" \
        -e "s|^#DEFINE THICK_40K|//#DEFINE THICK_40K|" \
        -e "s|^#DEFINE MIX_MODE|//#DEFINE MIX_MODE|" \
        -e "s|^#DEFINE CHECK_ALRDL|//#DEFINE CHECK_ALRDL|" \
        -e "s|^#DEFINE GUIDELINE_ESD|//#DEFINE GUIDELINE_ESD|" \
        "$1" > "$2"
}

if [ -n "$CALIBRE_DRC_RULE" ] && [ -e "$CALIBRE_DRC_RULE" ]; then
    if [ "$CALIBRE_STYLE" = embedded ]; then
        make_deck "$CALIBRE_DRC_RULE" drc.runset "$TOP.drc"
        echo "== 规则文件里生效的开关 (#DEFINE):"; grep -E '^#DEFINE' drc.runset
    else
        cat > drc.runset <<EOT
LAYOUT PATH    "$GDS"
LAYOUT PRIMARY "$TOP"
LAYOUT SYSTEM  GDSII
DRC RESULTS DATABASE "$TOP.drc.results" ASCII
DRC SUMMARY REPORT   "$TOP.drc.summary" REPLACE HIER
DRC MAXIMUM RESULTS  1000
INCLUDE "$CALIBRE_DRC_RULE"
EOT
    fi
    calibre -drc -hier -turbo drc.runset 2>&1 | tee calibre_drc.log
    if [ -n "$CALIBRE_ANT_RULE" ] && [ -e "$CALIBRE_ANT_RULE" ]; then
        make_deck "$CALIBRE_ANT_RULE" ant.runset "$TOP.ant"
        calibre -drc -hier -turbo ant.runset 2>&1 | tee calibre_ant.log
    fi
    echo; echo "==== 结果 ===="
    for r in $TOP.drc.summary $TOP.ant.summary; do
        [ -e $r ] && { echo "$r:"; grep -E "TOTAL DRC Results Generated" $r; }
    done
    echo "每条规则的违例数:  grep -E 'RULECHECK .* TOTAL Result Count = [1-9]' $TOP.drc.summary"
elif [ "$LIB" = gf180mcu ] && command -v klayout >/dev/null 2>&1; then
    export PDK_ROOT PDK
    RUNNER=$(ls $PDK_ROOT/$PDK/libs.tech/klayout/tech/drc/run_drc.py $PDK_ROOT/$PDK/libs.tech/klayout/drc/run_drc.py 2>/dev/null | head -1)
    [ -n "$RUNNER" ] || { echo "PDK 里找不到 run_drc.py, 用 find \$PDK_ROOT -name run_drc.py 找一下"; exit 1; }
    echo "用 $RUNNER (选项以 python3 $RUNNER --help 的输出为准)"
    python3 $RUNNER --path=$GDS --topcell=$TOP --variant=D --run_mode=flat --no_feol --run_dir=$PWD/klayout_drc 2>&1 | tee klayout_drc.log
else
    echo "没有 Calibre 规则文件, 也没有可用的 KLayout."
    echo "DRC 结论以布局布线工具的内置检查为准: ../$PNR_DIR/work/reports/"
fi
