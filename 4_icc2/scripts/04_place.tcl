#==============================================================================
# 04_place.tcl : 布局 + 布局阶段优化 (含 Tie 单元)
#==============================================================================
# 常量 0/1 通过 Tie 单元接到电源地
set_dont_touch [expand_cells $env(TIE_CELLS)] false
set_lib_cell_purpose -include optimization [expand_cells $env(TIE_CELLS)]
set_app_options -name opt.tie_cell.max_fanout -value 8

set_app_options -name place.coarse.continue_on_missing_scandef -value true
place_opt
connect_pg_net -automatic

check_legality > reports/check_legality_place.rpt
report_qor -summary > reports/qor_place.rpt
report_utilization  > reports/utilization.rpt
