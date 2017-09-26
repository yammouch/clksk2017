reg        RSTX;
wire       CLK;
reg        BTN_UP;
reg        BTN_DN;
wire [1:0] lvds;

tb_clk_gen fg(.clk(CLK));

pll_test dut (
 .RSTX      (RSTX),
 .CLK       (CLK),
 .BTN_UP    (BTN_UP),
 .BTN_DN    (BTN_DN),
 .DIN       (lvds),
 .DOUT      (lvds),
 .DIV32     (),
 .PLL_LOCK  (),
 .DIGIT_SEL (),
 .DIGIT     ()
);
