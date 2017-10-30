module lvds1 (
 input         RSTXS,
 input         CLKS,
 input         RSTXF,
 input         CLKF,
 input         CLKF_DATA,
 input         CLR,
 input         INV,
 input  [ 1:0] PATTERN,
 input  [ 1:0] DIN,

 output [ 1:0] DOUT,
 output [63:0] ERR_CNT,
 output [57:0] RECV_CNT
);

reg rstxf_d1, rstxf_d2;
always @(posedge CLKF or negedge RSTXF)
  if (!RSTXF) {rstxf_d2, rstxf_d1} <= 2'b00;
  else        {rstxf_d2, rstxf_d1} <= {rstxf_d1, RSTXF};
wire clr_int = CLR || !rstxf_d2;

wire phy_init, dopushp, dopullp;
wire [31:0] doutp;
parallel_send i_parallel_send (
 .RSTX     (RSTXF),
 .CLK      (CLKF),
 .CLR      (clr_int),

 .PHY_INIT (phy_init),
 .DOUT     (doutp),
 .DOPUSH   (dopushp),
 .DOPULL   (dopullp)
);

serial_send i_serial_send (
 .RSTXF     (RSTXF),
 .CLKF      (CLKF),
 .CLKF_DATA (CLKF_DATA),
 .DIN       ( PATTERN == 2'd0 ? doutp
            : PATTERN == 2'd1 ? 32'hAAAA_AAAA
            : PATTERN == 2'd2 ? 32'd0
            :                   32'd0 ),
 .RSTXS     (RSTXS),
 .CLKS      (CLKS),
 .DOUT      (DOUT)
);

wire [31:0] dina;
serial_recv i_serial_recv (
 .RSTXS     (RSTXS),
 .CLKS      (CLKS),
 .PHY_INIT  (phy_init),
 .DIN       (DIN),
 .DOUT      (dina),
 .CLKF      (CLKF),
 .CLKF_DATA (CLKF_DATA)
);

wire [31:0] dinp;
wire dipushp, aligned;
word_align i_word_align (
 .RSTX     (RSTXF),
 .CLK      (CLKF),
 .PHY_INIT (phy_init),
 .DIN      (INV ? ~dina : dina),
 .DIPUSH   (1'b1),

 .DOUT     (dinp),
 .DOPUSH   (dipushp),
 .ALIGNED  (aligned)
);

parallel_recv i_parallel_recv (
 .RSTX     (RSTXF),
 .CLK      (CLKF),
 .INIT     (phy_init),
 .DIN      (dinp),
 .DIPUSH   (dipushp),
 .ALIGNED  (aligned),
 .CLR      (clr_int),
 .ERR_CNT  (ERR_CNT),
 .RECV_CNT (RECV_CNT)
);

endmodule
