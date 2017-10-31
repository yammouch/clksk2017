module synth (
 input        RSTX,
 input        CLK,
 input        CLR,
 output [5:0] SEQ
);

seq #(
 .BW_SEQ        (3'd6),
 .SEQ_CNT       (3'd5),
 .BW_SEQ_CNT    (2'd3),
 .RV            (6'b000001),
 .BW_TIMEOUT    (2'd3)
) i_seq (
 .RSTX (RSTX),
 .CLK  (CLK),
 .CLR  (CLR),
 .PTN  ({6'b000001, 3'd0,
         6'b000010, 3'd1,
         6'b000100, 3'd2,
         6'b001000, 3'd3,
         6'b010000, 3'd4,
         6'b100000, 3'd5}),
 .SEQ  (SEQ)
);

endmodule
