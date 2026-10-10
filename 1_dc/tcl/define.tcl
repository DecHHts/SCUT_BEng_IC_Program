#==============================================================================
# define.tcl : 指定顶层模块和要综合的 RTL 文件
#   设计文件直接从 0_simulation_pre/rtl 读, 保证综合的和仿真的是同一份代码.
#   cos_rom.vh 是被 `include 的片段, 不能列在这里, 靠 search_path 找到.
#==============================================================================
set DESIGN_NAME       $env(TOP)
set rtl_dir           $env(RTL_DIR)
set RTL_SOURCE_FILES  $env(RTL_FILES)
set OUT               ./output
