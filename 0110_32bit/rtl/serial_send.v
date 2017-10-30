module serial_send (
 input         RSTXS,
 input         RSTXF,
 input         CLKS,
 input         CLKF,
 input         CLKF_DATA,
 input  [31:0] DIN,
 output [ 1:0] DOUT
);

reg [31:0] din_d1;
always @(posedge CLKF) din_d1 <= DIN;

reg clkf_d1, clkf_d2;
always @(posedge CLKS) {clkf_d2, clkf_d1} <= {clkf_d1, CLKF_DATA};

reg [31:0] shift;
always @(posedge CLKS)
  if (!clkf_d1 && clkf_d2) shift <= din_d1;
  else                     shift <= {shift[29:0], 2'd0};

wire ddr;
ODDR2 #(
 .DDR_ALIGNMENT ("C0"),
 .SRTYPE        ("ASYNC")
) i_oddr2 (
 .D0 (shift[31]),
 .D1 (shift[30]),
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
