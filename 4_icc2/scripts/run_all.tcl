#==============================================================================
# run_all.tcl : 按顺序执行全部步骤.  环境变量 LAST_STEP=N 时只跑到第 N 步.
#==============================================================================
set steps {00_init 01_floorplan 02_power 03_pin 04_place 05_cts 06_route 07_finish 08_export}
set last 8
if {[info exists env(LAST_STEP)]} { set last $env(LAST_STEP) }
foreach s $steps {
    scan [string range $s 0 1] %d n
    if {$n > $last} break
    puts "\n######## $s ########"
    source -echo -verbose ../scripts/$s.tcl
    if {$n >= 1} { save_block -as ${TOP}_$s }
}
if {$last >= 8} { exit }
