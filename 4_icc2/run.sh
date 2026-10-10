#!/bin/bash
#==============================================================================
# 4_icc2 : 布局布线 (IC Compiler II)
#   ./run.sh          进入 icc2_shell 图形界面, 手动逐个 source 脚本 (第一次建议这样做)
#   ./run.sh all      批处理, 从头跑到导出
#   ./run.sh N        批处理, 只跑到第 N 步 (0~8), 停在命令行
#   前提: 已经跑过 0_lib/run.sh (建好 NDM 参考库) 和 1_dc/run.sh
#==============================================================================
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
[ -d "$NDM_LIB" ] || { echo "找不到 NDM 参考库 $NDM_LIB, 先执行 0_lib/run.sh"; exit 1; }
[ -e ../1_dc/output/$TOP.v ] || { echo "找不到 DC 网表, 先执行 1_dc/run.sh"; exit 1; }
mkdir -p postlayout work/reports
cd work
case "$1" in
  "")   icc2_shell -gui ;;
  all)  icc2_shell -f ../scripts/run_all.tcl | tee icc2.log ;;
  *)    LAST_STEP=$1 icc2_shell -f ../scripts/run_all.tcl | tee icc2.log ;;
esac
