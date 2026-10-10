# function_gen：从 RTL 到版图的完整练习（题目版）

用一道小题目把数字集成电路的全流程走一遍：设计一个定点运算电路，验证、综合、布局布线、版图验证、时序签核、后仿。

```
        a · b · cos(2π · c / 4096)
y = ───────────────────────────────
           (a + d) · 4096
```

| 项目 | 要求 |
| --- | --- |
| 数据格式 | a、b、c、d 为 12 位无符号整数；y 为 13 位有符号数（真实值 = y / 4096） |
| 端口 | 输入只有 `a[11:0]`、`b[11:0]`、`c[11:0]`、`e`、`clk`；输出 `y[12:0]`。d 通过 `e` 串行写入 |
| 精度 | 误差不超过 y 的 ±4 个最低位 |
| 时序 | 200 MHz；建立时间不确定度 1 ns，保持时间不确定度 300 ps |
| 目标 | 满足以上条件的前提下，输入到输出的延迟拍数尽量小 |

**详细的题目说明、环境要求、每一步怎么做、会遇到哪些问题，见 [`docs/function_gen项目说明.pdf`](docs/function_gen项目说明.pdf)。**

## 这个分支里有什么

- 目录结构和能运行的**基础**流程脚本（VCS / Verdi、Design Compiler、Formality、IC Compiler II、Calibre、PrimeTime）
- 一份验收用 testbench（`0_simulation_pre/tb/`，延迟拍数和串行格式要按你的设计改）
- **没有 RTL**，`1_dc/tcl/top.sdc` 是待填的模板，后端脚本只做最基本的事

需要你自己完成的：设计 RTL、写时序约束、解决综合和布局布线中的时序问题、让 DRC / 天线 / LVS 通过、让 PrimeTime 三个工艺角无违例。说明文档第 6 章列出了会遇到的问题和方向。

做完想对照，或者只想看完整流程怎么搭：切到 [`solution`](../../tree/solution) 分支。

## 开始

1. 准备 EDA 工具和一套 0.18 µm 标准单元库及 PDK（**不随仓库提供**，见说明文档第 3 章）。
2. 改 `flow.cfg` 里的库路径；库的文件名、单元名和默认配置不一样时改 `common/env.sh`。
3. 对照自己的 PDK，从模板生成两个本地文件（它们含设计规则数值，不进仓库）：
   ```
   cp 4_icc2/icc2_files/gdsout_text.map.example  4_icc2/icc2_files/gdsout_text.map
   cp 4_icc2/icc2_files/text_layers.tcl.example  4_icc2/icc2_files/text_layers.tcl
   ```
4. `./check_env.sh` 看还缺什么。
5. 把设计放进 `0_simulation_pre/rtl/`，按下表顺序往下做。

| 步骤 | 目录 | 命令 |
| --- | --- | --- |
| 准备 | `0_lib` | `./run.sh` |
| 1 RTL 仿真 | `0_simulation_pre` | `make`；`make vd` 看波形 |
| 2 综合 | `1_dc` | `./run.sh` |
| 3 形式验证 | `2_formality_postdc` | `./run.sh` |
| 4 综合后仿真 | `3_simulation_postdc` | `make` |
| 5 布局布线 | `4_icc2` | `./run.sh N`（跑到第 N 步）或 `./run.sh all` |
| 6 形式验证 | `6_formality_postlayout` | `./run.sh` |
| 7 版图验证 | `5_DRC`、`5_LVS` | `./run.sh` |
| 8 寄生参数 | `7_StarRC` | `./run.sh` |
| 9 时序签核 | `8_pt` | `./run.sh` |
| 10 后仿 | `9_simulation_postlayout` | `make` |

## 说明

- 仓库不含任何工艺厂或 EDA 厂商的文件，也不含由它们生成的版图、网表、报告；`.gitignore` 已把这些排除，请不要提交。
- 脚本是在一套具体的工具版本和工艺库上调通的，换环境后预计需要调整。脚本里的库名和单元名只是配置示例。
- 题目来自一门数字集成电路设计课程的课程设计，这里是重新表述的版本。
