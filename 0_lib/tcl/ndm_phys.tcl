#==============================================================================
# ndm_phys.tcl : 只含物理信息的参考库, 提供填充单元和阱接触单元
#   这些单元只在 LEF 里有, 时序库 .db 里没有, 常规流程建的主库不会收进去.
#==============================================================================
create_workspace -flow physical_only -technology $env(TECH_TF) fill_phys
read_lef $env(CELL_LEF)
check_workspace
commit_workspace -force -output ndm/fill_phys.ndm
exit
