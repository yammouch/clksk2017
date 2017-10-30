module lfsr32x2 (
 input  [7:0] DIN,
 output [7:0] DOUT);

assign DOUT = DIN == 8'd0
            ? 8'd1
            :   { DIN[6:0], 1'b0 }
              ^ ( DIN[7] ? 8'h71 : 8'd0 );

endmodule
