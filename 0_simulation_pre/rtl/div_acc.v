module div_acc (
    input  wire        clk,
    input  wire [23:0] p,
    input  wire [12:0] div,
    input  wire [14:0] mag,
    input  wire        neg,
    output wire [12:0] y
);
    wire [12:0] r  [0:12];
    wire [11:0] pl [0:12];
    wire [12:0] d  [0:12];
    wire [14:0] m  [0:12];
    wire        n  [0:12];
    wire        qb [0:12];
    wire [16:0] s  [0:12];
    wire [16:0] c  [0:12];
    assign r[0] = {1'b0, p[23:12]};  assign pl[0] = p[11:0];  assign d[0] = div;
    assign m[0] = mag;  assign n[0] = neg;  assign qb[0] = 1'b0;
    assign s[0] = 17'd8;  assign c[0] = 17'd0;          // 初值 8 = 0.5 LSB, 实现四舍五入
    genvar k;
    generate for (k = 0; k < 12; k = k + 1) begin : g_stage
        div_stage #(.J(11 - k)) u_stage (
            .clk(clk), .r_i(r[k]), .pl_i(pl[k]), .d_i(d[k]), .m_i(m[k]), .n_i(n[k]), .qb_i(qb[k]), .s_i(s[k]), .c_i(c[k]),
            .r_o(r[k+1]), .pl_o(pl[k+1]), .d_o(d[k+1]), .m_o(m[k+1]), .n_o(n[k+1]), .qb_o(qb[k+1]), .s_o(s[k+1]), .c_o(c[k+1]));
    end endgenerate
    // r17: 最后一位商 (q0) 的加数, 再做一次进位传播加法
    wire [16:0] s_w, c_w;
    acc_step #(.J(0)) u_last (.s_i(s[12]), .c_i(c[12]), .mag(m[12]), .neg(n[12]), .qb(qb[12]), .s_o(s_w), .c_o(c_w));
    reg [16:0] acc;
    always @(posedge clk) acc <= s_w + c_w;
    assign y = acc[16:4];
endmodule
