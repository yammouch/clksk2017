module lfsr32x2 (
 input  [15:0] DIN,
 output [15:0] DOUT);

assign DOUT = DIN == 16'd0
            ? 16'd1
            :   { DIN[14:0], 1'b0 }
              ^ ( DIN[15] ? 16'h3401 : 16'd0 );

endmodule
