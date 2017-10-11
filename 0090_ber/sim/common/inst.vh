wire       CLK;
reg        BTN_1;
reg        BTN_2;
reg        BTN_3;
wire [1:0] lvds;

tb_clk_gen fg(.clk(CLK));

lvds_test dut (
 .CLK       (CLK),
 .BTN_1     (BTN_1),
 .BTN_2     (BTN_2),
 .BTN_3     (BTN_3),
 .DIN       (lvds),
 .DIGIT_SEL (),
 .DIGIT     (),
 .DOUT      (lvds),
 .DIV32     ()
);
