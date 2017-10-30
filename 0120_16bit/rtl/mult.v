module mult(
 clk,
 rstx,
 mcand_is_signed,
 mlier_is_signed,
 start,
 mcand,
 mlier,
 prod,
 busy
);

parameter BW_CNT = 3,   // ceiling(log2(BW_MLIER));
          BW_MCAND = 3,
          BW_MLIER = 4;

input                          clk;
input                          rstx;
input                          mcand_is_signed;
input                          mlier_is_signed;
input                          start;
input           [BW_MCAND-1:0] mcand;
input           [BW_MLIER-1:0] mlier;
output [BW_MCAND+BW_MLIER-1:0] prod;
output                         busy;

reg [BW_CNT-1:0] cnt;
wire cnt_eq_0 = (cnt == {BW_CNT{1'b0}});
always @(posedge clk or negedge rstx)
  if (~rstx)         cnt <= {BW_CNT{1'b0}};
  else if (start)    cnt <= BW_MLIER;
  else if (cnt_eq_0) cnt <= {BW_CNT{1'b0}};
  else               cnt <= cnt - {{(BW_CNT-1){1'b0}}, 1'd1};

wire cnt_eq_1 = (cnt == {{(BW_CNT-1){1'b0}}, 1'd1});
assign busy = ~cnt_eq_0;

wire last_stage_1 = cnt_eq_1 & mlier_is_signed;

reg [BW_MCAND+BW_MLIER-1:0] prod;

wire [BW_MCAND-1:0] prod1 = (prod[0] ? mcand : {BW_MCAND{1'b0}});

wire [BW_MCAND:0] sum = {   cnt_eq_1
                          ? mcand_is_signed | mlier_is_signed
                          : 1'b0
                        , prod[BW_MCAND+BW_MLIER-1:BW_MLIER] }
                      + { 1'b0
                        ,   {BW_MCAND{last_stage_1}}
                          ^ { prod1[BW_MCAND-1] ^ mcand_is_signed
                            , prod1[BW_MCAND-2:0] } }
                      + {{BW_MCAND{1'b0}}, last_stage_1};

always @(posedge clk or negedge rstx)
  if (~rstx)          prod <= {(BW_MCAND+BW_MLIER){1'b0}};
  else if (start)     prod <= {mcand_is_signed, {(BW_MCAND-1){1'b0}}, mlier};
  else if (~cnt_eq_0) prod <= {sum, prod[BW_MLIER-1:1]};

endmodule
