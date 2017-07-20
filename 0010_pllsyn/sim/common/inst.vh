reg  rst;
wire clk_in;

tb_clk_gen clk_gen(.CLK(clk_in));

clksk dut(
 .clk_in  (clk_in),
 .rst     (rst),
 .pll_clk ()
);
