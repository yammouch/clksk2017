module div #(
 parameter BW_CNT  = 'd2,
           BW_DEND = 'd4,
           BW_DSOR = 'd3) (
 input                RSTX,
 input                CLK,
 input                CLR,
 input  [BW_DSOR-1:0] DIVISOR,
 input  [BW_DEND-1:0] DIVIDEND,
 input                START,
 output [BW_DSOR-1:0] REM,
 output [BW_DEND-1:0] QUOT,
 output               BUSY
);

reg [BW_CNT-1:0] cnt;
assign BUSY = cnt != {BW_CNT{1'b0}};
always @(posedge CLK or negedge RSTX)
  if (!RSTX)      cnt <= {BW_CNT{1'b0}};
  else if (START) cnt <= BW_DEND - 1;
  else if (BUSY)  cnt <= cnt + {BW_CNT{1'b1}};
  else            cnt <= {BW_CNT{1'b0}};

reg [BW_DEND+BW_DSOR-1:0] shift_reg;
wire [BW_DEND+BW_DSOR-1:0] minuend = START ? { {BW_DSOR{1'b0}}, DIVIDEND }
                                   :         shift_reg;

wire [BW_DSOR:0] diff = minuend[BW_DEND+BW_DSOR-1:BW_DEND-1]
                      - {1'b0, DIVISOR};

always @(posedge CLK or negedge RSTX)
  if (!RSTX)
    shift_reg <= {(BW_DEND+BW_DSOR){1'b0}};
  else if (BUSY || START)
    shift_reg <=
    {   diff[BW_DSOR]
      ? minuend[BW_DEND+BW_DSOR-2:BW_DEND-1]
      : diff[BW_DSOR-1:0]
    , minuend[BW_DEND-2:0]
    , !diff[BW_DSOR] };

assign QUOT = shift_reg[BW_DEND-1:0];
assign REM  = shift_reg[BW_DSOR+BW_DEND-1:BW_DEND];

endmodule
