#==============================================================================
# fm.tcl : Formality 等价性检查 (前端, 后端共用; 区别全在 dc_setup.tcl 里)
#==============================================================================
source -echo -verbose tcl/dc_setup.tcl
file mkdir $REPORTS_DIR

# 没有驱动的信号在两边按同样方式处理, 避免因此产生的假失败
set_app_var verification_set_undriven_signals synthesis
# 仿真与综合不一致的写法只警告
set_app_var hdlin_error_on_mismatch_message false

if {$SVF_FILE ne ""} { set_svf $SVF_FILE }

# 标准单元库: 两边共用
read_db -technology_library $LIB_DB

#---------------- 参考设计 (r) ----------------
if {$REF_TYPE eq "rtl"} {
    set_app_var search_path [concat $rtl_dir $search_path]
    read_verilog -container r -libname WORK $REF_FILES
} else {
    read_verilog -container r -libname WORK -netlist $REF_FILES
}
set_top r:/WORK/$DESIGN_NAME

#---------------- 实现设计 (i) ----------------
read_verilog -container i -libname WORK -netlist $IMPL_NETLIST
set_top i:/WORK/$DESIGN_NAME

#---------------- 匹配与验证 ----------------
match
report_unmatched_points > $REPORTS_DIR/unmatched_points.rpt

if {[verify]} {
    puts "\n==== 形式验证通过 ====\n"
} else {
    puts "\n==== 形式验证未通过, 看 reports/ 下的 failing_points.rpt ====\n"
    report_failing_points > $REPORTS_DIR/failing_points.rpt
    report_aborted_points > $REPORTS_DIR/aborted_points.rpt
    analyze_points -failing > $REPORTS_DIR/analyze_points.rpt
    save_session -replace $REPORTS_DIR/failing_session
}
report_status > $REPORTS_DIR/status.rpt
exit
