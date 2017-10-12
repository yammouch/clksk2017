module cnt_down #(parameter BW = 'd8) (
 input               RSTX,
 input               CLK,
 input               DEC,
 input               LOAD,
 input      [BW-1:0] VAL,
 output              CNT0,
 output reg [BW-1:0] CNT,
 output     [BW-1:0] CNT_NEXT
);

assign CNT_NEXT = LOAD ? VAL
                : !DEC ? CNT
                : CNT0 ? VAL
                :        CNT + {BW{1'b1}};
always @(posedge CLK or negedge RSTX)
  if (!RSTX) CNT <= {BW{1'b0}};
  else       CNT <= CNT_NEXT;
assign CNT0 = CNT == {BW{1'b0}};

endmodule
