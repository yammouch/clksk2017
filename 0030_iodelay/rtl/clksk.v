module clksk(
 input             clk_in,
 input             rst,
 input             iodelay_rst,
 input             iodelay_cal,
 input             dinp,
 input             dinn,
 output reg [15:0] dout,
 output            pll_clk_out_p,
 output            pll_clk_out_n,
 output            iodelay_busy
);

wire pll_clk;

PLL_ADV #(
 .CLKIN1_PERIOD (50.0),
 .CLKFBOUT_MULT (20)
) pll0 (
 .CLKIN1     (clk_in),
 .CLKIN2     (1'b0),
 .CLKFBIN    (pll_clk),
 .RST        (rst),
 .CLKINSEL   (1'b1), // to use CLKIN1
 .DADDR      (5'd0),
 .DI         (16'd0),
 .DWE        (1'b0),
 .DEN        (1'b0),
 .DCLK       (1'b0),
 .REL        (1'b0),
 .CLKOUT0    (pll_clk),
 .CLKOUT1    (),
 .CLKOUT2    (),
 .CLKOUT3    (),
 .CLKOUT4    (),
 .CLKOUT5    (),
 .CLKFBOUT   (),
 .CLKOUTDCM0 (),
 .CLKOUTDCM1 (),
 .CLKOUTDCM2 (),
 .CLKOUTDCM3 (),
 .CLKOUTDCM4 (),
 .CLKOUTDCM5 (),
 .CLKFBDCM   (),
 .LOCKED     (),
 .DO         (),
 .DRDY       ()
);

wire din;

IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("LVDS_33")) ibuf (
 .I(dinp), .IB(dinn), .O(din));

wire dout_p2;

IODELAY2 #(
 .IDELAY_TYPE ("VARIABLE_FROM_ZERO"),
 .DATA_RATE   ("DDR")
) delay (
 .IDATAIN  (din),
 .T        (1'b1),
 .ODATAIN  (1'b0),
 .CAL      (iodelay_cal),
 .IOCLK0   (pll_clk),
 .IOCLK1   (1'b0),
 .CLK      (clk_in),
 .INC      (1'b0),
 .CE       (1'b0),
 .RST      (iodelay_rst),
 .BUSY     (iodelay_busy),
 .DATAOUT  (),
 .DATAOUT2 (dout_p2),
 .TOUT     (),
 .DOUT     ()
);

reg [15:0] dout_p1;
always @(posedge pll_clk or posedge rst)
  if (rst) dout_p1 <= 16'd0;
  else     dout_p1 <= {dout_p1[14:0], dout_p2};
always @(posedge clk_in or posedge rst)
  if (rst) dout <= 16'd0;
  else     dout <= dout_p1;

wire pll_clk_out;

ODDR2 clkg_pll_clk(.CE(1'b1), .R(1'b0), .S(1'b0),
 .D0(1'b1), .D1(1'b0), .C0(pll_clk), .C1(~pll_clk), .Q(pll_clk_out));

OBUFDS #(.IOSTANDARD("LVDS_33")) diff_out (
 .I(pll_clk_out), .O(pll_clk_out_p), .OB(pll_clk_out_n));

endmodule
