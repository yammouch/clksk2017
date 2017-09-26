module fifo_async #(parameter BW = 32) (
 input           RSTX_DI,
 input           CLKDI,
 output reg      DIPULL,
 input           DIPUSH,
 input  [BW-1:0] DIN,

 input           RSTX_DO,
 input           CLKDO,
 input           DOPULL,
 output reg      DOPUSH,
 output [BW-1:0] DOUT
);

reg [BW-1:0] din_d1;
reg          dipush_d1;
always @(posedge CLKDI or negedge RSTX_DI)
  if (!RSTX_DI) begin
    din_d1    <= {(BW){1'b0}};
    dipush_d1 <= 1'b0;
  end else begin
    din_d1    <= DIN;
    dipush_d1 <= DIPUSH;
  end
reg [5:0] din_cnt, din_cnt_next;
always @(*)
  if (dipush_d1) din_cnt_next = din_cnt + 6'd1;
  else           din_cnt_next = din_cnt;
always @(posedge CLKDI or negedge RSTX_DI)
  if (!RSTX_DI) din_cnt <= 6'd0;
  else       din_cnt <= din_cnt_next;
reg [5:0] din_cnt_gray, din_cnt_gray_d1, din_cnt_gray_d2;
always @(posedge CLKDI or negedge RSTX_DI)
  if (!RSTX_DI) begin
    din_cnt_gray    <= 6'd0;
    din_cnt_gray_d1 <= 6'd0;
    din_cnt_gray_d2 <= 6'd0;
  end else begin
    din_cnt_gray    <= din_cnt ^ {1'b0, din_cnt[5:1]};
    din_cnt_gray_d1 <= din_cnt_gray;
    din_cnt_gray_d2 <= din_cnt_gray_d1;
  end
wire [5:0] din_cnt_d2;
assign din_cnt_d2[5] = din_cnt_gray_d2[5];
assign din_cnt_d2[4] = din_cnt_gray_d2[4] ^ din_cnt_d2[5];
assign din_cnt_d2[3] = din_cnt_gray_d2[3] ^ din_cnt_d2[4];
assign din_cnt_d2[2] = din_cnt_gray_d2[2] ^ din_cnt_d2[3];
assign din_cnt_d2[1] = din_cnt_gray_d2[1] ^ din_cnt_d2[2];
assign din_cnt_d2[0] = din_cnt_gray_d2[0] ^ din_cnt_d2[1];
reg data_read;
reg [5:0] dout_cnt;
wire [5:0] dout_cnt_next = data_read ? dout_cnt + 6'd1 : dout_cnt;
wire [5:0] fifo_level = din_cnt_d2 - dout_cnt_next;
always @(posedge CLKDO or negedge RSTX_DO)
  if (!RSTX_DO) begin
    data_read <= 1'b0;
    DOPUSH    <= 1'b0;
  end else begin
    data_read <= DOPULL && 6'd0 < fifo_level;
    DOPUSH    <= data_read;
  end
always @(posedge CLKDO or negedge RSTX_DO)
  if (!RSTX_DO)       dout_cnt <= 6'd0;
  else if (data_read) dout_cnt <= dout_cnt_next;
reg dipull_p2, dipull_p1;
always @(posedge CLKDO or negedge RSTX_DO)
  if (!RSTX_DO) dipull_p2 <= 1'b1;
  else          dipull_p2 <= fifo_level < 6'd8;
always @(posedge CLKDI or negedge RSTX_DI)
  if (!RSTX_DI) begin
    dipull_p1 <= 1'b1;
    DIPULL    <= 1'b1;
  end else begin
    dipull_p1 <= dipull_p2;
    DIPULL    <= dipull_p1;
  end

pseudo_sram #(.BW(BW), .AW(6), .WC(64)) sram (
 .CLKDI (CLKDI),
 .WEN   (dipush_d1),
 .WADDR (din_cnt),
 .DIN   (din_d1),
 .CLKDO (CLKDO),
 .REN   (data_read),
 .RADDR (dout_cnt),
 .DOUT  (DOUT)
);

endmodule
