#==============================================================================
# 08_export.tcl : 文件输出
#   function_gen.v      后端网表, 不含填充等纯物理单元 (给 Formality, PrimeTime, 后仿)
#   function_gen_pg.v   带电源地连接和物理单元的网表 (给 LVS)
#   function_gen.def    版图的 DEF
#   function_gen.gds    完整版图 (合并了标准单元的版图)
#   function_gen.spef   ICC2 提取的寄生参数 (没有 StarRC 工艺文件, 用它做时序签核)
#==============================================================================
set P ../postlayout
file mkdir $P
save_block -as ${TOP}_final
save_lib

change_names -rules verilog -hierarchy
write_verilog -exclude {scalar_wire_declarations leaf_module_declarations empty_modules \
                        pg_objects end_cap_cells well_tap_cells filler_cells \
                        pad_spacer_cells physical_only_cells cover_cells} $P/$TOP.v

# 带电源地连接和物理单元 (填充, 阱接触) 的网表: 不排除 pg_objects 和物理单元即可
write_verilog -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} $P/${TOP}_pg.v

write_def -include_tech_via_definitions $P/$TOP.def

# 寄生参数: 文件名会被自动加上工艺角和温度后缀, 之后由 7_StarRC/run.sh 统一改名
write_parasitics -format spef -output $P/$TOP

# GDS: 合并标准单元版图; 端口文字标签写到 Calibre LVS 规则读取的 pin text 层
write_gds -hierarchy all -long_names -keep_data_type \
          -merge_files [list $env(CELL_GDS)] \
          -layer_map $env(STREAM_MAP) -layer_map_format icc_default \
          -output_pin all -units $env(GDS_UNITS) \
          $P/$TOP.gds
# 电源地的文字标签: Calibre LVS 需要在版图上看到 VDD / VSS 这两个名字.
# 取电源环在顶层金属上的一段, 把它的中心坐标写成 Calibre 的 LAYOUT TEXT 语句,
# 5_LVS/run.sh 会把这个文件接到规则文件后面.  文字层 = 该金属层对应的 pin text 层.
# 各层金属的 pin text 层号属于 PDK 的内容, 放在不进仓库的本地文件里 (模板: text_layers.tcl.example)
source ../icc2_files/text_layers.tcl
set fp [open $P/pg_text.svrf w]
foreach n [list $PWR $GND] {
    set shp [index_collection [get_shapes -of_objects [get_nets $n] -filter "layer_name==$env(M6)"] 0]
    set bb  [get_attribute $shp bbox]
    set x [expr {([lindex $bb 0 0] + [lindex $bb 1 0]) / 2.0}]
    set y [expr {([lindex $bb 0 1] + [lindex $bb 1 1]) / 2.0}]
    puts $fp [format {LAYOUT TEXT "%s" %.3f %.3f %d "%s"} $n $x $y $textlayer($env(M6)) $TOP]
}
close $fp

puts "\n== 导出完成: [glob $P/*]"
