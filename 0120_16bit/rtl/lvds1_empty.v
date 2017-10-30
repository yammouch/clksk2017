module lvds1_empty (
 input         RSTXS,
 input         CLKS,
 input         RSTXF,
 input         CLKF,
 input         RSTXP,
 input         CLKP,
 input         CLR,
 input         INV,
 input  [ 1:0] PATTERN,
 input  [ 1:0] DIN,

 output [ 1:0] DOUT,
 output [63:0] ERR_CNT,
 output [57:0] RECV_CNT
);

assign DOUT     = 2'd0;
assign ERR_CNT  = 64'd0;
assign RECV_CNT = 58'd0;

endmodule
