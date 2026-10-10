module cos_lut (
    input  wire        clk,
    input  wire [11:0] c,
    output reg  [14:0] mag,
    output reg         neg
);
    // r1: 象限折叠
    reg [9:0] addr1; reg zero1, neg1;
    always @(posedge clk) begin
        addr1 <= c[10] ? (10'd0 - c[9:0]) : c[9:0];   // 1024 - idx (模 1024)
        zero1 <= c[10] & (c[9:0] == 10'd0);           // 1024 - 0 = 1024, 表外, 值为 0
        neg1  <= c[11] ^ c[10];
    end
    // r2: 查表
    reg [14:0] rom;
    always @(*) begin
        case (addr1)
`include "cos_rom.vh"
            default: rom = 15'd0;
        endcase
    end
    reg [14:0] mag2; reg zero2, neg2;
    always @(posedge clk) begin mag2 <= rom; zero2 <= zero1; neg2 <= neg1; end
    // r3, r4
    reg [14:0] mag3; reg neg3;
    always @(posedge clk) begin
        mag3 <= zero2 ? 15'd0 : mag2;  neg3 <= neg2;
        mag  <= mag3;                  neg  <= neg3;
    end
endmodule
