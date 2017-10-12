wire       CLK;
reg        BTN_1;
reg        BTN_2;
reg        BTN_3;
wire [1:0] lvds;

reg [255:0] lvds_p;
reg [255:0] lvds_n;
reg [  7:0] tap_sel;

tb_clk_gen fg(.clk(CLK));

always @(dut.i_pll_ctrl.CLKS) begin
  lvds_p <= {lvds_p[254:0], lvds[0]};
  lvds_n <= {lvds_n[254:0], lvds[1]};
end

lvds_test dut (
 .CLK       (CLK),
 .BTN_1     (BTN_1),
 .BTN_2     (BTN_2),
 .BTN_3     (BTN_3),
 .DIN       ({lvds_n[tap_sel], lvds_p[tap_sel]}),
 .DIGIT_SEL (),
 .DIGIT     (),
 .DOUT      (lvds),
 .DIV32     ()
);
