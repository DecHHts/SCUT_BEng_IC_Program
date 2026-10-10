#==============================================================================
# 02_power.tcl : 电源环, 电源条, 单元行电源轨
#   环: 上下边 M5 (水平), 左右边 M6 (垂直);  条: M6 垂直;  轨: M1 (单元自带的电源轨位置)
#==============================================================================
remove_pg_strategies -all; remove_pg_patterns -all

create_pg_ring_pattern ring_pat \
    -horizontal_layer $env(M5) -horizontal_width 4 -horizontal_spacing 2 \
    -vertical_layer   $env(M6) -vertical_width   4 -vertical_spacing   2
set_pg_strategy ring_strat -core \
    -pattern [list [list name: ring_pat] [list nets: [list $PWR $GND]] [list offset: {2 2}]]

create_pg_mesh_pattern mesh_pat \
    -layers [list [list [list vertical_layer: $env(M6)] {width: 2} {spacing: 2} {pitch: 80} {offset: 40}]]
set_pg_strategy mesh_strat -core \
    -pattern [list [list name: mesh_pat] [list nets: [list $PWR $GND]]] \
    -extension {{stop: outermost_ring}}

create_pg_std_cell_conn_pattern rail_pat -layers $env(M1)
set_pg_strategy rail_strat -core \
    -pattern [list [list name: rail_pat] [list nets: [list $PWR $GND]]] \
    -extension {{stop: outermost_ring}}

compile_pg -strategies {ring_strat mesh_strat rail_strat}

check_pg_connectivity > reports/check_pg_connectivity.rpt
check_pg_drc          > reports/check_pg_drc.rpt
