module lvds_test (
 input        CLK,
 input        BTN_1,
 input        BTN_2,
 input        BTN_3,
 input  [1:0] DIN,
 output [3:0] DIGIT_SEL,
 output [7:0] DIGIT,
 output [1:0] DOUT,
 output       DIV32
);

wire [7:0] pll_addr;
wire pll_chg;
wire rstxs, clks;
wire rstxf, clkf;
wire rstxo;

pll_ctrl i_pll_ctrl (
 .CLK      (CLK),
 .PLL_ADDR (pll_addr[3:0]),
 .PLL_CHG  (pll_chg),
 .RSTXS    (rstxs),
 .CLKS     (clks),
 .RSTXF    (rstxf),
 .CLKF     (clkf),
 .RSTXO    (rstxo)
);

wire [7:0] main_mode;
wire clr_seq;
button_ctrl i_button_ctrl (
 .RSTX    (rstxo),
 .CLK     (CLK),
 .BTN_1   (BTN_1),
 .BTN_2   (BTN_2),
 .BTN_3   (BTN_3),
 .PLL_CHG (pll_chg),
 .CNT1    (pll_addr),
 .CNT2    (main_mode),
 .CLR_SEQ (clr_seq)
);

wire [57:0] recv_cnt;
wire [63:0] err_cnt;
lvds1 i_lvds1 (
 .RSTXS    (rstxs),
 .CLKS     (clks),
 .RSTXF    (rstxf),
 .CLKF     (clkf),
 .RSTXP    (rstxo),
 .CLKP     (CLK),
 .CLR      (clr_seq),
 .DIN      (DIN),
 .RECV_CNT (recv_cnt),
 .ERR_CNT  (err_cnt),
 .DOUT     (DOUT)
);

handle_7seg i_handle_7seg (
 .RSTX      (rstxo),
 .CLK       (CLK),
 .MAIN_MODE (main_mode[6:0]),
 .SUB_MODE  (pll_addr[6:0]),
 .RECV_CNT  (recv_cnt),
 .ERR_CNT   (err_cnt),
 .DIGIT_SEL (DIGIT_SEL),
 .DIGIT     (DIGIT)
);

endmodule
