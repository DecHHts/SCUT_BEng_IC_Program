module d_rx (
    input  wire        clk,
    input  wire        e,
    output reg  [11:0] d
);
    reg        e0;
    reg [11:0] tk;      // 令牌: 某一位为 1 表示正在接收, 位置表示收到第几位
    reg [10:0] sr;      // 已收到的数据位
    wire start = e0 & ~(|tk);
    always @(posedge clk) begin
        e0 <= e;
        tk <= {tk[10:0], start};
        sr <= {sr[9:0], e0};
        if (tk[11]) d <= {sr, e0};
    end
endmodule
