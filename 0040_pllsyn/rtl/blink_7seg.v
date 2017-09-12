module blink_7seg #(parameter BW='d8) (
 input               RSTX,
 input               CLK,
 input      [BW-1:0] TIMEOUT,
 input      [   7:0] DIGIT0,
 input      [   7:0] DIGIT1,
 input      [   7:0] DIGIT2,
 input      [   7:0] DIGIT3,
 output reg [   7:0] DIGIT,
 output reg [   3:0] DIGIT_SEL
);

reg [BW-1:0] cnt_0;
wire cnting_0 = cnt_0 < TIMEOUT;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)         cnt_0 <= {BW{1'b0}};
  else if (cnting_0) cnt_0 <= cnt_0 + {{(BW-1){1'b0}}, 1'b1};
  else               cnt_0 <= {BW{1'b0}};

reg [1:0] cnt_1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)          cnt_1 <= 2'd0;
  else if (!cntint_0) cnt_1 <= cnt_1 + 2'd1;

always @(posedge CLK or negedge RSTX)
  if (!RSTX) DIGIT <= ~8'd0;
  else
    case (cnt_1)
    2'd0   : DIGIT <= DIGIT0;
    2'd1   : DIGIT <= DIGIT1;
    2'd2   : DIGIT <= DIGIT2;
    2'd3   : DIGIT <= DIGIT3;
    default: DIGIT <= 8'dx;
    endcase

always @(posedge CLK or negedge RSTX)
  if (!RSTX)
    DIGIT_SEL <= 2'd0;
  else if ( {{(BW-1){1'b0}}, 1'b1} < cnt_0
         && cnt_0 < TIMEOUT - {{(BW-1){1'b0}}, 1'b1})
    DIGIT_SEL <= 4'h1 << cnt_1;
  else
    DIGIT_SEL <= 4'h0;

endmodule
