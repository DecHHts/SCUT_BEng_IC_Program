#==============================================================================
# dc_setup.tcl (前端形式验证): 参考设计 = RTL, 实现设计 = DC 网表
#==============================================================================
set DESIGN_NAME   $env(TOP)
set REPORTS_DIR   reports
set RESULTS_DIR   ../1_dc/output
set SVF_FILE      $RESULTS_DIR/$DESIGN_NAME.svf
set IMPL_NETLIST  $RESULTS_DIR/$DESIGN_NAME.v

# 标准单元逻辑库 (和综合用同一个角的 .db)
set LIB_DB        $env(DB_DIR)/$env(DB_SYN)

# 参考设计: RTL
set REF_TYPE      rtl
set rtl_dir       $env(RTL_DIR)
set REF_FILES     {}
foreach f $env(RTL_FILES) { lappend REF_FILES $rtl_dir/$f }
