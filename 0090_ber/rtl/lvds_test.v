module lvds_test (
 input        CLK,
 input        RSTX,
 input        BTN_1,
 input        BTN_2,
 input        BTN_3,
 output [3:0] DIGIT_SEL,
 output [7:0] DIGIT,
 //output       DIV32,

/*
 output       NT_SEL_RX_A,
 output       NT_SEL_RX_B,
 output       NT_SEL_TX_A,
 output       NT_SEL_TX_B,
 output       NT_PD_BIAS_A,
 output       NT_PD_BIAS_B,
 output [1:0] NT_IDSET_A,
 output [1:0] NT_IDSET_B,
 output       NT_HYST_A,
 output       NT_HYST_B,
 output [1:0] NT_DRV_STR_A,
 output [1:0] NT_DRV_STR_B,
 output       NT_SR_A,
 output       NT_SR_B,
 output       NT_PUDEN_TX_A,
 output       NT_PUDEN_TX_B,
 output       NT_PUDEN_RX_A,
 output       NT_PUDEN_RX_B,
 output       NT_PUDPOL_TX_A,
 output       NT_PUDPOL_TX_B,
 output       NT_PUDPOL_RX_A,
 output       NT_PUDPOL_RX_B,
 output [1:0] NT_TEST_A,
 output [1:0] NT_TEST_B,
 output       NT_POR,
*/
 //input  [1:0] NTA_DIN,
 //output [1:0] NTA_DOUT,
 //input  [1:0] NTB_DIN,
 //output [1:0] NTB_DOUT,

/*
 output       ET_SEL_RX_A,
 output       ET_SEL_RX_B,
 output       ET_SEL_TX_A,
 output       ET_SEL_TX_B,
 output       ET_PD_BIAS_A,
 output       ET_PD_BIAS_B,
 output [1:0] ET_IDSET_A,
 output [1:0] ET_IDSET_B,
 output       ET_HYST_A,
 output       ET_HYST_B,
 output [1:0] ET_DRV_STR_A,
 output [1:0] ET_DRV_STR_B,
 output       ET_SR_A,
 output       ET_SR_B,
 output       ET_PUDEN_TX_A,
 output       ET_PUDEN_TX_B,
 output       ET_PUDEN_RX_A,
 output       ET_PUDEN_RX_B,
 output       ET_PUDPOL_TX_A,
 output       ET_PUDPOL_TX_B,
 output       ET_PUDPOL_RX_A,
 output       ET_PUDPOL_RX_B,
 output [1:0] ET_TEST_A,
 output [1:0] ET_TEST_B,
 output       ET_POR,
*/
 //input  [1:0] ETA_DIN,
 //output [1:0] ETA_DOUT,
 //input  [1:0] ETB_DIN,
 //output [1:0] ETB_DOUT,

/*
 output       ST_SEL_RX_A,
 output       ST_SEL_RX_B,
 output       ST_SEL_TX_A,
 output       ST_SEL_TX_B,
 output       ST_PD_BIAS_A,
 output       ST_PD_BIAS_B,
 output [1:0] ST_IDSET_A,
 output [1:0] ST_IDSET_B,
 output       ST_HYST_A,
 output       ST_HYST_B,
 output [1:0] ST_DRV_STR_A,
 output [1:0] ST_DRV_STR_B,
 output       ST_SR_A,
 output       ST_SR_B,
 output       ST_PUDEN_TX_A,
 output       ST_PUDEN_TX_B,
 output       ST_PUDEN_RX_A,
 output       ST_PUDEN_RX_B,
 output       ST_PUDPOL_TX_A,
 output       ST_PUDPOL_TX_B,
 output       ST_PUDPOL_RX_A,
 output       ST_PUDPOL_RX_B,
 output [1:0] ST_TEST_A,
 output [1:0] ST_TEST_B,
 output       ST_POR,
*/
 //input  [1:0] ST_DIN,
 //output [1:0] ST_DOUT,

 output       SC_SEL_RX_A,
 output       SC_SEL_RX_B,
 output       SC_SEL_TX_A,
 output       SC_SEL_TX_B,
 output       SC_PD_BIAS_A,
 output       SC_PD_BIAS_B,
 output [1:0] SC_IDSET_A,
 output [1:0] SC_IDSET_B,
 output       SC_HYST_A,
 output       SC_HYST_B,
 output [1:0] SC_DRV_STR_A,
 output [1:0] SC_DRV_STR_B,
 output       SC_SR_A,
 output       SC_SR_B,
 output       SC_PUDEN_TX_A,
 output       SC_PUDEN_TX_B,
 output       SC_PUDEN_RX_A,
 output       SC_PUDEN_RX_B,
 output       SC_PUDPOL_TX_A,
 output       SC_PUDPOL_TX_B,
 output       SC_PUDPOL_RX_A,
 output       SC_PUDPOL_RX_B,
 output [1:0] SC_TEST_A,
 output [1:0] SC_TEST_B,
 output       SC_POR,
 input  [1:0] SCA_DIN,
 output [1:0] SCA_DOUT//,
 //input  [1:0] SCB_DIN,
 //output [1:0] SCB_DOUT
);

