module button_ctrl (
 input            RSTX,
 input            CLK,
 input            BTN_1,
 input            BTN_2,
 input            BTN_3,
 output     [7:0] CNT1,
 output     [7:0] CNT2,
 output           CLR_SEQ,
 output reg       PLL_CHG
);

localparam MODE1  = 1'd0,
           MODE10 = 1'd1;

wire bt1r, bt1, bt1f;
wire bt2r, bt2, bt2f;
wire       bt3      ;

dechat #(.BW(12), .RV(1'b1)) i_dechat_bt3 (
 .TIMEOUT (12'd2499),
 .RSTX    (RSTX),
 .CLK     (CLK),
 .DIN     (BTN_3),
 .DRISE   (),
 .DOUT    (bt3),
 .DFALL   ()
);

dechat #(.BW(12), .RV(1'b1)) i_dechat_bt2 (
 .TIMEOUT (12'd2499),
 .RSTX    (RSTX),
 .CLK     (CLK),
 .DIN     (BTN_2),
 .DRISE   (bt2r),
 .DOUT    (bt2),
 .DFALL   (bt2f)
);

dechat #(.BW(12), .RV(1'b1)) i_dechat_bt1 (
 .TIMEOUT (12'd2499),
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
wire p_add1  = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b111_010;
wire p_add10 = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b110_010;
wire p_sub1  = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b111_001;
wire p_sub10 = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b110_001;

cnt10 cnt10_p (
 .UBND  (8'd4),
 .RSTX  (RSTX),
 .CLK   (CLK),
 .CLR   (1'b0),
 .ADD1  (p_add1),
 .ADD10 (p_add10),
 .SUB1  (p_sub1),
 .SUB10 (p_sub10),
 .CNT   (CNT1)
);

wire s_clr   = p_add1 | p_add10 | p_sub1 | p_sub10;
wire s_add1  = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b011_010;
wire s_add10 = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b010_010;
wire s_sub1  = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b011_001;
wire s_sub10 = { bt3, bt2, bt1, esc, bt2r, bt1r } == 6'b010_001;
reg [7:0] s_ubnd;
always @*
  case (CNT1)
  8'd0   : s_ubnd = 8'd0;
  8'd1   : s_ubnd = 8'd2;
  8'd2   : s_ubnd = 8'd4;
  8'd3   : s_ubnd = 8'd2;
  8'd4   : s_ubnd = 8'd2;
  default: s_ubnd = 8'd0;
  endcase

cnt10 cnt10_s (
 .UBND  (s_ubnd),
 .RSTX  (RSTX),
 .CLK   (CLK),
 .CLR   (s_clr),
 .ADD1  (s_add1),
 .ADD10 (s_add10),
 .SUB1  (s_sub1),
 .SUB10 (s_sub10),
 .CNT   (CNT2)
);

wire clsq = s_clr | s_add1 | s_add10 | s_sub1 | s_sub10;
pulse_extend #(.CBW(4), .RV(1'b1)) i_pex (
 .CYCLE (4'd15),
 .RSTX  (RSTX),
 .CLK   (CLK),
 .DIN   (clsq),
 .DOUT  (CLR_SEQ)
);

always @(posedge CLK or negedge RSTX)
  if (!RSTX) PLL_CHG <= 1'b0;
  else       PLL_CHG <= clsq;

endmodule
