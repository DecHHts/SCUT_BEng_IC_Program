#==============================================================================
# 05_cts.tcl : 时钟树综合 + 时钟树后的优化 (建立, 保持时间)
#==============================================================================
# 时钟树只用专门的时钟缓冲器 / 反相器
set cts_cells [expand_cells [concat $env(CLKBUF_CELLS) $env(CLKINV_CELLS)]]
set_dont_touch $cts_cells false
set_lib_cell_purpose -exclude cts [get_lib_cells */*]
set_lib_cell_purpose -include cts $cts_cells

# 时钟线走 M3/M4
if {[sizeof_collection [get_routing_rules -quiet cts_rule]] == 0} {
    create_routing_rule cts_rule -default_reference_rule
}
set_clock_routing_rules -rules cts_rule -min_routing_layer $env(M3) -max_routing_layer $env(M4)

# 目标: 转换时间 250 ps, 偏斜 50 ps
set_clock_tree_options -target_skew 0.05
set_max_transition 0.25 -clock_path [get_clocks clk]

# 时钟树之后时钟按真实延迟计算, 保持时间从这里开始修 (clock_opt 默认就修)
clock_opt

connect_pg_net -automatic
report_clock_qor -type summary > reports/clock_qor.rpt
report_clock_qor -type latency > reports/clock_latency.rpt
report_qor -summary            > reports/qor_cts.rpt
