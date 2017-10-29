module serial_recv (
 input             RSTXS,
 input             CLKS,
 input             CLKSS,
 input             CLKF,
 input             PHY_INIT,
 input             SERDESSTROBE,
 input      [ 1:0] DIN,
 output reg [63:0] DOUT
);

wire din_se, din_delay;

IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("LVDS_33")) i_ibufds (
 .I(DIN[0]), .IB(DIN[1]), .O(din_se) );

IODELAY2 #(.DATA_RATE("DDR")) i_iodelay2(
 .IDATAIN  (din_se),
 .T        (1'b1),
 .ODATAIN  (1'b0),
 .IOCLK1   (1'b0),
 .INC      (1'b0),
 .CE       (1'b0),
 .CAL      (PHY_INIT),
 .IOCLK0   (CLKSS),
 .CLK      (CLKF),
 .RST      (~RSTXS),
 .DATAOUT  (din_delay),
 .DATAOUT2 (),
 .TOUT     (),
 .DOUT     (),
 .BUSY     ()
);

wire [3:0] ddr;

ISERDES2 #(
 .DATA_RATE      ("SDR"),
 .DATA_WIDTH     (4),
 .BITSLIP_ENABLE ("FALSE"),
 .SERDES_MODE    ("NONE"),
 .INTERFACE_TYPE ("RETIMED")
) i_iserdes2 (
 .CLK0      (CLKSS),
 .CLK1      (1'b0),
 .CLKDIV    (CLKS),
 .CE0       (1'b1),
 .BITSLIP   (1'b0),
 .D         (din_delay),
 .RST       (!RSTXS),
 .IOCE      (SERDESSTROBE),
 .SHIFTIN   (1'b0),
 .CFB0      (),
 .CFB1      (),
 .DFB       (),
 .SHIFTOUT  (),
 .FABRICOUT (),
 .Q4        (ddr[0]),
 .Q3        (ddr[1]),
 .Q2        (ddr[2]),
 .Q1        (ddr[3]),
 .VALID     (),
 .INCDEC    ()
);

reg [63:0] shift;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) shift <= 64'd0;
  else        shift <= {shift[59:0], ddr};

reg clkf_d1, clkf_d2;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) {clkf_d2, clkf_d1} <= 2'b00;
  else        {clkf_d2, clkf_d1} <= {clkf_d1, CLKF};

always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS)                   DOUT <= 64'd0;
  else if (!clkf_d1 && clkf_d2) DOUT <= shift;

endmodule
