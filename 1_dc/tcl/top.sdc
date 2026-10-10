#==============================================================================
# top.sdc : 时序约束 (DC / ICC2 / PrimeTime 共用同一份内容)
#   题目: 200 MHz; 建立时间不确定度 1 ns; 保持时间不确定度 300 ps;
#         a/b/c/e 在时钟上升沿输入.
#   周期取自 flow.cfg 的 CLOCK_PERIOD, 输入输出延迟各取半个周期.
#==============================================================================
set PERIOD $env(CLOCK_PERIOD)
set HALF   [expr {$PERIOD / 2.0}]

# 建立时钟
create_clock -name clk -period $PERIOD -waveform [list 0 $HALF] [get_ports clk]

# 时钟不确定度 (skew + jitter)
set_clock_uncertainty -setup 1.0 [get_clocks clk]
set_clock_uncertainty -hold  0.3 [get_clocks clk]

# 输入输出延迟: 各取半个周期, 不区分最大最小值.
#   输入: 上游在时钟上升沿之后半个周期把数据送到 (testbench 也是在下降沿改变输入);
#   输出: 留半个周期给下游.
#   注意不要把最小值单独设成 0: 那表示 "数据在时钟沿到达引脚的同一瞬间就变化",
#   而片内时钟还要经过时钟树才到寄存器, 布局布线工具和 PrimeTime 对这种情况的
#   处理方式不同, 会在端口路径上得出互相矛盾的结论.
set_input_delay  -clock clk $HALF [get_ports {a b c e}]
set_output_delay -clock clk $HALF [get_ports y]

# 时钟端口的最大扇出 (综合阶段时钟是理想网络, 时钟树留给 ICC2 做)
set_max_fanout 4 [get_ports clk]
