#==============================================================================
# setenv.tcl : PrimeTime 环境
#==============================================================================
set DESIGN_NAME    $env(TOP)
set NETLIST_FILES  ../$env(PNR_DIR)/postlayout/$DESIGN_NAME.v
set REPORTS_DIR    reports
set_app_var search_path [concat . $env(DB_DIR) $search_path]

# 三个工艺角各自的逻辑库和寄生参数文件
array set corner_db   [list wst $env(DB_WST) typ $env(DB_TYP) bst $env(DB_BST)]
foreach c {wst typ bst} {
    set PARASITIC_FILES($c) ../7_StarRC/reports_spef/${DESIGN_NAME}_$c.spef
}
