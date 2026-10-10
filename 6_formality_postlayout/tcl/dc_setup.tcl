#==============================================================================
# dc_setup.tcl (后端形式验证): 参考设计 = DC 网表, 实现设计 = 布局布线后的网表
#   这一次不需要 SVF: 布局布线只插缓冲器, 改单元尺寸, 建时钟树, 不改寄存器名.
#==============================================================================
set DESIGN_NAME   $env(TOP)
set REPORTS_DIR   reports
set SVF_FILE      ""
set IMPL_NETLIST  ../$env(PNR_DIR)/postlayout/$DESIGN_NAME.v

set LIB_DB        $env(DB_DIR)/$env(DB_SYN)

# 参考设计: DC 综合出的门级网表
set REF_TYPE      netlist
set REF_FILES     [list ../1_dc/output/$DESIGN_NAME.v]
