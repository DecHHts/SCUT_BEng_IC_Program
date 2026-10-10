#!/bin/bash
cd "$(dirname "$0")" && source ../common/env.sh || exit 1
mkdir -p reports
fm_shell -f tcl/fm.tcl | tee fm.log
echo; grep -E "Verification SUCCEEDED|Verification FAILED|Verification INCONCLUSIVE" fm.log || echo "fm.log 里没有验证结论, 往上翻看报错"
