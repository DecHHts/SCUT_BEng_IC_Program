#==============================================================================
# pt.tcl : 一个工艺角的时序分析. 工艺角由环境变量 CORNER 指定 (wst / typ / bst),
#          run.sh 会依次跑三遍.
#==============================================================================
source -echo -verbose tcl/setenv.tcl
set corner $env(CORNER)
set report_default_significant_digits 4
# 报告里出现违例时仍然继续往下跑
set_app_var sh_continue_on_error true

set_app_var link_path [list * $corner_db($corner)]
read_verilog $NETLIST_FILES
current_design $DESIGN_NAME
link_design

# 反标寄生参数 (7_StarRC/reports_spef 下的 SPEF)
read_parasitics -format spef $PARASITIC_FILES($corner)
report_annotated_parasitics -check > $REPORTS_DIR/${corner}_report_annotated_parasitics.report

# 约束: 和综合用的同一份 (本目录 tcl/top.sdc 是指向 1_dc/tcl/top.sdc 的拷贝)
source -echo -verbose tcl/top.sdc
# 时钟树已经做好, 用真实的时钟网络延迟
set_propagated_clock [all_clocks]

# 最慢角查建立时间, 最快角查保持时间是重点; 这里每个角两种都查
update_timing -full
report_analysis_coverage -nosplit                                   > $REPORTS_DIR/${corner}_report_analysis_coverage.report
report_constraint -all_violators -nosplit                           > $REPORTS_DIR/${corner}_report_constraint.report
# -slack_lesser_than: 多条路径时 PrimeTime 默认只列违例的, 加上它把满足的也列出来
report_timing -delay_type max -max_paths 10 -slack_lesser_than 100 -nets -transition_time -nosplit \
                                                                    > $REPORTS_DIR/${corner}_report_timing_max.report
report_timing -delay_type min -max_paths 10 -slack_lesser_than 100 -nosplit                > $REPORTS_DIR/${corner}_report_timing_min.report
report_global_timing                                                > $REPORTS_DIR/${corner}_report_global_timing.report
report_clock_timing -type skew -nosplit                             > $REPORTS_DIR/${corner}_report_clock_skew.report

# 后仿用的延迟文件
write_sdf -version 3.0 -context verilog $REPORTS_DIR/${DESIGN_NAME}_$corner.sdf
exit
