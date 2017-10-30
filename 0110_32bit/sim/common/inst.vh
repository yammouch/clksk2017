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

wire [1:0] nta_lvds, ntb_lvds, eta_lvds, etb_lvds, st_lvds, scb_lvds;

lvds_test dut (
 .CLK            (CLK),
 .BTN_1          (BTN_1),
 .BTN_2          (BTN_2),
 .BTN_3          (BTN_3),
 .DIGIT_SEL      (),
 .DIGIT          (),
 //.DIV32          (),

/*
 .NT_SEL_RX_A    (),
 .NT_SEL_RX_B    (),
 .NT_SEL_TX_A    (),
 .NT_SEL_TX_B    (),
 .NT_PD_BIAS_A   (),
 .NT_PD_BIAS_B   (),
 .NT_IDSET_A     (),
 .NT_IDSET_B     (),
 .NT_HYST_A      (),
 .NT_HYST_B      (),
 .NT_DRV_STR_A   (),
 .NT_DRV_STR_B   (),
 .NT_SR_A        (),
 .NT_SR_B        (),
 .NT_PUDEN_TX_A  (),
 .NT_PUDEN_TX_B  (),
 .NT_PUDEN_RX_A  (),
 .NT_PUDEN_RX_B  (),
 .NT_PUDPOL_TX_A (),
 .NT_PUDPOL_TX_B (),
 .NT_PUDPOL_RX_A (),
 .NT_PUDPOL_RX_B (),
 .NT_TEST_A      (),
 .NT_TEST_B      (),
 .NT_POR         (),
 .NTA_DIN        (nta_lvds),
 .NTA_DOUT       (nta_lvds),
 .NTB_DIN        (ntb_lvds),
 .NTB_DOUT       (ntb_lvds),

 .ET_SEL_RX_A    (),
 .ET_SEL_RX_B    (),
 .ET_SEL_TX_A    (),
 .ET_SEL_TX_B    (),
 .ET_PD_BIAS_A   (),
 .ET_PD_BIAS_B   (),
 .ET_IDSET_A     (),
 .ET_IDSET_B     (),
 .ET_HYST_A      (),
 .ET_HYST_B      (),
 .ET_DRV_STR_A   (),
 .ET_DRV_STR_B   (),
 .ET_SR_A        (),
 .ET_SR_B        (),
 .ET_PUDEN_TX_A  (),
 .ET_PUDEN_TX_B  (),
 .ET_PUDEN_RX_A  (),
 .ET_PUDEN_RX_B  (),
 .ET_PUDPOL_TX_A (),
 .ET_PUDPOL_TX_B (),
 .ET_PUDPOL_RX_A (),
 .ET_PUDPOL_RX_B (),
 .ET_TEST_A      (),
 .ET_TEST_B      (),
 .ET_POR         (),
 .ETA_DIN        (eta_lvds),
 .ETA_DOUT       (eta_lvds),
 .ETB_DIN        (etb_lvds),
 .ETB_DOUT       (etb_lvds),

 .ST_SEL_RX_A    (),
 .ST_SEL_RX_B    (),
 .ST_SEL_TX_A    (),
 .ST_SEL_TX_B    (),
 .ST_PD_BIAS_A   (),
 .ST_PD_BIAS_B   (),
 .ST_IDSET_A     (),
 .ST_IDSET_B     (),
 .ST_HYST_A      (),
 .ST_HYST_B      (),
 .ST_DRV_STR_A   (),
 .ST_DRV_STR_B   (),
 .ST_SR_A        (),
 .ST_SR_B        (),
 .ST_PUDEN_TX_A  (),
 .ST_PUDEN_TX_B  (),
 .ST_PUDEN_RX_A  (),
 .ST_PUDEN_RX_B  (),
 .ST_PUDPOL_TX_A (),
 .ST_PUDPOL_TX_B (),
 .ST_PUDPOL_RX_A (),
 .ST_PUDPOL_RX_B (),
 .ST_TEST_A      (),
 .ST_TEST_B      (),
 .ST_POR         (),
 .ST_DIN         (st_lvds),
 .ST_DOUT        (st_lvds),
*/

 .SC_SEL_RX_A    (),
 .SC_SEL_RX_B    (),
 .SC_SEL_TX_A    (),
 .SC_SEL_TX_B    (),
 .SC_PD_BIAS_A   (),
 .SC_PD_BIAS_B   (),
 .SC_IDSET_A     (),
 .SC_IDSET_B     (),
 .SC_HYST_A      (),
 .SC_HYST_B      (),
 .SC_DRV_STR_A   (),
 .SC_DRV_STR_B   (),
 .SC_SR_A        (),
 .SC_SR_B        (),
 .SC_PUDEN_TX_A  (),
 .SC_PUDEN_TX_B  (),
 .SC_PUDEN_RX_A  (),
 .SC_PUDEN_RX_B  (),
 .SC_PUDPOL_TX_A (),
 .SC_PUDPOL_TX_B (),
 .SC_PUDPOL_RX_A (),
 .SC_PUDPOL_RX_B (),
 .SC_TEST_A      (),
 .SC_TEST_B      (),
 .SC_POR         (),
 .SCA_DIN        ({lvds_n[tap_sel], lvds_p[tap_sel]}),
 .SCA_DOUT       (lvds)/*,
 .SCB_DIN        (scb_lvds),
 .SCB_DOUT       (scb_lvds)
*/
);
