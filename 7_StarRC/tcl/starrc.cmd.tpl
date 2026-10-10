* StarRC 命令文件模板. run.sh 把 @...@ 换成实际值, 生成 wst.cmd / typ.cmd / bst.cmd
* Library and design
BLOCK                       : @TOP@

* Extraction
EXTRACTION                  : RC
COUPLE_TO_GROUND            : YES
REDUCTION                   : YES

* Processing
STAR_DIRECTORY              : ./reports_spef/starrc_@CORNER@
NETS                        : *
SKIP_CELLS                  : *

* LEF / DEF 流程: 直接读 布局布线工具 导出的 DEF, 不需要 GDS
LEF_FILE                    : @LEF@
TOP_DEF_FILE                : @DEF@

* Netlist
SUMMARY_FILE                : ./reports_spef/@TOP@_@CORNER@.star_sum
NETLIST_FILE                : ./reports_spef/@TOP@_@CORNER@.spef
NETLIST_FORMAT              : SPEF

* 工艺文件
TCAD_GRD_FILE               : @GRD@
MAPPING_FILE                : @MAP@
OPERATING_TEMPERATURE       : @TEMP@
