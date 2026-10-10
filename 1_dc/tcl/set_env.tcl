#==============================================================================
# set_env.tcl : 工艺库环境. 不需要修改 (库路径来自 flow.cfg / common/env.sh)
#==============================================================================
set_app_var search_path      [concat . $env(DB_DIR) $search_path]
# 综合用的工艺角由 common/env.sh 的 DB_SYN 决定 (tsmc180: 最慢角; gf180mcu: 典型角)
set_app_var target_library   [list $env(DB_SYN)]
set_app_var synthetic_library [list dw_foundation.sldb]
set_app_var link_library     [concat * $target_library $synthetic_library]

# 中间文件放到 work/ 下, 不弄乱当前目录
define_design_lib WORK -path ./work
