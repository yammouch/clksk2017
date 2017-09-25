module lvds1 (
 input        RSTXS,
 input        CLKS,
 input        RSTXF,
 input        CLKF,
 input        RSTXP,
 input        CLKP,
 input  [1:0] DIN,

 output [1:0] DOUT,
 output [7:0] ERR_CNT
);

wire phy_init, dopushp, dopullp;
wire [63:0] doutp;
parallel_send i_parallel_send (
 .RSTX     (RSTXP),
 .CLK      (CLKP),
 .CLR      (1'b0),

 .PHY_INIT (phy_init),
 .DOUT     (doutp),
 .DOPUSH   (dopushp),
 .DOPULL   (dopullp)
);

wire [63:0] doutf;
fifo_async #(.BW(64)) i_fifo_send (
 .RSTX_DI (RSTXP),
 .CLKDI   (CLKP),
 .DIN     (doutp),
 .DIPUSH  (dopushp),
 .DIPULL  (dopullp),

 .RSTX_DO (RSTXF),
 .CLKDO   (CLKF),
 .DOUT    (doutf),
 .DOPUSH  (),
 .DOPULL  (1'b1)
);

serial_send i_serial_send (
 .RSTXF (RSTXF),
 .CLKF  (CLKF),
 .DIN   (doutf),

 .RSTXS (RSTXS),
 .CLKS  (CLKS),
 .DOUT  (DOUT)
);

wire [63:0] dinf;
serial_recv i_serial_recv (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .PHY_INIT (phy_init),
 .DIN      (DIN),
 .DOUT     (dinf),
 .CLKF     (CLKF)
);

wire [63:0] dina;
wire dipusha;
fifo_async #(.BW(64)) i_fifo_recv (
 .RSTX_DI (RSTXF),
 .CLKDI   (CLKF),
 .DIN     (dinf),
 .DIPUSH  (1'b1),
 .DIPULL  (),

 .RSTX_DO (RSTXP),
 .CLKDO   (CLKP),
 .DOUT    (dina),
 .DOPUSH  (dipusha),
 .DOPULL  (1'b1)
);

wire [63:0] dinp,
wire dipushp, aligned;
word_align i_word_align (
 .RSTX     (RSTXP),
 .CLK      (CLKP),
 .PHY_INIT (phy_init),
 .DIN      (dina),
 .DIPUSH   (dipusha),

 .DOUT     (dinp),
 .DOPUSH   (dipushp),
 .ALIGNED  (aligned)
);

parallel_recv i_parallel_recv (
 .RSTX    (RSTXP),
 .CLK     (CLKP),
 .INIT    (phy_init),
 .DIN     (dinp),
 .DIPUSH  (dipushp),
 .ALIGNED (aligned),
 .CLR     (1'b0),
 .ERR_CNT (ERR_CNT)
);

endmodule
