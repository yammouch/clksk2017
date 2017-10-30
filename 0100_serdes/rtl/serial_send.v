module serial_send (
 input         RSTXS,
 input         RSTXF,
 input         CLKS,
 input         CLKSS,
 input         CLKF,
 input         CLKF_DATA,
 input         SERDESSTROBE,
 input  [15:0] DIN,
 output [ 1:0] DOUT
);

reg [15:0] din_d1 = 16'd0;
always @(posedge CLKF) din_d1 <= DIN;

reg clkf_d1 = 1'b0, clkf_d2 = 1'b0;
always @(posedge CLKS) {clkf_d2, clkf_d1} <= {clkf_d1, CLKF_DATA};

reg [15:0] shift = 16'd0;
always @(posedge CLKS)
  if (!clkf_d1 && clkf_d2) shift <= din_d1;
  else                     shift <= {shift[11:0], 4'd0};

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
 .D1        (shift[15]),
 .D2        (shift[14]),
 .D3        (shift[13]),
 .D4        (shift[12]),
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
