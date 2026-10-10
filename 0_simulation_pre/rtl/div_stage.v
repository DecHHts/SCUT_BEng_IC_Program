module div_stage #(parameter J = 0) (
    input  wire        clk,
    input  wire [12:0] r_i,
    input  wire [11:0] pl_i,
    input  wire [12:0] d_i,
    input  wire [14:0] m_i,
    input  wire        n_i,
    input  wire        qb_i,
    input  wire [16:0] s_i,
    input  wire [16:0] c_i,
    output reg  [12:0] r_o,
    output reg  [11:0] pl_o,
    output reg  [12:0] d_o,
    output reg  [14:0] m_o,
    output reg         n_o,
    output reg         qb_o,
    output reg  [16:0] s_o,
    output reg  [16:0] c_o
);
    wire        nb = pl_i[J];
    wire [13:0] x  = {r_i, nb};
    wire        ge = (x >= {1'b0, d_i});
    wire [12:0] df = x[12:0] - d_i;
    wire [16:0] s_w, c_w;
    acc_step #(.J(J + 1)) u_acc (.s_i(s_i), .c_i(c_i), .mag(m_i), .neg(n_i), .qb(qb_i), .s_o(s_w), .c_o(c_w));
    always @(posedge clk) begin
        r_o  <= ge ? df : x[12:0];
        qb_o <= ge;
        pl_o <= pl_i;  d_o <= d_i;  m_o <= m_i;  n_o <= n_i;
        s_o  <= s_w;   c_o <= c_w;
    end
endmodule
