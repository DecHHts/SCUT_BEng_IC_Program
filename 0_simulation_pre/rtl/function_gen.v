module function_gen (
    input  wire        clk,
    input  wire [11:0] a,
    input  wire [11:0] b,
    input  wire [11:0] c,
    input  wire        e,
    output wire [12:0] y
);
    reg [11:0] a0, b0, c0;
    always @(posedge clk) begin a0 <= a; b0 <= b; c0 <= c; end
    wire [11:0] d;
    d_rx u_d_rx (.clk(clk), .e(e), .d(d));
    wire [23:0] p4;
    mul12 u_mul (.clk(clk), .a(a0), .b(b0), .p(p4));
    reg [12:0] div1, div2, div3, div4;
    always @(posedge clk) begin
        div1 <= {1'b0, a0} + {1'b0, d};
        div2 <= (div1 == 13'd0) ? 13'd1 : div1;
        div3 <= div2;  div4 <= div3;
    end
    wire [14:0] mag4; wire neg4;
    cos_lut u_cos (.clk(clk), .c(c0), .mag(mag4), .neg(neg4));
    div_acc u_div_acc (.clk(clk), .p(p4), .div(div4), .mag(mag4), .neg(neg4), .y(y));
endmodule
