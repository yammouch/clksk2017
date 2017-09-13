module pll_ctrl (
 input            RSTX,
 input            CLK,
 input            BTN_UP,
 input            BTN_DN,
 output reg [6:0] DIGIT0,
 output reg [6:0] DIGIT1,
 output           PLL_LOCK,
 output reg       DIV32,
 output reg       RSTXO
);

reg rstx_d1;
always @(posedge CLK or negedge RSTX)
  if (!RSTX) {RSTXO, rstx_d1} <= 2'b00;
  else       {RSTXO, rstx_d1} <= {rstx_d1, 1'b1};

reg btn_up_d1, btn_dn_d1;
always @(posedge CLK or negedge RSTXO)
  if (!RSTXO) {btn_up_d1, btn_dn_d1} <= 2'b00;
  else        {btn_up_d1, btn_dn_d1} <= {BTN_UP, BTN_DN};
wire btn_up_fall = ~BTN_UP & btn_up_d1;
wire btn_dn_fall = ~BTN_DN & btn_dn_d1;

reg [3:0] saddr;
always @(posedge CLK or negedge RSTXO)
  if (!RSTXO)           saddr <= 4'd0;
  else if (btn_dn_fall) saddr <= saddr - 4'd1;
  else if (btn_up_fall) saddr <= saddr + 4'd1;

reg sen;
always @(posedge CLK or negedge RSTXO)
  if (!RSTXO) sen <= 1'b0;
  else        sen <= btn_up_fall | btn_dn_fall;

always @*
  case (saddr)
  4'd0   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd1000000};
  4'd1   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd1111001};
  4'd2   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd0100100};
  4'd3   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd0110000};
  4'd4   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd0011001};
  4'd5   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd0010010};
  4'd6   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd1000000};
  4'd7   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd1011000};
  4'd8   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd0000000};
  4'd9   : {DIGIT1, DIGIT0} = {7'b1111111, 7'd0010000};
  4'd10  : {DIGIT1, DIGIT0} = {7'b1111001, 7'd1000000};
  4'd11  : {DIGIT1, DIGIT0} = {7'b1111001, 7'd1111001};
  4'd12  : {DIGIT1, DIGIT0} = {7'b1111001, 7'd0100100};
  4'd13  : {DIGIT1, DIGIT0} = {7'b1111001, 7'd0110000};
  4'd14  : {DIGIT1, DIGIT0} = {7'b1111001, 7'd0011001};
  4'd15  : {DIGIT1, DIGIT0} = {7'b1111001, 7'd0010010};
  default: {DIGIT1, DIGIT0} = 14'dx;
  endcase

wire [15:0] do, di;
wire [ 4:0] daddr;
wire drdy, dwe, den, dclk, rst_pll;
pll_drp i_pll_drp(
 .SADDR   (saddr),
 .SEN     (sen),
 .RST     (~RSTXO),
 .SRDY    (),
 .SCLK    (CLK),
 .DO      (do),
 .DRDY    (drdy),
 .LOCKED  (PLL_LOCK),
 .DWE     (dwe),
 .DEN     (den),
 .DADDR   (daddr),
 .DI      (di),
 .DCLK    (dclk),
 .RST_PLL (rst_pll)
);

PLL_ADV #(
 .SIM_DEVICE         ("SPARTAN6"),
 .DIVCLK_DIVIDE      (1),
 .BANDWIDTH          ("LOW"),
 .CLKFBOUT_MULT      (8), 
 .CLKFBOUT_PHASE     (0.0),
 .REF_JITTER         (0.100),
 .CLKIN1_PERIOD      (10.000),
 .CLKIN2_PERIOD      (10.000), 
 .CLKOUT0_DIVIDE     (8),
 .CLKOUT0_DUTY_CYCLE (0.5),
 .CLKOUT0_PHASE      (0.0), 
 .CLKOUT1_DIVIDE     (8), 
 .CLKOUT1_DUTY_CYCLE (0.5),
 .CLKOUT1_PHASE      (0.0), 
 .CLKOUT2_DIVIDE     (8),
 .CLKOUT2_DUTY_CYCLE (0.5),
 .CLKOUT2_PHASE      (0.0),
 .CLKOUT3_DIVIDE     (8),
 .CLKOUT3_DUTY_CYCLE (0.5),
 .CLKOUT3_PHASE      (0.0),
 .CLKOUT4_DIVIDE     (8),
 .CLKOUT4_DUTY_CYCLE (0.5),
 .CLKOUT4_PHASE      (0.0), 
 .CLKOUT5_DIVIDE     (8),
 .CLKOUT5_DUTY_CYCLE (0.5),
 .CLKOUT5_PHASE      (0.0),
 .COMPENSATION       ("SYSTEM_SYNCHRONOUS"),
 .EN_REL             ("FALSE"),
 .PLL_PMCD_MODE      ("FALSE"),
 .RST_DEASSERT_CLK   ("CLKIN1")
) i_pll_adv (
);

endmodule
