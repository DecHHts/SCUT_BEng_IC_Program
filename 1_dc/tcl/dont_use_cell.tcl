#==============================================================================
# dont_use_cell.tcl : 不让综合使用的单元 (三态门, 锁存器, 门控时钟单元).
#   通配符列表来自 common/env.sh 的 DONT_USE; 为空则不限制.
#==============================================================================
foreach pat $env(DONT_USE) {
    set cells [get_lib_cells -quiet */$pat]
    if {[sizeof_collection $cells] > 0} {
        set_dont_use $cells
        puts "dont_use: $pat  ([sizeof_collection $cells] 个单元)"
    }
}
