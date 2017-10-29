module cnt10 (
 input            RSTX,
 input            CLK,
 input            CLR,
 input      [7:0] UBND,
 input            ADD1,
 input            ADD10,
 input            SUB1,
 input            SUB10,
 output reg [7:0] CNT
);

wire [8:0] cnt_added = ADD1  ? {1'b0, CNT} + 9'd1
                     : ADD10 ? {1'b0, CNT} + 9'd10
                     : SUB1  ? {1'b0, CNT} - 9'd1
                     :         {1'b0, CNT} - 9'd10;

always @(posedge CLK or negedge RSTX)
  if (!RSTX)                                  CNT <= 8'd0;
  else if (CLR)                               CNT <= 8'd0;
  else if (!(ADD1 || ADD10 || SUB1 || SUB10)) CNT <= CNT;
  else if (cnt_added[8])                      CNT <= 8'd0;
  else                                        CNT <= cnt_added[7:0];

endmodule
