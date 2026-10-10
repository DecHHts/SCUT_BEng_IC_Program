//==============================================================================
// tb_function_gen.v : 验收用 testbench (可以按自己的设计修改)
//   两处和具体设计有关, 换成你自己的:
//     1. LATENCY     : 输入到输出的拍数
//     2. 写入 d 的任务 : 这里假设的串行格式是 "e 空闲为 0; 先送 1 位起始位 1,
//                       再送 12 位数据, 高位在前". 你定的格式不同就改这个任务.
//   判定: 每个输出与实数参考模型比较, 误差超过 TOL (单位 LSB) 记为失败.
//==============================================================================
`timescale 1ns/1ps
`ifndef CLK_HALF
  `define CLK_HALF 2.5
`endif
module tb_function_gen;
    localparam LATENCY = 18;
    localparam real TOL = 4.0;
    reg clk = 1'b0;
    reg [11:0] a = 0, b = 0, c = 0;
    reg e = 1'b0;
    wire [12:0] y;
    function_gen dut (.clk(clk), .a(a), .b(b), .c(c), .e(e), .y(y));
    always #(`CLK_HALF) clk = ~clk;

    function real ref_y(input [11:0] fa, input [11:0] fb, input [11:0] fc, input [11:0] fd);
        real ra, rb, rc, rd;
        begin
            ra = fa; rb = fb; rc = fc; rd = fd;
            if (ra + rd == 0.0) ref_y = 0.0;
            else ref_y = ra * rb * $cos(6.283185307179586 * rc / 4096.0) / (ra + rd);
        end
    endfunction

    reg [11:0] d_now = 0;
    reg        drive_en = 1'b0;
    real       exp_q [0:LATENCY];
    reg        vld_q [0:LATENCY];
    integer i, n_check = 0, n_fail = 0, n_rand = 100000;
    real err, max_err = 0.0, y_real;

    // 期望值延迟线: 上升沿采样输入, 与 DUT 同步
    always @(posedge clk) begin
        for (i = LATENCY; i > 0; i = i - 1) begin exp_q[i] <= exp_q[i-1]; vld_q[i] <= vld_q[i-1]; end
        exp_q[0] <= ref_y(a, b, c, d_now);
        vld_q[0] <= drive_en;
    end
    // 下降沿比对
    always @(negedge clk) if (vld_q[LATENCY-1] === 1'b1) begin
        y_real = $signed(y);
        err = y_real - exp_q[LATENCY-1];
        if (err < 0) err = -err;
        if (err > max_err) max_err = err;
        n_check = n_check + 1;
        if (!(err <= TOL)) begin
            n_fail = n_fail + 1;
            if (n_fail <= 10) $display("FAIL: y=%0d expect=%.3f", $signed(y), exp_q[LATENCY-1]);
        end
    end

    task write_d(input [11:0] v);
        integer k;
        begin
            drive_en = 1'b0;
            repeat (LATENCY + 4) @(negedge clk);        // 等管线里的旧数据出完
            e = 1'b1; @(negedge clk);                   // 起始位
            for (k = 11; k >= 0; k = k - 1) begin e = v[k]; @(negedge clk); end
            e = 1'b0; d_now = v;
            repeat (4) @(negedge clk);
            drive_en = 1'b1;
        end
    endtask

    reg [11:0] edge_v [0:5];
    integer ia, ib, ic, id;
    initial begin
        edge_v[0]=0; edge_v[1]=1; edge_v[2]=2047; edge_v[3]=2048; edge_v[4]=4094; edge_v[5]=4095;
        if ($value$plusargs("n=%d", n_rand)) ;
        for (i = 0; i <= LATENCY; i = i + 1) vld_q[i] = 1'b0;
        repeat (20) @(negedge clk);                     // e 保持 0, 让 d_rx 回到空闲
        // 边界值全组合
        for (id = 0; id < 6; id = id + 1) begin
            write_d(edge_v[id]);
            for (ia = 0; ia < 6; ia = ia + 1) for (ib = 0; ib < 6; ib = ib + 1)
                for (ic = 0; ic < 4096; ic = ic + 409) begin
                    a = edge_v[ia]; b = edge_v[ib]; c = ic; @(negedge clk);
                end
        end
        // 随机
        repeat (8) begin
            write_d($urandom);
            repeat (n_rand / 8) begin a = $urandom; b = $urandom; c = $urandom; @(negedge clk); end
        end
        drive_en = 1'b0;
        repeat (LATENCY + 4) @(negedge clk);
        $display("checked %0d, failed %0d, max error %.3f LSB", n_check, n_fail, max_err);
        if (n_fail == 0 && n_check > 0) $display(" TEST PASSED"); else $display(" TEST FAILED");
        $finish;
    end
`ifdef SDF_FILE
    initial $sdf_annotate(`SDF_FILE, dut, , "sdf_annotate.log", "MAXIMUM");
`endif
`ifdef FSDB
    initial begin $fsdbDumpfile("tb_function_gen.fsdb"); $fsdbDumpvars(0, tb_function_gen); end
`endif
endmodule
