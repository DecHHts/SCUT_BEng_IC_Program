#==============================================================================
# dc.tcl : Design Compiler 综合主脚本
#   输入: RTL + top.sdc          输出: output/ 下的网表, SDF, SDC, SVF, 各种报告
#==============================================================================
source -echo -verbose tcl/set_env.tcl
source -echo -verbose tcl/define.tcl
file mkdir $OUT

# 记录综合中做的结构变换 (重命名, 常量寄存器删除等), 给 Formality 做对应点匹配用
set_svf $OUT/$DESIGN_NAME.svf

#---------------- 读入设计 ----------------
set_app_var search_path [concat $rtl_dir $search_path]
analyze -format verilog $RTL_SOURCE_FILES
elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link
uniquify
check_design > $OUT/$DESIGN_NAME.check_design.rpt

#---------------- 工作条件与线负载 ----------------
# 库里定义了工作条件名和线负载模型时使用 (变量来自 common/env.sh, 为空则跳过)
if {$env(OPCOND_SYN) ne ""} { set_operating_conditions $env(OPCOND_SYN) }
if {$env(WLM_GROUP)  ne ""} {
    set_wire_load_mode segmented
    set_wire_load_selection_group $env(WLM_GROUP)
}

#---------------- 约束 ----------------
source -echo -verbose tcl/top.sdc
source -echo -verbose tcl/dont_use_cell.tcl
# 修保持时间 (这是 DC 的命令, 不属于标准 SDC, 所以不放在 top.sdc 里)
set_fix_hold [get_clocks clk]
# 网表里不要出现 assign 和 tri, 后端工具处理起来麻烦
set_fix_multiple_port_nets -all -buffer_constants
set_app_var verilogout_no_tri true

#---------------- 综合 ----------------
# compile_ultra 需要 DC Ultra 许可; 如果报许可错误, 把下面两行换成:
#     compile -map_effort high
#     compile -incremental -map_effort high
compile_ultra -no_autoungroup
compile_ultra -incremental -no_autoungroup

#---------------- 输出 ----------------
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output $OUT/$DESIGN_NAME.v
write -format ddc     -hierarchy -output $OUT/$DESIGN_NAME.ddc
write_sdf -version 2.1 $OUT/$DESIGN_NAME.sdf
write_sdc -nosplit     $OUT/$DESIGN_NAME.sdc
set_svf -off

report_timing -delay_type max -max_paths 10 -nets -transition_time -nosplit > $OUT/$DESIGN_NAME.timing.rpt
report_timing -delay_type min -max_paths 10 -nosplit                        > $OUT/$DESIGN_NAME.timing_hold.rpt
report_area -hierarchy -nosplit                                              > $OUT/$DESIGN_NAME.area.rpt
report_power -nosplit                                                        > $OUT/$DESIGN_NAME.power.rpt
report_qor                                                                   > $OUT/$DESIGN_NAME.qor.rpt
report_constraint -all_violators -nosplit                                    > $OUT/$DESIGN_NAME.con
report_reference -hierarchy -nosplit                                         > $OUT/$DESIGN_NAME.cells.rpt

puts "\n==== 综合结束. 最差建立时间路径的 slack: ===="
redirect -variable r {report_timing -delay_type max -nosplit}
puts [lindex [regexp -inline -line {^\s*slack.*$} $r] 0]
puts "==== 输入 gui_start 看电路图; 输入 exit 退出 ====\n"
