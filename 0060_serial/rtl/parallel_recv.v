module parallel_recv (
 input             RSTX,
 input             CLK,
 input             CLR,
 input             ALIGNED,
 input             DIPUSH,
 input      [63:0] DIN,
 input             INIT,

 output reg [ 7:0] ERR_CNT
);

wire divalid = ALIGNED & DIPUSH;

reg divalid_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)    divalid_d1 <= 1'b0;
  else if (CLR) divalid_d1 <= 1'b0;
  else          divalid_d1 <= divalid;

reg [63:0] din_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)       din_d1 <= 64'd0;
  else if (CLR)    din_d1 <= 64'd0;
  else if (DIPUSH) din_d1 <= DIN;

reg [10:0] recv_cnt;
reg        init_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) init_d1 <= 1'b0;
  else       init_d1 <= INIT;
wire recv_cnt_m1 = recv_cnt == ~11'd0;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)            recv_cnt <= ~11'd0;
  else if (CLR)         recv_cnt <= ~11'd0;
  else if (init_d1)     recv_cnt <= 11'd1023;
  else if (!divalid)    recv_cnt <= recv_cnt;
  else if (recv_cnt_m1) recv_cnt <= ~11'd0;
  else                  recv_cnt <= recv_cnt - 11'd1;

reg [63:0] ref_data;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)                        ref_data <= 64'd0;
  else if (CLR)                     ref_data <= 64'd0;
  else if (divalid && !recv_cnt_m1) ref_data <= ref_data + 64'd1;

always @(posedge CLK or negedge RSTX)
  if (!RSTX)                 ERR_CNT <= 8'd0;
  else if (CLR)              ERR_CNT <= 8'd0;
  else if (!(divalid_d1 && din_d1 != ref_data && !recv_cnt_m1))
                             ERR_CNT <= ERR_CNT;
  else if (ERR_CNT == ~8'd0) ERR_CNT <= ~8'd0;
  else                       ERR_CNT <= ERR_CNT + 8'd1;

endmodule
