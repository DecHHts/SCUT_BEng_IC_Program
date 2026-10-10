module acc_step #(parameter J = 0) (
    input  wire [16:0] s_i,
    input  wire [16:0] c_i,
    input  wire [14:0] mag,
    input  wire        neg,
    input  wire        qb,
    output wire [16:0] s_o,
    output wire [16:0] c_o
);
    wire [16:0] term;
    generate
        if (J >= 10) begin : g_shl  assign term = {2'b0, mag} << (J - 10);  end
        else         begin : g_shr  assign term = {2'b0, mag} >> (10 - J);  end
    endgenerate
    wire        sub = qb & neg;
    wire [16:0] t   = qb ? (term ^ {17{neg}}) : 17'd0;
    wire [16:0] maj = (s_i & c_i) | (s_i & t) | (c_i & t);
    assign s_o = s_i ^ c_i ^ t;
    assign c_o = {maj[15:0], sub};
endmodule
