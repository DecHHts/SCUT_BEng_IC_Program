#!/bin/bash
#==============================================================================
# common/env.sh : 读 flow.cfg, 推导出各工具要用的库文件路径, 导出为环境变量.
#   每个步骤的 run.sh / makefile 都会先 source 它, tcl 脚本通过 $env(XXX) 读取.
#   不需要修改. 库文件名和你机器上不一致时, 改这里对应的那一行.
#==============================================================================
PROJ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJ/flow.cfg"
export PROJ LIB TOP CLOCK_PERIOD CORE_UTIL CORE_MARGIN
export CALIBRE_DRC_RULE CALIBRE_LVS_RULE STARRC_MAPFILE
export STARRC_NXTGRD_WST STARRC_NXTGRD_TYP STARRC_NXTGRD_BST

first() { ls $1 2>/dev/null | head -n 1; }      # 通配符匹配到的第一个文件

export PNR_DIR=4_icc2               # 布局布线目录
export OPCOND_WST="" OPCOND_TYP="" OPCOND_BST="" WLM_GROUP=""
export VOLT_WST="" VOLT_TYP="" VOLT_BST=""
export CALIBRE_STYLE=include        # include: 规则文件被 INCLUDE; embedded: 规则文件自带 LAYOUT 语句
export CALIBRE_ANT_RULE="" LVS_SOURCE_ADDED=""

case "$LIB" in
tsmc180)
    export TSMC_ROOT TSMC_METALS
    H="$TSMC_ROOT/SC/gbwp7t/TSMCHOME/digital"
    N=tcb018gbwp7t
    MW="$H/Back_End/milkyway/${N}_270a"
    export LIB_ROOT="$H" SCL=$N
    export PNR_DIR=4_icc2
    # 三个工艺角 (用 lc_shell 的 report_lib 核对过 wc: 1.62V 125C, 工作条件名 WCCOM)
    export CORNER_WST=wc CORNER_TYP=tc CORNER_BST=bc
    export OPCOND_WST=WCCOM          # 另两个角用各自库的默认工作条件
    export VOLT_WST=1.62 VOLT_TYP=1.80 VOLT_BST=1.98
    # 最快角的温度按 TSMC 惯例填 0; 用 report_lib tcb018gbwp7tbc 核对, 不同则改这里
    export TEMP_WST=125 TEMP_TYP=25 TEMP_BST=0
    # 时序库: 这套库只有 .db (在 Milkyway 库的 LM 目录里), 没有 .lib
    export DB_DIR="$MW/cell_frame/$N/LM"
    export DB_WST=${N}wc.db DB_TYP=${N}tc.db DB_BST=${N}bc.db
    export LIB_WST="" LIB_TYP="" LIB_BST=""
    # 综合时的线负载模型选择组 (库里自带; 保守组)
    export WLM_GROUP=WireAreaCon
    # 物理库
    export CELL_LEF="$H/Back_End/lef/${N}_270a/lef/${N}_${TSMC_METALS}lm.lef"
    export TECH_LEF="$CELL_LEF"          # 这份 LEF 同时包含工艺层定义和单元
    export LEF_FILES="$CELL_LEF"
    export TECH_TF="$MW/techfiles/tsmc018_${TSMC_METALS}lm.tf"
    export TLUPLUS="$MW/techfiles/tluplus/t018lo_1p${TSMC_METALS}m_typical.tluplus"
    export TLU_MAP="$MW/techfiles/tluplus/star.map_${TSMC_METALS}M"
    export NDM_LIB="$PROJ/0_lib/ndm/${N}.ndm"
    # 纯物理单元 (填充, 阱接触) 时序库里没有, 主库不收; 另建一个只含物理信息的库
    export NDM_PHYS="$PROJ/0_lib/ndm/fill_phys.ndm"
    export SITE_DEF=unit                 # 库管理器把 LEF 里的 core7T 改名成了 unit
    export CELL_GDS="$H/Back_End/gds/${N}_270a/${N}.gds"
    export CELL_SPICE="$H/Back_End/spice/${N}_270a/${N}_270a.spi"
    export CELL_CDL="$CELL_SPICE"
    export CELL_V="$H/Front_End/verilog/${N}_270a/${N}.v"
    export PWR_NET=VDD GND_NET=VSS PWR_PIN=VDD GND_PIN=VSS
    export M1=METAL1 M2=METAL2 M3=METAL3 M4=METAL4 M5=METAL5 M6=METAL6
    export ROUTE_TOP_LAYER=METAL4       # 信号线最高走到 M4, M5/M6 留给电源
    export TIE_CELLS="TIEHBWP7T TIELBWP7T"
    export FILL_CELLS="FILL64BWP7T FILL32BWP7T FILL16BWP7T FILL8BWP7T FILL4BWP7T FILL2BWP7T FILL1BWP7T"
    # 阱接触单元, 天线保护二极管单元: 需要时自己填单元名, 并在布局布线脚本里用起来
    export WELLTAP_CELL="" ENDCAP_CELL="" TAP_DISTANCE=""
    export ANT_DIODE_CELL=""
    export CLKBUF_CELLS="CKBD*BWP7T"
    export CLKINV_CELLS="CKND*BWP7T"
    # 综合时不使用: 三态, 锁存器, 门控时钟, 扫描触发器 (G* 开头的 ECO 单元库里已标 dont_use)
    export DONT_USE="BUFT* LH* LN* CKLH* CKLN* SDF* SEDF* BHD*"
    export STREAM_MAP="$PROJ/4_icc2/icc2_files/gdsout_text.map"
    export GDS_UNITS=1000
    # Calibre: 规则文件里自带 LAYOUT PATH / PRIMARY 语句, run.sh 生成改好路径的副本
    export CALIBRE_STYLE=embedded
    export CALIBRE_DRC_RULE="$TSMC_ROOT/PDK/drc_rule/calibre.drc"
    export CALIBRE_ANT_RULE="$TSMC_ROOT/PDK/drc_rule/ant.drc"
    export CALIBRE_LVS_RULE="$TSMC_ROOT/PDK/lvs_rule/calibre.lvs"
    export LVS_SOURCE_ADDED="$TSMC_ROOT/PDK/lvs_rule/source.added"
    ;;
*)
    echo "flow.cfg: LIB 目前只支持 tsmc180 (现在是 '$LIB'); 换别的库时照 tsmc180 这一段再写一段"; return 1 2>/dev/null || exit 1
    ;;
esac

# 综合 (以及 Formality) 用哪个角的库
export DB_SYN="$DB_WST" OPCOND_SYN="$OPCOND_WST"      # 用最慢角

# 设计文件 (顺序无关; cos_rom.vh 是被 include 的片段, 不能出现在这里)
export RTL_DIR="$PROJ/0_simulation_pre/rtl"
export RTL_FILES="function_gen.v"      # 把你自己的全部 .v 文件名列在这里 (空格分隔)
