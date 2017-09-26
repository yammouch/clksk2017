module dechat #(parameter BW='d8, RV=1'b0) (
 input               RSTX,
 input               CLK,
 input               DIN,
 input      [BW-1:0] TIMEOUT,
 output reg          DOUT
);

reg din_d1, din_d2;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) {din_d2, din_d1} <= {2{RV}};
  else       {din_d2, din_d1} <= {din_d1, DIN};

reg [BW-1:0] cnt;
wire cnting = cnt < TIMEOUT;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)               cnt <= {BW{1'b0}};
  else if (din_d2 == DOUT) cnt <= {BW{1'b0}};
  else                     cnt <= cnt + {{(BW-1){1'b0}}, 1'b1};

always @(posedge CLK or negedge RSTX)
  if (!RSTX)        DOUT <= RV;
  else if (!cnting) DOUT <= din_d2;

endmodule
