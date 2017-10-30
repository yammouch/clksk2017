module parallel_recv (
 input             RSTX,
 input             CLK,
 input             CLR,
 input             ALIGNED,
 input             DIPUSH,
 input      [ 7:0] DIN,
 input             INIT,

 output reg [63:0] ERR_CNT,
 output reg [57:0] RECV_CNT
);

wire divalid = ALIGNED & DIPUSH;

reg divalid_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)    divalid_d1 <= 1'b0;
  else if (CLR) divalid_d1 <= 1'b0;
  else          divalid_d1 <= divalid;

reg [7:0] din_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)       din_d1 <= 8'd0;
  else if (CLR)    din_d1 <= 8'd0;
  else if (DIPUSH) din_d1 <= DIN;

reg [10:0] rcnt;
reg        init_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) init_d1 <= 1'b0;
  else       init_d1 <= INIT;
wire rcnt_m1 = rcnt == ~11'd0;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)            rcnt <= ~11'd0;
  else if (CLR)         rcnt <= ~11'd0;
  else if (init_d1)     rcnt <= 11'd1023;
  else if (!divalid_d1) rcnt <= rcnt;
  else if (rcnt_m1)     rcnt <= ~11'd0;
  else                  rcnt <= rcnt - 11'd1;

reg  [8:0] ref_data;
wire [8:0] ref_data_inc;
lfsr32x2 i_lfsr32x2 (.DIN(ref_data), .DOUT(ref_data_inc));

always @(posedge CLK or negedge RSTX)
  if (!RSTX)                    ref_data <= 8'd0;
  else if (CLR)                 ref_data <= 8'd0;
  else if (divalid && !rcnt_m1) ref_data <= ref_data_inc;

reg [2:0] err_word;
integer i;
always @* begin
  err_word = 3'd0;
  for (i = 0; i < 8; i = i+1)
    if (din_d1[i] != ref_data[i]) err_word = err_word + 4'd1;
end

wire [64:0] sum = ERR_CNT + {62'd0, err_word};
wire recv = divalid_d1 && !rcnt_m1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)        ERR_CNT <= 64'd0;
  else if (CLR)     ERR_CNT <= 64'd0;
  else if (!recv)   ERR_CNT <= ERR_CNT;
  else if (sum[64]) ERR_CNT <= ~64'd0;
  else              ERR_CNT <= sum[63:0];

always @(posedge CLK or negedge RSTX)
  if (!RSTX)    RECV_CNT <= 58'd0;
  else if (CLR) RECV_CNT <= 58'd0;
  else          RECV_CNT <= RECV_CNT + {57'd0, recv};

endmodule
