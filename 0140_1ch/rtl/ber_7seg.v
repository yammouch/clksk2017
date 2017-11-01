module ber_7seg (
 input         RSTX,
 input         CLK,
 input         START,
 input  [59:0] RECV_CNT,
 input  [63:0] ERR_CNT,
 output        BUSY,
 output [ 6:0] DIGIT0,
 output [ 6:0] DIGIT1,
 output [ 6:0] DIGIT2,
 output [ 6:0] DIGIT3
);

localparam INIT       = 3'd0,
           COMP       = 3'd1,
           MUL10      = 3'd2,
           MUL10_LAST = 3'd3,
           DIV        = 3'd4,
           DIV10      = 3'd5;

reg [59:0] rcnt;
reg [63:0] ecnt;
reg [ 4:0] exp_cnt;
wire end10  = {rcnt, 4'd0} <= ecnt;
wire endexp = 5'd17 < exp_cnt;
wire mbusy, dbusy, d10busy;
reg [2:0] state, state_next;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) state <= INIT;
  else       state <= state_next;
always @*
  case (state)
  INIT:
    if (START)        state_next = COMP;
    else              state_next = INIT;
  COMP:
    if (START)        state_next = COMP;
    else if (end10)   state_next = MUL10_LAST;
    else if (endexp)  state_next = INIT;
    else              state_next = MUL10;
  MUL10:
    if (START)        state_next = COMP;
    else if (mbusy)   state_next = MUL10;
    else              state_next = COMP;
  MUL10_LAST:
    if (START)        state_next = COMP;
    else if (mbusy)   state_next = MUL10_LAST;
    else              state_next = DIV;
  DIV:
    if (START)        state_next = COMP;
    else if (dbusy)   state_next = DIV;
    else              state_next = DIV10;
  DIV10:
    if (START)        state_next = COMP;
    else if (d10busy) state_next = DIV10;
    else              state_next = INIT;
  default:            state_next = INIT;
  endcase

assign BUSY = state != INIT;

always @(posedge CLK or negedge RSTX)
  if (!RSTX)      rcnt <= 60'd0;
  else if (START) rcnt <= RECV_CNT;

wire [67:0] prod;
wire ecnt_updt = state_next == COMP && state == MUL10;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)          ecnt <= 64'd0;
  else if (START)     ecnt <= ERR_CNT;
  else if (ecnt_updt) ecnt <= prod[63:0];
always @(posedge CLK or negedge RSTX)
  if (!RSTX)          exp_cnt <= 5'd0;
  else if (START)     exp_cnt <= 5'd0;
  else if (ecnt_updt) exp_cnt <= exp_cnt + 5'd1;

mult #(.BW_CNT(7), .BW_MCAND(4), .BW_MLIER(64)) i_mult (
 .mlier_is_signed (1'b0),
 .mcand_is_signed (1'b0),
 .rstx            (RSTX),
 .clk             (CLK),
 .start           (state == COMP),
 .mcand           (4'd10),
 .mlier           (ecnt),
 .busy            (mbusy),
 .prod            (prod)
);

wire [63:0] ratio;
div #(.BW_CNT(6), .BW_DEND(64), .BW_DSOR(64)) i_div (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .DIVIDEND (prod[63:0]),
 .DIVISOR  ({rcnt, 4'd0}),
 .START    (state_next == DIV && state == MUL10_LAST),
 .BUSY     (dbusy),
 .REM      (),
 .QUOT     (ratio)
);

wire start_div10 = state_next == DIV10 && state == DIV;
wire [6:0] dig3;
wire [3:0] dig2;
div #(.BW_CNT(3), .BW_DEND(7), .BW_DSOR(4)) i_div10 (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .DIVIDEND (ratio[6:0]),
 .DIVISOR  (4'd10),
 .START    (start_div10),
 .BUSY     (d10busy),
 .QUOT     (dig3),
 .REM      (dig2)
);

wire [4:0] dig1;
wire [3:0] dig0;
div #(.BW_CNT(3), .BW_DEND(5), .BW_DSOR(4)) i_divexp (
 .RSTX (RSTX),
 .CLK  (CLK),
 .DIVIDEND (exp_cnt),
 .DIVISOR  (4'd10),
 .START    (start_div10),
 .BUSY     (),
 .QUOT     (dig1),
 .REM      (dig0)
);

wire [6:0] dec3, dec2, dec1, dec0;
encode_7seg i_encode_7seg_3 (.DIN(endexp ? 4'd0 : dig3[3:0]), .DOUT(dec3));
encode_7seg i_encode_7seg_2 (.DIN(endexp ? 4'd0 : dig2     ), .DOUT(dec2));
encode_7seg i_encode_7seg_1 (.DIN(endexp ? 4'd0 : dig1[3:0]), .DOUT(dec1));
encode_7seg i_encode_7seg_0 (.DIN(endexp ? 4'd0 : dig0     ), .DOUT(dec0));

wire no_data = rcnt == 58'd0;
assign DIGIT3 = no_data ? 7'b1010100 : dec3;
assign DIGIT2 = no_data ? 7'b1011100 : dec2;
assign DIGIT1 = no_data ? 7'b1011110 : dec1;
assign DIGIT0 = no_data ? 7'b1111000 : dec0;

endmodule
