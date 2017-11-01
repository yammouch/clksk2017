module button_ctrl (
 input            RSTX,
 input            CLK,
 input            BTN_1,
 input            BTN_2,
 input            BTN_3,
 output reg [7:0] CNT1,
 output reg [7:0] CNT2,
 output           CLR_SEQ,
 output reg       PLL_CHG,
 output reg [7:0] PLL_ADDR
);

localparam MODE1  = 1'd0,
           MODE10 = 1'd1;

wire bt1r, bt1, bt1f;
wire bt2r, bt2, bt2f;
wire       bt3      ;

dechat #(.BW(15), .RV(1'b1)) i_dechat_bt3 (
 .TIMEOUT (15'd20000),
 .RSTX    (RSTX),
 .CLK     (CLK),
 .DIN     (BTN_3),
 .DRISE   (),
 .DOUT    (bt3),
 .DFALL   ()
);

dechat #(.BW(15), .RV(1'b1)) i_dechat_bt2 (
 .TIMEOUT (15'd20000),
 .RSTX    (RSTX),
 .CLK     (CLK),
 .DIN     (BTN_2),
 .DRISE   (bt2r),
 .DOUT    (bt2),
 .DFALL   (bt2f)
);

dechat #(.BW(15), .RV(1'b1)) i_dechat_bt1 (
 .TIMEOUT (15'd20000),
 .RSTX    (RSTX),
 .CLK     (CLK),
 .DIN     (BTN_1),
 .DRISE   (bt1r),
 .DOUT    (bt1),
 .DFALL   (bt1f)
);

reg state, state_next;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) state <= MODE1;
  else       state <= state_next;
always @*
  case (state)
  MODE1:
    if (!bt1 && bt2f || !bt2 && bt1f) state_next = MODE10;
    else                              state_next = MODE1;
  MODE10:
    if (bt1 && bt2)                   state_next = MODE1;
    else                              state_next = MODE10;
  endcase

wire esc = state_next == MODE1 && state == MODE10;
wire [5:0] bts = {bt3, bt2, bt1, esc, bt2r, bt1r};
wire [7:0] cnt1_p1, cnt2_p1;

cnt10 cnt10_p (
 .UBND  (~8'd0),
 .RSTX  (RSTX),
 .CLK   (CLK),
 .CLR   (1'b0),
 .ADD1  (bts == 6'b111_010),
 .ADD10 (bts == 6'b110_010),
 .SUB1  (bts == 6'b111_001),
 .SUB10 (bts == 6'b101_001),
 .CNT   (cnt1_p1)
);

cnt10 cnt10_s (
 .UBND  (~8'd0),
 .RSTX  (RSTX),
 .CLK   (CLK),
 .CLR   (1'b0),
 .ADD1  (bts == 6'b011_010),
 .ADD10 (bts == 6'b010_010),
 .SUB1  (bts == 6'b011_001),
 .SUB10 (bts == 6'b001_001),
 .CNT   (cnt2_p1)
);

always @(posedge CLK or negedge RSTX)
  if (!RSTX) CNT1 <= 8'd0;
  else       CNT1 <= cnt1_p1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) CNT2 <= 8'd0;
  else       CNT2 <= cnt2_p1;
wire cnt1_chg = cnt1_p1 != CNT1;
wire cnt2_chg = cnt2_p1 != CNT2;

pulse_extend #(.CBW(11), .RV(1'b0)) i_pex (
 .CYCLE (~11'd0),
 .RSTX  (RSTX),
 .CLK   (CLK),
 .DIN   (cnt1_chg | cnt2_chg),
 .DOUT  (CLR_SEQ)
);

function [8:0] fplladdr(input [7:0] CNT1, input [7:0] CNT2);
case (CNT1)
  8'd9   : fplladdr = {1'b1, CNT2};
  8'd10  : fplladdr = {1'b0, 8'd2};
  8'd11  : fplladdr = {1'b1, CNT2};
  8'd12  : fplladdr = {1'b0, 8'd8};
  8'd13  : fplladdr = {1'b0, 8'd2};
  8'd14  : fplladdr = {1'b0, 8'd2};
  8'd15  : fplladdr = {1'b0, 8'd2};
  8'd16  : fplladdr = {1'b0, 8'd2};
  8'd17  : fplladdr = {1'b0, 8'd2};
  8'd18  : fplladdr = {1'b0, 8'd2};
  8'd19  : fplladdr = {1'b0, 8'd2};
  8'd20  : fplladdr = {1'b0, 8'd2};
  8'd21  : fplladdr = {1'b1, CNT2};
  8'd22  : fplladdr = {1'b1, CNT2};
  8'd23  : fplladdr = {1'b1, CNT2};
  8'd24  : fplladdr = {1'b1, CNT2};
  8'd25  : fplladdr = {1'b1, CNT2};
  8'd26  : fplladdr = {1'b1, CNT2};
  8'd27  : fplladdr = {1'b1, CNT2};
  8'd28  : fplladdr = {1'b1, CNT2};
  8'd29  : fplladdr = {1'b1, CNT2};
  8'd30  : fplladdr = {1'b1, CNT2};
  8'd31  : fplladdr = {1'b1, CNT2};
  default: fplladdr = {1'b1, CNT2};
endcase
endfunction

wire [8:0] plladdr = fplladdr(cnt1_p1, cnt2_p1);

always @(posedge CLK or negedge RSTX)
  if (!RSTX) PLL_CHG <= 1'b0;
  else       PLL_CHG <= cnt1_chg || plladdr[8] && cnt2_chg;

always @(posedge CLK or negedge RSTX)
  if (!RSTX) PLL_ADDR <= 8'd0;
  else       PLL_ADDR <= plladdr[7:0];

endmodule
