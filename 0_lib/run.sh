#!/bin/bash
#==============================================================================
# 0_lib : 库准备, 只需做一次
#   LIB=tsmc180  : 用库管理器把 工艺文件 + LEF + 三个角的 .db 建成 ICC2 的 NDM 参考库
#   LIB=gf180mcu : 用 Library Compiler 把 .lib 转成 .db
#   LIB=csm18ic  : 不用做
#==============================================================================
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
case "$LIB" in
tsmc180)
    LM=$(command -v icc2_lm_shell || command -v lm_shell)
    [ -n "$LM" ] || { echo "找不到 icc2_lm_shell / lm_shell"; exit 1; }
    mkdir -p ndm && rm -rf ndm/$SCL.ndm $SCL
    $LM -f tcl/ndm.tcl | tee lm.log
    rm -rf ndm/fill_phys.ndm fill_phys
    $LM -f tcl/ndm_phys.tcl | tee lm_phys.log
    ls -ld ndm/*.ndm ;;
gf180mcu)
    mkdir -p db
    lc_shell -f tcl/lc.tcl | tee lc.log
    ls -l db/ ;;
*)  echo "LIB=$LIB 自带 .db, 这一步不用做." ;;
esac
