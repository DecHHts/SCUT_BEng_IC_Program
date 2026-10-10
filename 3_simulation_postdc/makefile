# 第 2 次仿真 (前仿): DC 网表 + DC 写出的 SDF  ->  波形 2
STAGE = gate
SDF   = ./rtl/function_gen.sdf
PREP  = prep
include ../common/sim.mk

# 把网表, SDF, testbench 拷过来
prep:
	mkdir -p rtl tb
	cp ../1_dc/output/$(TOP).v   ./rtl/
	cp ../1_dc/output/$(TOP).sdf ./rtl/
	cp ../0_simulation_pre/tb/*.v ./tb/
