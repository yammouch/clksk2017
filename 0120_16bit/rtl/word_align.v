module word_align (
 input             RSTX,
 input             CLK,
 input             PHY_INIT,
 input             DIPUSH,
 input      [15:0] DIN,

 output reg        DOPUSH,
 output reg [15:0] DOUT,
 output            ALIGNED
);

reg [30:0] din_shift;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)       din_shift <= 31'd0;
  else if (DIPUSH) din_shift <=  {din_shift[14:0], DIN};
always @(posedge CLK or negedge RSTX)
  if (!RSTX) DOPUSH <= 1'b0;
  else       DOPUSH <= DIPUSH;

wire [15:0] sync_comp;
generate
genvar gv;
for (gv = 0; gv < 16; gv = gv+1) begin : sync_mux
  assign sync_comp[gv] = din_shift[gv+15:gv] == 16'hF731;
end
endgenerate

reg [14:0] sync_found;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)                    sync_found <= 15'd0;
  else if (PHY_INIT)            sync_found <= 15'd0;
  else if (sync_found != 31'd0) sync_found <= sync_found;
  else if (sync_comp != 31'd0)  sync_found <= sync_comp;
  else                          sync_found <= 15'd0;

integer i;
always @* begin
  DOUT = 16'd0;
  for (i = 0; i < 16; i = i+1)
    DOUT = DOUT | ({16{sync_found[i]}} & (din_shift >> i));
end

assign ALIGNED = |sync_found;

endmodule
