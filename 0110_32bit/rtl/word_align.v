module word_align (
 input             RSTX,
 input             CLK,
 input             PHY_INIT,
 input             DIPUSH,
 input      [31:0] DIN,

 output reg        DOPUSH,
 output reg [31:0] DOUT,
 output            ALIGNED
);

reg [62:0] din_shift;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)       din_shift <= 63'd0;
  else if (DIPUSH) din_shift <=  {din_shift[30:0], DIN};
always @(posedge CLK or negedge RSTX)
  if (!RSTX) DOPUSH <= 1'b0;
  else       DOPUSH <= DIPUSH;

wire [31:0] sync_comp;
generate
genvar gv;
for (gv = 0; gv < 32; gv = gv+1) begin : sync_mux
  assign sync_comp[gv] = din_shift[gv+31:gv] == 32'hF731_8CEF;
end
endgenerate

reg [31:0] sync_found;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)                    sync_found <= 31'd0;
  else if (PHY_INIT)            sync_found <= 31'd0;
  else if (sync_found != 31'd0) sync_found <= sync_found;
  else if (sync_comp != 31'd0)  sync_found <= sync_comp;
  else                          sync_found <= 31'd0;

integer i;
always @* begin
  DOUT = 32'd0;
  for (i = 0; i < 32; i = i+1)
    DOUT = DOUT | ({32{sync_found[i]}} & (din_shift >> i));
end

assign ALIGNED = |sync_found;

endmodule
