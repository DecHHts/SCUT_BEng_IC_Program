#==============================================================================
# 06_route.tcl : 信号线布线 + 布线后优化
#==============================================================================
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven  -value true
set_app_options -name route.detail.timing_driven -value true

# 天线: 工艺文件里没有天线规则, 这里补上; 布线器先靠换层解决, 不行再接保护二极管
if {[catch {source -echo ../icc2_files/antenna.tcl} msg]} { puts "警告: 天线规则没有设置成功: $msg" }
foreach {opt val} [list route.detail.antenna true \
                        route.detail.antenna_fixing_preference hop_layers \
                        route.detail.insert_diodes_during_routing true \
                        route.detail.diode_libcell_names $env(ANT_DIODE_CELL)] {
    if {[catch {set_app_options -name $opt -value $val} msg]} { puts "警告: 选项 $opt 没有设置成功" }
}

route_auto
route_opt

# 这个设计在 200 MHz 下没有多少余量, 布线后常剩几十皮秒的违例.
# 做法: 临时把不确定度加大一点让工具多优化一些, 再改回题目要求的值, 最后平衡一轮.
#   (建立 1.0 -> 1.1 ns, 保持 0.3 -> 0.35 ns; 报告始终按 1.0 / 0.3 出)
current_scenario func_wc
set_clock_uncertainty -setup 1.1 [get_clocks clk]
route_opt
set_clock_uncertainty -setup 1.0 [get_clocks clk]
current_scenario func_bc
set_clock_uncertainty -hold 0.35 [get_clocks clk]
route_opt
set_clock_uncertainty -hold 0.3 [get_clocks clk]
current_scenario func_wc
route_opt

connect_pg_net -automatic
check_routes        > reports/check_routes_route.rpt
report_qor -summary > reports/qor_route.rpt
puts [exec cat reports/qor_route.rpt]
puts [exec sh -c {grep -E "Total number of (DRCs|open nets|antenna)" reports/check_routes_route.rpt; true}]
