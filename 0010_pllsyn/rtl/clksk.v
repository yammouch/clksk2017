module clksk(
 input  clk_in,
 input  rst,
 output pll_clk_out
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

ODDR2 clkg_pll_clk(.CE(1'b1), .R(1'b0), .S(1'b0),
 .D0(1'b1), .D1(1'b0), .C0(CLKXTAL), .C1(~CLKXTAL), .Q(pll_clk_out));

endmodule
