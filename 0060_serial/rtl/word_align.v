module word_align (
 input             RSTX,
 input             CLK,
 input             PHY_INIT,
 input             DIPUSH,
 input      [63:0] DIN,

 output reg        DOPUSH,
 output reg [63:0] DOUT,
 output            ALIGNED
);

reg [126:0] din_shift;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)       din_shift <= 127'd0;
  else if (DIPUSH) din_shift <=  {din_shift[62:0], DIN};
always @(posedge CLK or negedge RSTX)
  if (!RSTX) DOPUSH <= 1'b0;
  else       DOPUSH <= DIPUSH;

wire [63:0] sync_comp;
generate
genvar gv;
for (gv = 0; gv < 64; gv = gv+1)
  assign sync_comp[gv] = din_shift[gv+63:gv] == 64'hF731_8CEF_137F_FEC8;
endgenerate

reg [63:0] sync_found;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)                    sync_found <= 63'd0;
  else if (PHY_INIT)            sync_found <= 63'd0;
  else if (sync_found != 63'd0) sync_found <= sync_found;
  else if (sync_comp != 63'd0)  sync_found <= sync_comp;
  else                          sync_found <= 63'd0;

integer i;
always @* begin
  DOUT = 64'd0;
  for (i = 0; i < 64; i = i+1)
    DOUT = DOUT | ({64{sync_found[i]}} & (din_shift >> i));
end

assign ALIGNED = |sync_found;

endmodule
