#==============================================================================
# 01_floorplan.tcl : 布图规划 (宽长比 1.0, 利用率和边距取自 flow.cfg)
#==============================================================================
set m $env(CORE_MARGIN)
# 标准单元的 site (名字在 common/env.sh 的 SITE_DEF); 让它成为默认的行类型
if {[sizeof_collection [get_site_defs -quiet $env(SITE_DEF)]] > 0} {
    set_attribute [get_site_defs $env(SITE_DEF)] is_default true
    set_attribute [get_site_defs $env(SITE_DEF)] symmetry Y
    initialize_floorplan -core_utilization $env(CORE_UTIL) -side_ratio {1 1} \
                         -core_offset [list $m $m $m $m] -site_def $env(SITE_DEF)
} else {
    puts "警告: 参考库里没有 site $env(SITE_DEF), 使用工艺文件的默认 site (get_site_defs 查看)"
    initialize_floorplan -core_utilization $env(CORE_UTIL) -side_ratio {1 1} \
                         -core_offset [list $m $m $m $m]
}
# 阱接触单元: 每行每隔 TAP_DISTANCE 放一个, 位置固定. 必须在布局之前放
if {$env(WELLTAP_CELL) ne ""} {
    create_tap_cells -lib_cell [expand_cells $env(WELLTAP_CELL)] -distance $env(TAP_DISTANCE) \
                     -pattern every_row -skip_fixed_cells
    puts "== 阱接触单元: [sizeof_collection [get_cells -quiet -hierarchical -filter {ref_name=~TAPCELL*}]] 个"
}
puts "\n== 核心区: [get_attribute [get_core_area] bbox]   芯片边界: [get_attribute [current_block] boundary_bbox]"
