reg  RSTX;
wire CLK;
reg  BTN_UP;
reg  BTN_DN;

tb_clk_gen fg(.clk(CLK));

pll_test dut (
 .RSTX      (RSTX),
 .CLK       (CLK),
 .BTN_UP    (BTN_UP),
 .BTN_DN    (BTN_DN),
 .DIV32     (),
 .PLL_LOCK  (),
 .DIGIT_SEL (),
 .DIGIT     ()
);
