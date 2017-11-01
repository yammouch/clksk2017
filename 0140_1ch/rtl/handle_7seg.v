module handle_7seg (
 input         RSTX,
 input         CLK,
 input  [ 7:0] MAIN_MODE,
 input  [ 7:0] SUB_MODE,
 input         PHY_INIT,
 input  [59:0] RECV_CNT,
 input  [63:0] ERR_CNT,
 output [ 3:0] DIGIT_SEL,
 output [ 7:0] DIGIT
);

reg [7:0] main_mode_d1, sub_mode_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) main_mode_d1 <= ~8'd0;
  else       main_mode_d1 <= MAIN_MODE;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) sub_mode_d1  <= ~8'd0;
  else       sub_mode_d1  <= SUB_MODE;

wire main_mode_chg = MAIN_MODE != main_mode_d1;
wire sub_mode_chg  = SUB_MODE  != sub_mode_d1;
wire mode_chg = main_mode_chg || sub_mode_chg;

wire s_cnt0;
cnt_down #(.BW(24)) i_cnt_down_s (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .VAL      (24'd10_000_000),
 .DEC      (1'b1),
 .LOAD     (mode_chg),
 .CNT0     (s_cnt0),
 .CNT      (),
 .CNT_NEXT ()
);

wire [1:0] p_cnt, p_cnt_next;
cnt_down #(.BW(2)) i_cnt_down_p (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .VAL      (sub_mode_chg ? 2'd1 : 2'd2),
 .DEC      (s_cnt0),
 .LOAD     (mode_chg),
 .CNT0     (),
 .CNT      (p_cnt),
 .CNT_NEXT (p_cnt_next)
);

reg [2:0] phy_init_d;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) phy_init_d <= 3'b00;
  else       phy_init_d <= {phy_init_d[1:0], PHY_INIT};

wire [27:0] dig_ber;
wire        ber_busy;
ber_7seg i_ber_7seg (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (!phy_init_d[2] && phy_init_d[1] && !ber_busy && p_cnt != 2'd0),
 .RECV_CNT (RECV_CNT),
 .ERR_CNT  (ERR_CNT),
 .BUSY     (ber_busy),
 .DIGIT0   (dig_ber[ 6: 0]),
 .DIGIT1   (dig_ber[13: 7]),
 .DIGIT2   (dig_ber[20:14]),
 .DIGIT3   (dig_ber[27:21])
);

wire [3:0] dig_s0, dig_s1;
wire [4:0] dig_s2;
wire [7:0] s0_q;
wire       s0_busy;
div #(.BW_CNT(3), .BW_DEND(8), .BW_DSOR(4)) i_div_s0 (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (sub_mode_chg),
 .DIVIDEND (SUB_MODE),
 .DIVISOR  (4'd10),
 .BUSY     (s0_busy),
 .QUOT     (s0_q),
 .REM      (dig_s0)
);
reg s0_busy_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) s0_busy_d1 <= 1'b0;
  else       s0_busy_d1 <= s0_busy;
div #(.BW_CNT(3), .BW_DEND(5), .BW_DSOR(4)) i_div_s1 (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (!s0_busy && s0_busy_d1),
 .DIVIDEND (s0_q[4:0]),
 .DIVISOR  (4'd10),
 .BUSY     (),
 .QUOT     (dig_s2),
 .REM      (dig_s1)
);

wire [3:0] dig_m0, dig_m1;
wire [4:0] dig_m2;
wire [7:0] m0_q;
wire       m0_busy;
div #(.BW_CNT(3), .BW_DEND(8), .BW_DSOR(4)) i_div_m (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (main_mode_chg),
 .DIVIDEND (MAIN_MODE),
 .DIVISOR  (4'd10),
 .BUSY     (m0_busy),
 .QUOT     (m0_q),
 .REM      (dig_m0)
);
reg m0_busy_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) m0_busy_d1 <= 1'b0;
  else       m0_busy_d1 <= m0_busy;
div #(.BW_CNT(3), .BW_DEND(5), .BW_DSOR(4)) i_div_m1 (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .START    (!m0_busy && m0_busy_d1),
 .DIVIDEND (m0_q[4:0]),
 .DIVISOR  (4'd10),
 .BUSY     (),
 .QUOT     (dig_m2),
 .REM      (dig_m1)
);

wire [20:0] dig_m, dig_s;
encode_7seg i_encode_7seg_m2 (.DIN (dig_m2[3:0]), .DOUT(dig_m[20:14]));
encode_7seg i_encode_7seg_m1 (.DIN (dig_m1     ), .DOUT(dig_m[13: 7]));
encode_7seg i_encode_7seg_m0 (.DIN (dig_m0     ), .DOUT(dig_m[ 6: 0]));
encode_7seg i_encode_7seg_s2 (.DIN (dig_s2[3:0]), .DOUT(dig_s[20:14]));
encode_7seg i_encode_7seg_s1 (.DIN (dig_s1     ), .DOUT(dig_s[13: 7]));
encode_7seg i_encode_7seg_s0 (.DIN (dig_s0     ), .DOUT(dig_s[ 6: 0]));

function ber_en(input [7:0] DIN);
case (DIN)
8'd9   : ber_en = 1'b1;
8'd10  : ber_en = 1'b0;
8'd11  : ber_en = 1'b0;
8'd12  : ber_en = 1'b1;
8'd13  : ber_en = 1'b0;
8'd14  : ber_en = 1'b0;
8'd15  : ber_en = 1'b0;
8'd16  : ber_en = 1'b0;
8'd17  : ber_en = 1'b0;
8'd18  : ber_en = 1'b0;
8'd19  : ber_en = 1'b0;
8'd20  : ber_en = 1'b0;
8'd21  : ber_en = 1'b1;
8'd22  : ber_en = 1'b1;
8'd23  : ber_en = 1'b0;
8'd24  : ber_en = 1'b0;
8'd25  : ber_en = 1'b0;
8'd26  : ber_en = 1'b0;
8'd27  : ber_en = 1'b0;
8'd28  : ber_en = 1'b0;
8'd29  : ber_en = 1'b0;
8'd30  : ber_en = 1'b0;
8'd31  : ber_en = 1'b1;
default: ber_en = 1'b1;
endcase
endfunction

reg [27:0] digmux;
always @*
  case (p_cnt)
  2'd0   : if (ber_en(MAIN_MODE)) digmux = dig_ber;
           else                   digmux = {4{7'b1000000}};
  2'd1   :                        digmux = {7'd0, dig_s};
  2'd2   :                        digmux = {7'd0, dig_m};
  default:                        digmux = 28'd0;
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
for (gv = 0; gv < 4; gv = gv+1) begin : tri_digsel
  assign DIGIT_SEL[gv] = digsel[gv] ? 1'b1 : 1'bz;
end
for (gv = 0; gv < 8; gv = gv+1) begin : tri_dig
  assign DIGIT[gv]     = dig[gv]    ? 1'b0 : 1'bz;
end
endgenerate

endmodule
