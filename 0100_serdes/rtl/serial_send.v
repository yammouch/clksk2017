module serial_send (
 input         RSTXS,
 input         RSTXF,
 input         CLKS,
 input         CLKSS,
 input         CLKF,
 input         SERDESSTROBE,
 input  [63:0] DIN,
 output [ 1:0] DOUT
);

reg [63:0] din_d1;
always @(posedge CLKF or negedge RSTXF)
  if (!RSTXF) din_d1 <= 64'd0;
  else        din_d1 <= DIN;

reg clkf_d1, clkf_d2;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) {clkf_d2, clkf_d1} <= 2'b00;
  else        {clkf_d2, clkf_d1} <= {clkf_d1, CLKF};

reg [63:0] shift;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) shift <= 64'd0;
  else if (!clkf_d1 && clkf_d2) shift <= din_d1;
  else                          shift <= {shift[59:0], 4'd0};

wire ddr;
OSERDES2 #(
 .DATA_RATE_OQ  ("SDR"),
 .DATA_RATE_OT  ("SDR"),
 .DATA_WIDTH    (4),
 .OUTPUT_MODE   ("SINGLE_ENDED"),
 .SERDES_MODE   ("NONE"),
 .TRAIN_PATTERN (0)
) i_oserdes2 (
 .CLK0      (CLKSS),
 .CLK1      (1'b0),
 .CLKDIV    (CLKS),
 .IOCE      (SERDESSTROBE),
 .D1        (shift[63]),
 .D2        (shift[62]),
 .D3        (shift[61]),
 .D4        (shift[60]),
 .OCE       (1'b1),
 .RST       (!RSTXS),
 .T1        (1'b0),
 .T2        (1'b0),
 .T3        (1'b0),
 .T4        (1'b0),
 .TCE       (1'b1),
 .SHIFTIN1  (1'b0),
 .SHIFTIN2  (1'b0),
 .SHIFTIN3  (1'b0),
 .SHIFTIN4  (1'b0),
 .TRAIN     (1'b0),
 .OQ        (ddr),
 .TQ        (),
 .SHIFTOUT1 (),
 .SHIFTOUT2 (),
 .SHIFTOUT3 (),
 .SHIFTOUT4 ()
);

OBUFDS #(.IOSTANDARD("LVDS_33")) i_obufds (
 .I(ddr), .OB(DOUT[1]), .O(DOUT[0]) );

endmodule
