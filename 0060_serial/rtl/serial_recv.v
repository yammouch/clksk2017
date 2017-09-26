module serial_recv (
 input             RSTXS,
 input             CLKS,
 input             CLKF,
 input             PHY_INIT,
 input      [ 1:0] DIN,
 output reg [63:0] DOUT
);

wire din_se, din_delay;

IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("LVDS_33")) i_ibufds (
 .I(DIN[0]), .IB(DIN[1]), .O(din_se) );

IODELAY2 i_iodelay2(
 .IDATAIN  (din_se),
 .T        (1'b0),
 .ODATAIN  (1'b0),
 .IOCLK1   (1'b0),
 .INC      (1'b0),
 .CE       (1'b1),
 .CAL      (PHY_INIT),
 .IOCLK0   (CLKS),
 .CLK      (CLKF),
 .RST      (~RSTXS),
 .DATAOUT  (din_delay),
 .DATAOUT2 (),
 .TOUT     (),
 .DOUT     (),
 .BUSY     ()
);

wire [1:0] ddr;

IDDR2 i_iddr2(
 .D(din_delay),
 .C0 (CLKS),
 .C1 (~CLKS),
 .CE (1'b1),
 .R  (~RSTXS),
 .S  (1'b0),
 .Q0 (ddr[1]),
 .Q1 (ddr[0])
);

reg [63:0] shift;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) shift <= 64'd0;
  else        shift <= {shift[61:0], ddr};

reg clkf_d1, clkf_d2;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) {clkf_d2, clkf_d1} <= 2'b00;
  else        {clkf_d2, clkf_d1} <= {clkf_d1, CLKF};

always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS)                   DOUT <= 64'd0;
  else if (!clkf_d1 && clkf_d2) DOUT <= shift;

endmodule
