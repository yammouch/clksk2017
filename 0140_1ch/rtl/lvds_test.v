module lvds_test (
 input        CLK,
 input        BTN_1,
 input        BTN_2,
 input        BTN_3,
 output [3:0] DIGIT_SEL,
 output [7:0] DIGIT,

 output       SEL_RX_A,
 output       SEL_RX_B,
 output       SEL_TX_A,
 output       SEL_TX_B,
 output       PD_BIAS_A,
 output       PD_BIAS_B,
 output [1:0] IDSET_A,
 output [1:0] IDSET_B,
 output       HYST_A,
 output       HYST_B,
 output [1:0] DRV_STR_A,
 output [1:0] DRV_STR_B,
 output       SR_A,
 output       SR_B,
 output       PUDEN_TX_A,
 output       PUDEN_TX_B,
 output       PUDEN_RX_A,
 output       PUDEN_RX_B,
 output       PUDPOL_TX_A,
 output       PUDPOL_TX_B,
 output       PUDPOL_RX_A,
 output       PUDPOL_RX_B,
 output [1:0] TEST_A,
 output [1:0] TEST_B,
 output       POR,
 input  [1:0] DIN,
 output [1:0] DOUT
);

wire clk_ibufg, clk_bufg;
reg clk_div2 = 1'b0;

IBUFG i_ibufg(.I(CLK), .O(clk_ibufg));
always @(posedge clk_ibufg) clk_div2 <= !clk_div2;
BUFG i_bufg(.I(clk_div2), .O(clk_bufg));

wire [7:0] pll_addr;
wire pll_chg;
wire rstxs, clks, clkss;
wire rstxf, clkf, clkf_data;
wire rstxo;
wire serdesstrobe;

pll_ctrl i_pll_ctrl (
 .CLK          (clk_bufg),
 .CLK_PLL_SRC  (clk_ibufg),
 .PLL_ADDR     (pll_addr),
 .PLL_CHG      (pll_chg),
 .RSTXS        (rstxs),
 .CLKS         (clks),
 .CLKSS        (clkss),
 .RSTXF        (rstxf),
 .CLKF         (clkf),
 .CLKF_DATA    (clkf_data),
 .RSTXO        (rstxo),
 .SERDESSTROBE (serdesstrobe)
);

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

wire [59:0] recv_cnt;
wire [63:0] err_cnt;
wire        phy_init;

handle_7seg i_handle_7seg (
 .RSTX      (rstxo),
 .CLK       (clk_bufg),
 .MAIN_MODE (main_mode),
 .SUB_MODE  (sub_mode),
 .PHY_INIT  (phy_init),
 .RECV_CNT  (recv_cnt),
 .ERR_CNT   (err_cnt),
 .DIGIT_SEL (DIGIT_SEL),
 .DIGIT     (DIGIT)
);

wire [30:0] ctrl;

stimulus i_stimulus (
 .RSTX         (rstxo),
 .CLK          (clk_bufg),
 .RSTXS        (rstxs),
 .CLKS         (clks),
 .CLKSS        (clkss),
 .RSTXF        (rstxf),
 .CLKF         (clkf),
 .CLKF_DATA    (clkf_data),
 .CLR          (clr_seq),
 .SERDESSTROBE (serdesstrobe),
 .MAIN_MODE    (main_mode),
 .SUB_MODE     (sub_mode),
 .CTRL         (ctrl),
 .DIN          (DIN),
 .PHY_INIT     (phy_init),
 .DOUT         (DOUT),
 .RECV_CNT     (recv_cnt),
 .ERR_CNT      (err_cnt)
);

assign SEL_RX_A    = ctrl[   30];
assign SEL_RX_B    = ctrl[   29];
assign SEL_TX_A    = ctrl[   28];
assign SEL_TX_B    = ctrl[   27];
assign PD_BIAS_A   = ctrl[   26];
assign PD_BIAS_B   = ctrl[   25];
assign IDSET_A     = ctrl[24:23];
assign IDSET_B     = ctrl[22:21];
assign HYST_A      = ctrl[   20];
assign HYST_B      = ctrl[   19];
assign DRV_STR_A   = ctrl[18:17];
assign DRV_STR_B   = ctrl[16:15];
assign SR_A        = ctrl[   14];
assign SR_B        = ctrl[   13];
assign PUDEN_TX_A  = ctrl[   12];
assign PUDEN_TX_B  = ctrl[   11];
assign PUDEN_RX_A  = ctrl[   10];
assign PUDEN_RX_B  = ctrl[    9];
assign PUDPOL_TX_A = ctrl[    8];
assign PUDPOL_TX_B = ctrl[    7];
assign PUDPOL_RX_A = ctrl[    6];
assign PUDPOL_RX_B = ctrl[    5];
assign TEST_A      = ctrl[ 4: 3];
assign TEST_B      = ctrl[ 2: 1];
assign POR         = ctrl[    0];

endmodule
