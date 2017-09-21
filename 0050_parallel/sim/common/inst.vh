reg         RSTX;
wire        CLK;
reg         CLR;

tb_clk_gen fg(.clk(CLK));

wire [31:0] parallel_dout;
wire        parallel_dopush;
wire        phy_init;
parallel_send i_parallel_send (
 .CLK      (CLK),
 .RSTX     (RSTX),
 .DOPULL   (1'b1),
 .CLR      (CLR),

 .PHY_INIT (phy_init),
 .DOPUSH   (parallel_dopush),
 .DOUT     (parallel_dout)
);

reg  [62:0] parallel_shift;
wire [31:0] misaligned;
reg  [ 4:0] parallel_shamt;
reg         parallel_dopush_d1;
initial parallel_shamt = 5'd0;
always @(posedge CLK) begin
  parallel_shift     <= {parallel_shift[30:0], parallel_dout};
  parallel_dopush_d1 <= parallel_dopush;
end
assign misaligned = parallel_shift << parallel_shamt;

wire [31:0] aligned_dout;
wire        aligned_dopush;
wire        aligned;
word_align i_word_align (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .PHY_INIT (phy_init | CLR),
 .DIN      (misaligned),
 .DIPUSH   (parallel_dopush_d1),

 .DOUT     (aligned_dout),
 .DOPUSH   (aligned_dopush),
 .ALIGNED  (aligned)
);

parallel_recv i_parallel_recv (
 .RSTX    (RSTX),
 .CLK     (CLK),
 .CLR     (CLR),
 .ALIGNED (aligned),
 .DIPUSH  (alighed_dout),
 .DIN     (alighed_dopush),
 .INIT    (phy_init),

 .ERR_CNT ()
);
