#!/usr/bin/env python3
# 生成 cos_rom.vh: 1/4 周期余弦表, 1024 项, 2^14 表示 1.0
import math
with open("rtl/cos_rom.vh", "w") as f:
    for i in range(1024):
        v = round(16384 * math.cos(2 * math.pi * i / 4096))
        f.write("10'd%-4d: rom = 15'd%d;\n" % (i, v))