wire clk_ibufg, clk_bufg;
reg clk_div2;

IBUFG i_ibufg(.I(CLK), .O(clk_ibufg));
always @(posedge clk_ibufg) clk_div2 <= !clk_div2;
BUFG i_bufg(.I(clk_div2), .O(clk_bufg));

wire [7:0] pll_addr;
wire pll_chg;
wire rstxs, clks;
wire rstxf, clkf;
wire rstxo;

pll_ctrl i_pll_ctrl (
 .RSTX        (RSTX),
 .CLK         (clk_bufg),
 .CLK_PLL_SRC (clk_ibufg),
 .PLL_ADDR    (pll_addr),
 .PLL_CHG     (pll_chg),
 .RSTXS       (rstxs),
 .CLKS        (clks),
 .RSTXF       (rstxf),
 .CLKF        (clkf),
 .RSTXO       (rstxo)
);

//assign DIV32 = clkf;

wire [7:0] main_mode, sub_mode;
wire clr_seq;
button_ctrl i_button_ctrl (
 .RSTX     (rstxo),
 .CLK      (clk_bufg),
 .BTN_1    (BTN_1),
 .BTN_2    (BTN_2),
 .BTN_3    (BTN_3),
 .PLL_CHG  (pll_chg),
 .PLL_ADDR (pll_addr),
 .CNT1     (main_mode),
 .CNT2     (sub_mode),
 .CLR_SEQ  (clr_seq)
);

wire [57:0] recv_cnt;
wire [63:0] err_cnt;

handle_7seg i_handle_7seg (
 .RSTX      (rstxo),
 .CLK       (clk_bufg),
 .MAIN_MODE (main_mode),
 .SUB_MODE  (sub_mode),
 .RECV_CNT  (recv_cnt),
 .ERR_CNT   (err_cnt),
 .DIGIT_SEL (DIGIT_SEL),
 .DIGIT     (DIGIT)
);

wire [30:0] nt_ctrl, et_ctrl, st_ctrl, sc_ctrl;

