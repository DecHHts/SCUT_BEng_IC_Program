#==============================================================================
# common/sim.mk : 三次 VCS 仿真共用的规则
#   0_simulation_pre / 3_simulation_postdc / 9_simulation_postlayout 下的
#   makefile 只设置几个变量, 然后 include 这个文件.
#
#   make run_vcs     编译并仿真
#   make vd          Verdi 看波形
#   make clean
#   可选:  make run_vcs N=200000      随机向量组数 (传给 testbench 的 +n=)
#==============================================================================
SHELL := /bin/bash
PROJ  := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
# 把 env.sh 导出的变量取进 make
ENVV  := $(shell source $(PROJ)/common/env.sh && echo "$$TOP|$$CLOCK_PERIOD|$$CELL_V")
TOP          := $(word 1,$(subst |, ,$(ENVV)))
CLOCK_PERIOD := $(word 2,$(subst |, ,$(ENVV)))
CELL_V       := $(shell source $(PROJ)/common/env.sh && echo $$CELL_V)
PNR_DIR      := $(shell source $(PROJ)/common/env.sh && echo $$PNR_DIR)
CLK_HALF     := $(shell awk "BEGIN{printf \"%.3f\", $(CLOCK_PERIOD)/2}")

simv_name = simv
src_list  = filelist
tb_top    = tb_$(TOP)
N        ?=

# 新版 VCS 用 -debug_access+all (旧写法 -debug_all 已废弃); -kdb 生成 Verdi 数据库
COMMON_OPT = -full64 -sverilog +v2k -timescale=1ns/1ps \
             -debug_access+all -kdb \
             +vcs+flush+all \
             +define+FSDB \
             +define+CLK_HALF=$(CLK_HALF) \
             -o $(simv_name) -l compile.log
# FSDB: 新版 VCS + Verdi 只需要 -debug_access+all -kdb 和环境变量 VERDI_HOME, 不要再加 -P novas.tab

ifeq ($(STAGE),rtl)
# RTL 仿真: 不需要时序检查
VCS_OPT = $(COMMON_OPT) +incdir+./rtl +notimingcheck +nospecify -f $(src_list).f
else
# 门级仿真: 网表 + 单元模型 + SDF 反标.  +neg_tchk 允许负的时序检查值
VCS_OPT = $(COMMON_OPT) +neg_tchk +lint=TFIPC-L \
          '+define+SDF_FILE="$(SDF)"' \
          $(addprefix -v ,$(CELL_V)) -f $(src_list).f
endif

.PHONY: run_vcs vd clean
run_vcs: $(PREP)
	vcs $(VCS_OPT)
	./$(simv_name) -l run.log $(if $(N),+n=$(N))
	@echo; grep -E "TEST PASSED|TEST FAILED" run.log || echo "run.log 里没有 TEST PASSED / FAILED, 仿真可能没有正常结束"

vd:
	verdi -sv +v2k -f $(src_list).f $(if $(filter rtl,$(STAGE)),+incdir+./rtl,$(addprefix -v ,$(CELL_V))) \
	      -top $(tb_top) -ssf $(tb_top).fsdb -nologo &

clean:
	rm -rf csrc simv* *.log *.key *.fsdb ucli.key verdiLog novas.* DVEfiles *.vpd vc_hdrs.h sdf_annotate.log
