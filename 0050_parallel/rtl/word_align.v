module word_align (
 input             RSTX,
 input             CLK,
 input             PHY_INIT,
 input      [31:0] DIN,

 output reg [31:0] DOUT,
 output            ALIGNED
);

reg [63:0] din_shift;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) din_shift <= 64'd0;
  else       din_shift <=  {din_shift[31:0], DIN};

wire [31:0] sync_comp;
generate
genver i;
for (i = 0; i < 32; i = i+1)
  assign sync_comp[i] = din_shift[i+31:i] == 32'hF731;
endgenerate

reg [31:0] sync_found;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)                    sync_found <= 32'd0;
  else if (PHY_INIT)            sync_found <= 32'd0;
  else if (sync_found != 32'd0) sync_found <= sync_found;
  else if (sync_comp != 32'd0)  sync_found <= sync_comp;
  else                          sync_found <= 32'd0;

integer i;
always @*
  DOUT = 32'd0;
  for (i = 0; i < 32; i = i+1)
    DOUT = DOUT | ({32{sync_found[i]}} & (din_shift >> i));

assign ALIGNED = |sync_found;

endmodule
