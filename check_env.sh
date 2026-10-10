#!/bin/bash
#==============================================================================
# check_env.sh : 开工前检查. 列出工具、库文件、设计文件哪些齐了, 哪些缺.
#   用法: ./check_env.sh
#==============================================================================
cd "$(dirname "$0")" && source common/env.sh || exit 1
ok=0; bad=0
have() { printf "  %-34s " "$1"; if [ -n "$2" ] && [ -e "$2" ]; then echo "有   $2"; ok=$((ok+1)); else echo "缺   ${2:-(未设置)}"; bad=$((bad+1)); fi; }
tool() { printf "  %-34s " "$1"; if p=$(command -v "$1" 2>/dev/null); then echo "有   $p"; ok=$((ok+1)); else echo "缺   $2"; bad=$((bad+1)); fi; }
opt()  { printf "  %-34s " "$1"; if [ -n "$2" ] && [ -e "$2" ]; then echo "有   $2"; else echo "无   $3"; fi; }

echo "== 配置: LIB=$LIB  TOP=$TOP  CLOCK_PERIOD=$CLOCK_PERIOD ns"
echo "== 工具"
tool vcs "VCS"; tool verdi "Verdi"; tool dc_shell "Design Compiler"; tool fm_shell "Formality"
tool pt_shell "PrimeTime"
if [ "$LIB" = tsmc180 ]; then
    tool icc2_shell "IC Compiler II"
    printf "  %-34s " "icc2_lm_shell / lm_shell"; (command -v icc2_lm_shell || command -v lm_shell) >/dev/null 2>&1 && echo "有   $(command -v icc2_lm_shell || command -v lm_shell)" || { echo "缺   (建 NDM 库要用)"; bad=$((bad+1)); }
    tool calibre "Calibre"; tool v2lvs "v2lvs (Calibre 自带)"
else
    tool innovus "布局布线工具"
fi
[ "$LIB" = gf180mcu ] && tool lc_shell "Library Compiler (.lib 转 .db 要用)"
printf "  %-34s " "VERDI_HOME"; [ -n "$VERDI_HOME" ] && echo "有   $VERDI_HOME" || { echo "缺   (FSDB 波形需要)"; bad=$((bad+1)); }
echo "== 工具 (缺少时对应步骤走替代做法)"
for t in calibre StarXtract virtuoso klayout; do printf "  %-34s " "$t"; command -v $t >/dev/null 2>&1 && echo "有   $(command -v $t)" || echo "无"; done

echo "== 时序库"
if [ "$LIB" != tsmc180 ]; then have "最慢角 .lib" "$LIB_WST"; have "典型角 .lib" "$LIB_TYP"; have "最快角 .lib" "$LIB_BST"; fi
have "最慢角 .db"  "$DB_DIR/$DB_WST"; have "典型角 .db" "$DB_DIR/$DB_TYP"; have "最快角 .db" "$DB_DIR/$DB_BST"
echo "== 物理库"
have "工艺 LEF" "$TECH_LEF"; have "单元 LEF" "$CELL_LEF"
[ "$LIB" = gf180mcu ] && { have "单元 GDS" "$CELL_GDS"; have "streamOut 层映射" "$STREAM_MAP"; }
if [ "$LIB" = tsmc180 ]; then
    have "工艺文件 .tf" "$TECH_TF"; have "TLU+ (连线寄生)" "$TLUPLUS"; have "TLU+ 层映射" "$TLU_MAP"
    have "单元 GDS" "$CELL_GDS"; have "单元 SPICE 网表" "$CELL_SPICE"; have "GDS 文字层映射" "$STREAM_MAP"
    have "NDM 参考库 (0_lib/run.sh 生成)" "$NDM_LIB"
    have "Calibre 天线规则" "$CALIBRE_ANT_RULE"; have "LVS source.added" "$LVS_SOURCE_ADDED"
fi
echo "== 仿真模型"
for f in $CELL_V; do have "$(basename $f)" "$f"; done
echo "== 版图验证 / 寄生提取的工艺文件 (没有属于正常情况, 见指导书)"
opt "Calibre DRC 规则" "$CALIBRE_DRC_RULE" "DRC 改用布局布线工具内置检查"
opt "Calibre LVS 规则" "$CALIBRE_LVS_RULE" "LVS 改用布局布线工具连通性检查"
opt "StarRC nxtgrd (典型)" "$STARRC_NXTGRD_TYP" "寄生参数改由布局布线工具提取"
opt "StarRC 映射文件" "$STARRC_MAPFILE" ""
[ "$LIB" = gf180mcu ] && opt "单元 CDL 网表 (LVS 用)" "$CELL_CDL" ""
echo "== 设计文件"
for f in $RTL_FILES cos_rom.vh; do have "rtl/$f" "$RTL_DIR/$f"; done
have "tb/tb_function_gen.v" "$PROJ/0_simulation_pre/tb/tb_function_gen.v"
echo
echo "合计: $ok 项就绪, $bad 项缺失."
[ $bad -eq 0 ] && echo "可以开始了." || echo "先补齐上面标 '缺' 的项 (NDM 库或 .db 缺失时, 先跑 0_lib/run.sh)."
