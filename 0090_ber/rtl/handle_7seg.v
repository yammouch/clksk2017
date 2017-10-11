module handle_7seg (
 input         RSTX,
 input         CLK,
 input  [ 6:0] MAIN_MODE,
 input  [ 6:0] SUB_MODE,
 input  [57:0] RECV_CNT,
 input  [63:0] ERR_CNT,
 output [ 3:0] DIGIT_SEL,
 output [ 7:0] DIGIT
);

wire s_cnt0;
cnt_down #(.BW(25)) i_cnt_down_s (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .VAL      (25'd20_000_000),
 .DEC      (1'b1),
 .LOAD     (1'b0),
 .CNT0     (s_cnt0),
 .CNT      (),
 .CNT_NEXT ()
);

wire [1:0] p_cnt, p_cnt_next;
cnt_down #(.BW(2)) i_cnt_down_p (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .VAL      (2'd2),
 .DEC      (s_cnt0),
 .LOAD     (1'b0),
 .CNT0     (),
 .CNT      (p_cnt),
 .CNT_NEXT (p_cnt_next)
);

wire [27:0] dig_ber;
ber_7seg i_ber_7seg (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (p_cnt_next == 2'd1 && p_cnt != 2'd0),
 .RECV_CNT (RECV_CNT),
 .ERR_CNT  (ERR_CNT),
 .DIGIT0   (dig_ber[ 6: 0]),
 .DIGIT1   (dig_ber[13: 7]),
 .DIGIT2   (dig_ber[20:14]),
 .DIGIT3   (dig_ber[27:21])
);

wire [3:0] dig_s0;
wire [6:0] dig_s1;
div #(.BW_CNT(3), .BW_DEND(7), .BW_DSOR(4)) i_div_s (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (p_cnt_next == 2'd2 && p_cnt != 2'd2),
 .DIVIDEND (SUB_MODE),
 .DIVISOR  (4'd10),
 .BUSY     (),
 .QUOT     (dig_s1),
 .REM      (dig_s0)
);

wire [3:0] dig_m0;
wire [6:0] dig_m1;
div #(.BW_CNT(3), .BW_DEND(7), .BW_DSOR(4)) i_div_m (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (p_cnt_next == 2'd0 && p_cnt != 2'd0),
 .DIVIDEND (MAIN_MODE),
 .DIVISOR  (4'd10),
 .BUSY     (),
 .QUOT     (dig_m1),
 .REM      (dig_m0)
);

wire [13:0] dig_m, dig_s;
encode_7seg i_encode_7seg_m1 (.DIN (dig_m1[3:0]), .DOUT(dig_m[13:7]));
encode_7seg i_encode_7seg_m0 (.DIN (dig_m0     ), .DOUT(dig_m[ 6:0]));
encode_7seg i_encode_7seg_s1 (.DIN (dig_s1[3:0]), .DOUT(dig_s[13:7]));
encode_7seg i_encode_7seg_s0 (.DIN (dig_s0     ), .DOUT(dig_s[ 6:0]));

reg [27:0] digmux;
always @*
  case (p_cnt)
  2'd0   : digmux = dig_ber;
  2'd1   : digmux = {14'd0, dig_s};
  2'd2   : digmux = {14'd0, dig_m};
  default: digmux = 28'd0;
  endcase

wire [3:0] digsel;
wire [7:0] dig;
blink_7seg #(.BW(6)) i_blink_7seg (
 .TIMEOUT   (6'd49),
 .RSTX      (RSTX),
 .CLK       (CLK),
 .DIGIT0    ({1'b0, digmux[ 6: 0]}),
 .DIGIT1    ({1'b0, digmux[13: 7]}),
 .DIGIT2    ({1'b0, digmux[20:14]}),
 .DIGIT3    ({1'b0, digmux[27:21]}),
 .DIGIT_SEL (digsel),
 .DIGIT     (dig)
);

generate
genvar gv;
for (gv = 0; gv < 4; gv = gv+1)
  assign DIGIT_SEL[gv] = digsel[gv] ? 1'b1 : 1'bz;
for (gv = 0; gv < 8; gv = gv+1)
  assign DIGIT[gv]     = dig[gv]    ? 1'b0 : 1'bz;
endgenerate

endmodule
