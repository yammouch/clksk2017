module pulse_extend #(parameter CBW = 'd2) (
 input            RSTX,
 input            CLK,
 input            DIN,
 input  [CBW-1:0] CYCLE,
 output           DOUT
);
integer i;

wire [(1<<CBW)-1:0] cycle_decoded = {{((1<<CBW)-1){1'b0}}, 1'b1} << CYCLE;

reg [CBW-1:0] cnt;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)                   cnt <= {CBW{1'b0}};
  else if (DIN)                cnt <= CYCLE;
  else if (cnt == {CBW{1'b0}}) cnt <= {CBW{1'b0}};
  else                         cnt <= cnt - {{(CBW-1){1'b0}}, 1'b1};

assign DOUT = (cnt != {CBW{1'b0}}) | DIN;

endmodule
