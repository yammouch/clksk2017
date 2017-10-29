module pulse_extend #(
 parameter CBW =  'd2,
           RV  = 1'b0) (
 input                RSTX,
 input                CLK,
 input                DIN,
 input      [CBW-1:0] CYCLE,
 output reg           DOUT
);
integer i;

reg [CBW-1:0] cnt;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)                   cnt <= {CBW{1'b0}};
  else if (DIN != RV)          cnt <= CYCLE;
  else if (cnt == {CBW{1'b0}}) cnt <= {CBW{1'b0}};
  else                         cnt <= cnt - {{(CBW-1){1'b0}}, 1'b1};

always @(posedge CLK or negedge RSTX)
  if (!RSTX) DOUT <= RV;
  else       DOUT <= (cnt != {CBW{1'b0}}) ^ RV;

endmodule
