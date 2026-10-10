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

# 输入端口保护二极管: 输入端口的线网在芯片内没有驱动器, 也就没有能泄放电荷的扩散区,
# 线稍长就违反天线规则. 给每个输入端口接一个二极管单元.
#   ICC2 的 add_port_protection_diodes 要求库单元在建库时就标成 diode 类型, 从 LEF 建的库
#   没有这个标记, 所以这里手工例化并连线, 位置交给后面的布局去定.
if {[info exists env(ANT_DIODE_CELL)] && $env(ANT_DIODE_CELL) ne ""} {
    set dio [index_collection [expand_cells $env(ANT_DIODE_CELL)] 0]
    set inp [get_ports -filter {direction==in}]
    set_dont_touch $dio false
    set i 0
    foreach_in_collection p $inp {
        set n [get_nets -quiet -of_objects $p]
        if {[sizeof_collection $n] == 0} { continue }
        create_cell ANT_DIODE_$i $dio
        # 这个库里电源地引脚的方向也是 in, 要按 "信号引脚" 来选
        connect_net -net $n [get_pins ANT_DIODE_$i/* -filter {port_type==signal}]
        incr i
    }
    # 二极管只有输入没有输出, 不保护的话优化时会被当成无用单元删掉
    set_dont_touch [get_cells ANT_DIODE_*] true
    connect_pg_net -automatic
    puts "== 端口保护二极管: [sizeof_collection [get_cells -quiet -hierarchical -filter "ref_name==$env(ANT_DIODE_CELL)"]] 个 (输入端口 [sizeof_collection $inp] 个)"
}
