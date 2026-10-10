# 第 3 次仿真 (后仿): 布局布线后的网表 + PrimeTime 写出的 SDF  ->  波形 3
#   默认反标典型角. 换工艺角:  make run_vcs CORNER=wst   (wst / typ / bst)
STAGE  = gate
CORNER ?= typ
SDF    = ./rtl/function_gen_$(CORNER).sdf
PREP   = prep
include ../common/sim.mk

prep:
	mkdir -p rtl tb
	cp ../$(PNR_DIR)/postlayout/$(TOP).v ./rtl/
	cp ../8_pt/reports/$(TOP)_*.sdf     ./rtl/
	cp ../0_simulation_pre/tb/*.v       ./tb/
