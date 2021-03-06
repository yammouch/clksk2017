wire       CLK;
reg        BTN_1;
reg        BTN_2;
reg        BTN_3;
wire [1:0] lvds;

reg [255:0] lvds_p;
reg [255:0] lvds_n;
reg [  7:0] tap_sel;

tb_clk_gen fg(.clk(CLK));

always @(negedge dut.i_pll_ctrl.CLKSS) begin
  lvds_p <= {lvds_p[254:0], lvds[0]};
  lvds_n <= {lvds_n[254:0], lvds[1]};
end

lvds_test dut (
 .CLK         (CLK),
 .BTN_1       (BTN_1),
 .BTN_2       (BTN_2),
 .BTN_3       (BTN_3),
 .DIGIT_SEL   (),
 .DIGIT       (),

 .SEL_RX_A    (),
 .SEL_RX_B    (),
 .SEL_TX_A    (),
 .SEL_TX_B    (),
 .PD_BIAS_A   (),
 .PD_BIAS_B   (),
 .IDSET_A     (),
 .IDSET_B     (),
 .HYST_A      (),
 .HYST_B      (),
 .DRV_STR_A   (),
 .DRV_STR_B   (),
 .SR_A        (),
 .SR_B        (),
 .PUDEN_TX_A  (),
 .PUDEN_TX_B  (),
 .PUDEN_RX_A  (),
 .PUDEN_RX_B  (),
 .PUDPOL_TX_A (),
 .PUDPOL_TX_B (),
 .PUDPOL_RX_A (),
 .PUDPOL_RX_B (),
 .TEST_A      (),
 .TEST_B      (),
 .POR         (),

 .DIN         ({lvds_n[tap_sel], lvds_p[tap_sel]}),
 .DOUT        (lvds)
);
