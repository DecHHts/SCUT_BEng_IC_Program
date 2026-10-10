module mul12 (
    input  wire        clk,
    input  wire [11:0] a,
    input  wire [11:0] b,
    output reg  [23:0] p
);
    // 部分积 pp[i] = b[i] ? a : 0, 权重 2^i
    wire [11:0] pp [0:11];
    genvar i;
    generate for (i = 0; i < 12; i = i + 1) begin : g_pp
        assign pp[i] = a & {12{b[i]}};
    end endgenerate
    // r1: 12 -> 6
    reg [13:0] s1 [0:5];
    // r2: 6 -> 3
    reg [16:0] s2 [0:2];
    // r3: 3 -> 2
    reg [20:0] s3a; reg [15:0] s3b;
    integer k;
    always @(posedge clk) begin
        for (k = 0; k < 6; k = k + 1)
            s1[k] <= {2'b0, pp[2*k]} + {1'b0, pp[2*k+1], 1'b0};
        for (k = 0; k < 3; k = k + 1)
            s2[k] <= {3'b0, s1[2*k]} + {1'b0, s1[2*k+1], 2'b0};
        s3a <= {4'b0, s2[0]} + {s2[1], 4'b0};          // 权重 2^0
        s3b <= s2[2][15:0];                            // 权重 2^8
        p   <= {3'b0, s3a} + {s3b, 8'b0};
    end
endmodule
