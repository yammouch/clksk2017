module clksk(
 input  clk_in,
 input  rst,
 output pll_clk
);

wire pll_clk;

PLL_ADV #(
 .CLKIN1_PERIOD (100.0),
 .CLKFBOUT_MULT (40)
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

endmodule
