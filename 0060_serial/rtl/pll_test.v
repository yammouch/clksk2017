module pll_test (
 input        RSTX,
 input        CLK,
 input        BTN_UP,
 input        BTN_DN,
 input  [1:0] DIN,
 output [1:0] DOUT,
 output       DIV32,
 output       PLL_LOCK,
 output [3:0] DIGIT_SEL,
 output [7:0] DIGIT
);

wire rstxo;

wire btn_up_d, btn_dn_d;

dechat #(.BW(19), .RV(1'b1)) i_dechat_up(
 .RSTX    (rstxo),
 .CLK     (CLK),
 .TIMEOUT (19'd399999),
 .DIN     (BTN_UP),
 .DOUT    (btn_up_d)
);

dechat #(.BW(19), .RV(1'b1)) i_dechat_dn(
 .RSTX    (rstxo),
 .CLK     (CLK),
 .TIMEOUT (19'd399999),
 .DIN     (BTN_DN),
 .DOUT    (btn_dn_d)
);

wire [6:0] digit0, digit1;
wire clkf, clks, rstxf, rstxs;
pll_ctrl i_pll_ctrl(
 .RSTX     (RSTX),
 .CLK      (CLK),
 .BTN_UP   (btn_up_d),
 .BTN_DN   (btn_dn_d),
 .PLL_LOCK (PLL_LOCK),
 .DIGIT0   (digit0),
 .DIGIT1   (digit1),
 .CLKF     (clkf),
 .CLKS     (clks),
 .RSTXO    (rstxo),
 .RSTXF    (rstxf),
 .RSTXS    (rstxs)
);

assign DIV32 = clkf;

wire [3:0] digit_sel_tri;
wire [7:0] digit_tri;

blink_7seg #(.BW(6)) i_blink_7seg (
 .RSTX      (rstxo),
 .CLK       (CLK),
 .TIMEOUT   (6'd49),
 .DIGIT0    ({1'b0, digit0}),
 .DIGIT1    ({1'b0, digit1}),
 .DIGIT2    (8'd0),
 .DIGIT3    (8'd0),
 .DIGIT_SEL (digit_sel_tri),
 .DIGIT     (digit_tri)
);

generate
genvar i;
for (i = 0; i < 4; i = i+1) begin : g_digit_sel
  OBUFT i_obuft (.I(1'b1), .T(~digit_sel_tri[i]), .O(DIGIT_SEL[i]));
end
for (i = 0; i < 8; i = i+1) begin : g_digit
  OBUFT i_obuft (.I(1'b0), .T(~digit_tri[i]), .O(DIGIT[i]));
end
endgenerate

lvds1 i_lvds1 (
 .RSTXS   (rstxs),
 .CLKS    (clks),
 .RSTXF   (rstxf),
 .CLKF    (clkf),
 .RSTXP   (rstxo),
 .CLKP    (CLK),
 .DOUT    (DOUT),
 .DIN     (DIN),
 .ERR_CNT ()
);

endmodule
