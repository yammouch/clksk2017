module serial_recv (
 input             RSTXS,
 input             CLKS,
 input             CLKF,
 input             CLKF_DATA,
 input             PHY_INIT,
 input      [ 1:0] DIN,
 output reg [15:0] DOUT
);

wire din_se, din_delay;

IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("LVDS_33")) i_ibufds (
 .I(DIN[0]), .IB(DIN[1]), .O(din_se) );

IODELAY2 #(
 .DATA_RATE   ("DDR"),
 .DELAY_SRC   ("IDATAIN"),
 .IDELAY_TYPE ("VARIABLE_FROM_ZERO")
) i_iodelay2(
 .IDATAIN  (din_se),
 .T        (1'b1),
 .ODATAIN  (1'b0),
 .IOCLK1   (CLKS),
 .INC      (1'b0),
 .CE       (1'b0),
 .CAL      (PHY_INIT),
 .IOCLK0   (!CLKS),
 .CLK      (CLKF),
 .RST      (~RSTXS),
 .DATAOUT  (din_delay),
 .DATAOUT2 (),
 .TOUT     (),
 .DOUT     (),
 .BUSY     ()
);

wire [1:0] ddr;

IDDR2 #(
 .DDR_ALIGNMENT ("C0"),
 .SRTYPE        ("ASYNC")
) i_iddr2(
 .D(din_delay),
 .C0 (CLKS),
 .C1 (~CLKS),
 .CE (1'b1),
 .R  (~RSTXS),
 .S  (1'b0),
 .Q0 (ddr[0]),
 .Q1 (ddr[1])
);

reg [15:0] shift;
always @(posedge CLKS) shift <= {shift[13:0], ddr};

reg clkf_d1, clkf_d2;
always @(posedge CLKS) {clkf_d2, clkf_d1} <= {clkf_d1, CLKF_DATA};

always @(posedge CLKS) if (clkf_d1 && !clkf_d2) DOUT <= shift;

endmodule
