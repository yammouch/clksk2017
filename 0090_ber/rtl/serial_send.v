module serial_send (
 input         RSTXS,
 input         RSTXF,
 input         CLKS,
 input         CLKF,
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
  else                          shift <= {shift[61:0], 2'd0};

wire ddr;
ODDR2 #(
 .DDR_ALIGNMENT ("C0"),
 .SRTYPE        ("ASYNC")
) i_oddr2 (
 .D0 (shift[63]),
 .D1 (shift[62]),
 .C0 (CLKS),
 .C1 (~CLKS),
 .CE (1'b1),
 .R  (~RSTXS),
 .S  (1'b0),
 .Q  (ddr)
);

OBUFDS #(.IOSTANDARD("LVDS_33")) i_obufds (
 .I(ddr), .OB(DOUT[1]), .O(DOUT[0]) );

endmodule
