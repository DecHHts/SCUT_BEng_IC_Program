#!/bin/bash
# 8_pt : PrimeTime 三工艺角静态时序分析, 并写出后仿用的 SDF
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
mkdir -p reports
cp -f ../1_dc/tcl/top.sdc tcl/top.sdc     # 约束始终用综合的那一份
for c in wst typ bst; do
    echo "==== PrimeTime: $c ===="
    CORNER=$c pt_shell -f tcl/pt.tcl 2>&1 | tee $c.log
done
echo
echo "==== 汇总 (slack 为负即违例) ===="
for c in wst typ bst; do
    printf "%s  setup 最差 slack: %-10s hold 最差 slack: %s\n" $c \
      "$(grep -m1 -E '^\s*slack' reports/${c}_report_timing_max.report | awk '{print $NF}')" \
      "$(grep -m1 -E '^\s*slack' reports/${c}_report_timing_min.report | awk '{print $NF}')"
done
