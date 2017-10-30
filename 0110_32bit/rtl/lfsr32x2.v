module lfsr32x2 (
 input  [31:0] DIN,
 output [31:0] DOUT);

assign DOUT = DIN == 32'd0
            ? 32'd1
            :   { DIN[30:0], 1'b0 }
              ^ ( DIN[31] ? 32'hC000_0401 : 32'd0 );

endmodule