stimulus i_stimulus (
 .RSTX      (rstxo),
 .CLK       (clk_bufg),
 .RSTXS     (rstxs),
 .CLKS      (clks),
 .RSTXF     (rstxf),
 .CLKF      (clkf),
 .CLR       (clr_seq),
 .MAIN_MODE (main_mode),
 .SUB_MODE  (sub_mode),
 .NT_CTRL   (nt_ctrl),
 .NTA_DIN   (2'd0), //(NTA_DIN),
 .NTA_DOUT  (),     //(NTA_DOUT),
 .NTB_DIN   (2'd0), //(NTB_DIN),
 .NTB_DOUT  (),     //(NTB_DOUT),
 .ET_CTRL   (et_ctrl),
 .ETA_DIN   (2'd0), //(ETA_DIN),
 .ETA_DOUT  (),     //(ETA_DOUT),
 .ETB_DIN   (2'd0), //(ETB_DIN),
 .ETB_DOUT  (),     //(ETB_DOUT),
 .ST_CTRL   (st_ctrl),
 .ST_DIN    (2'd0), //(ST_DIN),
 .ST_DOUT   (),     //(ST_DOUT),
 .SC_CTRL   (sc_ctrl),
 .SCA_DIN   (SCA_DIN),
 .SCA_DOUT  (SCA_DOUT),
 .SCB_DIN   (2'd0), //(SCB_DIN),
 .SCB_DOUT  (),     //(SCB_DOUT),
 .RECV_CNT  (recv_cnt),
 .ERR_CNT   (err_cnt)
);

/*
assign NT_SEL_RX_A    = nt_ctrl[   30];
assign NT_SEL_RX_B    = nt_ctrl[   29];
assign NT_SEL_TX_A    = nt_ctrl[   28];
assign NT_SEL_TX_B    = nt_ctrl[   27];
assign NT_PD_BIAS_A   = nt_ctrl[   26];
assign NT_PD_BIAS_B   = nt_ctrl[   25];
assign NT_IDSET_A     = nt_ctrl[24:23];
assign NT_IDSET_B     = nt_ctrl[22:21];
assign NT_HYST_A      = nt_ctrl[   20];
assign NT_HYST_B      = nt_ctrl[   19];
assign NT_DRV_STR_A   = nt_ctrl[18:17];
assign NT_DRV_STR_B   = nt_ctrl[16:15];
assign NT_SR_A        = nt_ctrl[   14];
assign NT_SR_B        = nt_ctrl[   13];
assign NT_PUDEN_TX_A  = nt_ctrl[   12];
assign NT_PUDEN_TX_B  = nt_ctrl[   11];
assign NT_PUDEN_RX_A  = nt_ctrl[   10];
assign NT_PUDEN_RX_B  = nt_ctrl[    9];
assign NT_PUDPOL_TX_A = nt_ctrl[    8];
assign NT_PUDPOL_TX_B = nt_ctrl[    7];
assign NT_PUDPOL_RX_A = nt_ctrl[    6];
assign NT_PUDPOL_RX_B = nt_ctrl[    5];
assign NT_TEST_A      = nt_ctrl[ 4: 3];
assign NT_TEST_B      = nt_ctrl[ 2: 1];
assign NT_POR         = nt_ctrl[    0];

assign ET_SEL_RX_A    = et_ctrl[   30];
assign ET_SEL_RX_B    = et_ctrl[   29];
assign ET_SEL_TX_A    = et_ctrl[   28];
assign ET_SEL_TX_B    = et_ctrl[   27];
assign ET_PD_BIAS_A   = et_ctrl[   26];
assign ET_PD_BIAS_B   = et_ctrl[   25];
assign ET_IDSET_A     = et_ctrl[24:23];
assign ET_IDSET_B     = et_ctrl[22:21];
assign ET_HYST_A      = et_ctrl[   20];
assign ET_HYST_B      = et_ctrl[   19];
assign ET_DRV_STR_A   = et_ctrl[18:17];
assign ET_DRV_STR_B   = et_ctrl[16:15];
assign ET_SR_A        = et_ctrl[   14];
assign ET_SR_B        = et_ctrl[   13];
assign ET_PUDEN_TX_A  = et_ctrl[   12];
assign ET_PUDEN_TX_B  = et_ctrl[   11];
assign ET_PUDEN_RX_A  = et_ctrl[   10];
assign ET_PUDEN_RX_B  = et_ctrl[    9];
assign ET_PUDPOL_TX_A = et_ctrl[    8];
assign ET_PUDPOL_TX_B = et_ctrl[    7];
assign ET_PUDPOL_RX_A = et_ctrl[    6];
assign ET_PUDPOL_RX_B = et_ctrl[    5];
assign ET_TEST_A      = et_ctrl[ 4: 3];
assign ET_TEST_B      = et_ctrl[ 2: 1];
assign ET_POR         = et_ctrl[    0];

assign ST_SEL_RX_A    = st_ctrl[   30];
assign ST_SEL_RX_B    = st_ctrl[   29];
assign ST_SEL_TX_A    = st_ctrl[   28];
assign ST_SEL_TX_B    = st_ctrl[   27];
assign ST_PD_BIAS_A   = st_ctrl[   26];
assign ST_PD_BIAS_B   = st_ctrl[   25];
assign ST_IDSET_A     = st_ctrl[24:23];
assign ST_IDSET_B     = st_ctrl[22:21];
assign ST_HYST_A      = st_ctrl[   20];
assign ST_HYST_B      = st_ctrl[   19];
assign ST_DRV_STR_A   = st_ctrl[18:17];
assign ST_DRV_STR_B   = st_ctrl[16:15];
assign ST_SR_A        = st_ctrl[   14];
assign ST_SR_B        = st_ctrl[   13];
assign ST_PUDEN_TX_A  = st_ctrl[   12];
assign ST_PUDEN_TX_B  = st_ctrl[   11];
assign ST_PUDEN_RX_A  = st_ctrl[   10];
assign ST_PUDEN_RX_B  = st_ctrl[    9];
assign ST_PUDPOL_TX_A = st_ctrl[    8];
assign ST_PUDPOL_TX_B = st_ctrl[    7];
assign ST_PUDPOL_RX_A = st_ctrl[    6];
assign ST_PUDPOL_RX_B = st_ctrl[    5];
assign ST_TEST_A      = st_ctrl[ 4: 3];
assign ST_TEST_B      = st_ctrl[ 2: 1];
assign ST_POR         = st_ctrl[    0];
*/

assign SC_SEL_RX_A    = sc_ctrl[   30];
assign SC_SEL_RX_B    = sc_ctrl[   29];
assign SC_SEL_TX_A    = sc_ctrl[   28];
assign SC_SEL_TX_B    = sc_ctrl[   27];
assign SC_PD_BIAS_A   = sc_ctrl[   26];
assign SC_PD_BIAS_B   = sc_ctrl[   25];
assign SC_IDSET_A     = sc_ctrl[24:23];
assign SC_IDSET_B     = sc_ctrl[22:21];
assign SC_HYST_A      = sc_ctrl[   20];
assign SC_HYST_B      = sc_ctrl[   19];
assign SC_DRV_STR_A   = sc_ctrl[18:17];
assign SC_DRV_STR_B   = sc_ctrl[16:15];
assign SC_SR_A        = sc_ctrl[   14];
assign SC_SR_B        = sc_ctrl[   13];
assign SC_PUDEN_TX_A  = sc_ctrl[   12];
assign SC_PUDEN_TX_B  = sc_ctrl[   11];
assign SC_PUDEN_RX_A  = sc_ctrl[   10];
assign SC_PUDEN_RX_B  = sc_ctrl[    9];
assign SC_PUDPOL_TX_A = sc_ctrl[    8];
assign SC_PUDPOL_TX_B = sc_ctrl[    7];
assign SC_PUDPOL_RX_A = sc_ctrl[    6];
assign SC_PUDPOL_RX_B = sc_ctrl[    5];
assign SC_TEST_A      = sc_ctrl[ 4: 3];
assign SC_TEST_B      = sc_ctrl[ 2: 1];
assign SC_POR         = sc_ctrl[    0];

endmodule
