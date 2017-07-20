`timescale 1ps/1ps

module t000;

wire pll_clk;
wire clk_in;
reg  rst;

tb_clk_gen clk_gen(.CLK(clk_in));

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

initial begin
  rst = 1'b1;

  #100_000; // 0.1us
  clk_gen.en = 1'b1;
  repeat (4) @(negedge clk_in);
  rst = 1'b0;
  #1e9; // 1ms
  $finish;
end

endmodule
