#!/bin/bash
# 1_dc : Design Compiler 综合.  跑完停在 dc_shell 提示符下 (可输入 gui_start 看电路图), exit 退出
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
mkdir -p output work
dc_shell -f tcl/dc.tcl | tee dc.log
