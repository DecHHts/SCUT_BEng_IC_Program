#==============================================================================
# ndm.tcl : 建 ICC2 用的 NDM 参考库 (在 icc2_lm_shell 里运行)
#   ICC2 不直接读 LEF / .db, 需要先把它们合成一个 .ndm:
#     物理信息 <- LEF (单元外框, 引脚) + 工艺文件 .tf (层, 布线规则)
#     时序信息 <- 三个工艺角的 .db
#==============================================================================
set name $env(SCL)
set_app_options -name lib.workspace.save_design_views -value true
set_app_options -name lib.workspace.save_layout_views -value true

create_workspace -technology $env(TECH_TF) -flow normal $name

read_db [list $env(DB_DIR)/$env(DB_WST) $env(DB_DIR)/$env(DB_TYP) $env(DB_DIR)/$env(DB_BST)]
read_lef $env(CELL_LEF)

# 检查物理库与逻辑库是否一致 (单元, 引脚能否对上). 有 Error 时不会提交
check_workspace
commit_workspace -force -output ndm/$name.ndm
exit
