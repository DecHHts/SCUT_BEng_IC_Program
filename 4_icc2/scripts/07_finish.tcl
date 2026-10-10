#==============================================================================
# 07_finish.tcl : 填充单元, 规则检查, 时序报告
#==============================================================================
create_stdcell_fillers -lib_cells [expand_cells $env(FILL_CELLS)] -prefix FILLER
connect_pg_net -automatic
remove_stdcell_fillers_with_violation
# 填充后布线器再检查并修一遍
route_detail -incremental true -initial_drc_from_input true

check_routes                       > reports/check_routes.rpt
check_lvs -max_errors 200          > reports/check_lvs.rpt
check_pg_drc                       > reports/check_pg_drc_final.rpt
check_legality                     > reports/check_legality_final.rpt

report_timing -scenarios func_wc -delay_type max -max_paths 10 -nets -transition_time -nosplit \
                                   > reports/timing_setup.rpt
report_timing -scenarios func_bc -delay_type min -max_paths 10 -nosplit \
                                   > reports/timing_hold.rpt
report_qor -summary                > reports/qor_final.rpt
report_global_timing               > reports/global_timing.rpt
report_utilization                 > reports/utilization_final.rpt
report_design -all                 > reports/design.rpt
puts [exec cat reports/qor_final.rpt]
