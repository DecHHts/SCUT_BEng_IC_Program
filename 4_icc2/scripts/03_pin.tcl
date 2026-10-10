#==============================================================================
# 03_pin.tcl : 端口位置. 数据从左边进 (a b c), 右边出 (y); clk 和 e 在上边
#   边的编号: 从左下角出发顺时针, 1 = 左, 2 = 上, 3 = 右, 4 = 下
#==============================================================================
set_block_pin_constraints -self -allowed_layers [list $env(M2) $env(M3) $env(M4)] -pin_spacing 2
set_individual_pin_constraints -ports [get_ports {a[*] b[*] c[*]}] -sides 1 -allowed_layers $env(M3)
set_individual_pin_constraints -ports [get_ports {y[*]}]           -sides 3 -allowed_layers $env(M3)
set_individual_pin_constraints -ports [get_ports {clk e}]          -sides 2 -allowed_layers $env(M2)
place_pins -self
set_attribute [get_ports *] physical_status fixed
check_pin_placement -self > reports/check_pin_placement.rpt

