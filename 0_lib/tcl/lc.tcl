#==============================================================================
# lc.tcl : .lib -> .db, 三个工艺角各转一次
#   库名 (read_lib 之后内存里的名字) 就是 .lib 文件里 library(...) 括号中的名字,
#   对这套开源库来说, 它和文件名 (去掉 .lib) 相同.
#==============================================================================
foreach c [list $env(CORNER_WST) $env(CORNER_TYP) $env(CORNER_BST)] {
    set name "$env(SCL)__$c"
    read_lib $env(LIB_ROOT)/lib/$name.lib
    write_lib $name -format db -output db/$name.db
}
exit
