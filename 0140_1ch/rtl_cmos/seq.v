module seq #(
 parameter BW_SEQ        = 3'd4,
           SEQ_CNT       = 3'd7,
           BW_SEQ_CNT    = 2'd3,
           RV            = {BW_SEQ{1'b0}},
           BW_TIMEOUT    = 2'd2
) (
 input                                            RSTX,
 input                                            CLK,
 input                                            CLR,
 input      [(BW_SEQ+BW_TIMEOUT)*(SEQ_CNT+1)-1:0] PTN, 
 output reg [                         BW_SEQ-1:0] SEQ
);

wire [BW_SEQ_CNT-1:0] cnt_next, cnt;
wire                  cnt0;

cnt_down #(.BW(BW_SEQ_CNT)) i_cnt_down_p (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .LOAD     (CLR),
 .VAL      (SEQ_CNT),
 .DEC      (cnt0),
 .CNT_NEXT (cnt_next),
 .CNT      (cnt),
 .CNT0     ()
);

reg [BW_TIMEOUT-1:0] timeout;
always @*
  timeout =  PTN
          >> ( (BW_TIMEOUT+BW_SEQ) * {16'd0, cnt_next} );

cnt_down #(.BW(BW_TIMEOUT)) i_cnt_down_s (
 .RSTX     (RSTX),
 .CLK      (CLK),
 .LOAD     (CLR),
 .VAL      (timeout),
 .DEC      (1'b1),
 .CNT_NEXT (),
 .CNT      (),
 .CNT0     (cnt0)
);

always @(posedge CLK or negedge RSTX)
  if (!RSTX) SEQ <= RV;
  else       SEQ <= PTN >> ( (BW_TIMEOUT+BW_SEQ)*{16'd0, cnt}+BW_TIMEOUT);

endmodule
