#==============================================================================
# 06_route.tcl : 信号线布线 + 布线后优化 (基础版)
#==============================================================================
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven  -value true
set_app_options -name route.detail.timing_driven -value true

route_auto
route_opt

connect_pg_net -automatic
check_routes        > reports/check_routes_route.rpt
report_qor -summary > reports/qor_route.rpt
puts [exec cat reports/qor_route.rpt]
puts [exec sh -c {grep -E "Total number of (DRCs|open nets|antenna)" reports/check_routes_route.rpt; true}]
