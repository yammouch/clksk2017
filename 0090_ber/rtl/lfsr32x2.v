module lfsr32x2 (
 input  [63:0] DIN,
 output [63:0] DOUT);

function [31:0] lfsr32(input [31:0] DIN);
  if (DIN == 32'd0) lfsr32 = 32'd1;
  else              lfsr32 = { DIN[30:0], 1'b0 }
                           ^ ( DIN[31] ? 32'hC000_0401 : 32'd0 );
endfunction

assign DOUT[63:32] = lfsr32(DIN [31: 0]);
assign DOUT[31: 0] = lfsr32(DOUT[63:32]);

endmodule
