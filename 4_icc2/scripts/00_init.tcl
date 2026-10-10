#==============================================================================
# 00_init.tcl : 建设计库, 读网表, 建立分析场景
#==============================================================================
set TOP $env(TOP)
set PWR $env(PWR_NET)
set GND $env(GND_NET)
file mkdir reports

proc expand_cells {patterns} {
    # 把单元名通配符展开成参考库里实际存在的单元 (返回 lib_cell 集合)
    # 先在主库里找; 主库没有的 (填充, 阱接触等纯物理单元) 再到其他参考库里找
    set col ""
    foreach p $patterns {
        set c [get_lib_cells -quiet $::env(SCL)/$p]
        if {[sizeof_collection $c] == 0} { set c [get_lib_cells -quiet */$p] }
        append_to_collection -unique col $c
    }
    return $col
}

#---------------- 设计库 ----------------
if {[file exists $TOP.dlib]} { file delete -force $TOP.dlib }
set ref_libs [list $env(NDM_LIB)]
if {[info exists env(NDM_PHYS)] && [file exists $env(NDM_PHYS)]} { lappend ref_libs $env(NDM_PHYS) }
create_lib -technology $env(TECH_TF) -ref_libs $ref_libs $TOP.dlib

#---------------- 网表 ----------------
read_verilog -top $TOP ../../1_dc/output/$TOP.v
link_block
save_block -as ${TOP}_init

#---------------- 电源地 ----------------
# 读入最简 UPF (一个电源域, VDD / VSS), 然后把所有单元的电源地引脚自动接上去
load_upf ../icc2_files/top.upf
commit_upf
connect_pg_net -automatic

#---------------- 连线寄生参数模型 (TLU+) ----------------
read_parasitic_tech -name tlu_typ -tlup $env(TLUPLUS) -layermap $env(TLU_MAP)

#---------------- 模式, 工艺角, 场景 ----------------
# 一个功能模式; 两个工艺角: 最慢角查建立时间, 最快角查保持时间.
# 这套库只有典型角的 TLU+, 两个角共用 (单元延迟随角变化, 连线寄生不变).
remove_modes -all; remove_corners -all; remove_scenarios -all
create_mode func
foreach {c volt temp} [list wc $env(VOLT_WST) $env(TEMP_WST)  bc $env(VOLT_BST) $env(TEMP_BST)] {
    create_corner $c
    create_scenario -name func_$c -mode func -corner $c
    current_scenario func_$c
    set_parasitic_parameters -early_spec tlu_typ -late_spec tlu_typ
    set_process_number 1.0
    set_temperature $temp
    set_voltage $volt -object_list [get_supply_nets $PWR]
    set_voltage 0.0   -object_list [get_supply_nets $GND]
    # 约束: 和综合用的同一份
    source ../../1_dc/tcl/top.sdc
}
set_scenario_status func_wc -setup true  -hold false -leakage_power true  -dynamic_power true
set_scenario_status func_bc -setup false -hold true  -leakage_power false -dynamic_power false
current_scenario func_wc

#---------------- 布线层 ----------------
# 信号线最高走到 ROUTE_TOP_LAYER, 更高层留给电源
set_ignored_layers -max_routing_layer $env(ROUTE_TOP_LAYER)
set_attribute [get_layers {METAL1 METAL3 METAL5}] routing_direction horizontal
set_attribute [get_layers {METAL2 METAL4 METAL6}] routing_direction vertical

report_ref_libs
check_design -checks pre_placement_stage > reports/check_design_init.rpt
puts "\n== 已导入. 单元数: [sizeof_collection [get_cells -hierarchical -filter is_hierarchical==false]]"
