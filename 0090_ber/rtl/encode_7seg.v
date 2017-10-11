module encode_7seg (
 input      [3:0] DIN,
 output reg [6:0] DOUT
);

always @*
  case (DIN)
  4'd0   : DOUT = 7'b0111111;
  4'd1   : DOUT = 7'b0000110;
  4'd2   : DOUT = 7'b1011011;
  4'd3   : DOUT = 7'b1001111;
  4'd4   : DOUT = 7'b1100110;
  4'd5   : DOUT = 7'b1101101;
  4'd6   : DOUT = 7'b0111111;
  4'd7   : DOUT = 7'b0100111;
  4'd8   : DOUT = 7'b1111111;
  4'd9   : DOUT = 7'b1101111;
  default: DOUT = 7'dx;
  endcase

endmodule
