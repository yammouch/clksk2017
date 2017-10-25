module pll_ctrl (
 input            CLK,
 input      [7:0] PLL_ADDR,
 input            PLL_CHG,
 output           RSTXO,
 output           CLKS,
 output reg       RSTXS,
 output reg       CLKF,
 output reg       RSTXF
);

reg rstx_d1, rstx_d2;
initial {rstx_d2, rstx_d1} = 2'b00;
always @(posedge CLK) {rstx_d2, rstx_d1} <= {rstx_d1, 1'b1};

pulse_extend #(.CBW(4), .RV(1'b1)) i_pex (
 .CYCLE (4'd15),
 .CLK   (CLK),
 .RSTX  (1'b1),
 .DIN   (rstx_d2),
 .DOUT  (RSTXO)
);

wire [15:0] do, di;
wire [ 4:0] daddr;
wire drdy, dwe, den, rst_pll, pll_lock;
pll_drp i_pll_drp(
 .SADDR   (PLL_ADDR),
 .SEN     (PLL_CHG),
 .RST     (~RSTXO),
 .SRDY    (),
 .SCLK    (CLK),
 .DO      (do),
 .DRDY    (drdy),
 .LOCKED  (pll_lock),
 .DWE     (dwe),
 .DEN     (den),
 .DADDR   (daddr),
 .DI      (di),
 .DCLK    (),
 .RST_PLL (rst_pll)
);

PLL_ADV #(
 .SIM_DEVICE         ("SPARTAN6"),
 .DIVCLK_DIVIDE      (1),
 .BANDWIDTH          ("LOW"),
 .CLKFBOUT_MULT      (40), 
 .CLKFBOUT_PHASE     (0.0),
 .REF_JITTER         (0.100),
 .CLKIN1_PERIOD      (50.000),
 .CLKIN2_PERIOD      (50.000), 
 .CLKOUT0_DIVIDE     (20),
 .CLKOUT0_DUTY_CYCLE (0.5),
 .CLKOUT0_PHASE      (0.0), 
 .CLKOUT1_DIVIDE     (128), 
 .CLKOUT1_DUTY_CYCLE (0.5),
 .CLKOUT1_PHASE      (0.0), 
 .CLKOUT2_DIVIDE     (128),
 .CLKOUT2_DUTY_CYCLE (0.5),
 .CLKOUT2_PHASE      (0.0),
 .CLKOUT3_DIVIDE     (128),
 .CLKOUT3_DUTY_CYCLE (0.5),
 .CLKOUT3_PHASE      (0.0),
 .CLKOUT4_DIVIDE     (128),
 .CLKOUT4_DUTY_CYCLE (0.5),
 .CLKOUT4_PHASE      (0.0), 
 .CLKOUT5_DIVIDE     (128),
 .CLKOUT5_DUTY_CYCLE (0.5),
 .CLKOUT5_PHASE      (0.0),
 .COMPENSATION       ("SYSTEM_SYNCHRONOUS"),
 .EN_REL             ("FALSE"),
 .PLL_PMCD_MODE      ("FALSE"),
 .RST_DEASSERT_CLK   ("CLKIN1")
) i_pll_adv (
 .DO         (do),
 .DRDY       (drdy),
 .LOCKED     (pll_lock),
 .DWE        (dwe),
 .DEN        (den),
 .DADDR      (daddr),
 .DI         (di),
 .DCLK       (CLK),
 .RST        (rst_pll),
 .CLKIN2     (1'b0),
 .CLKINSEL   (1'b1),
 .REL        (1'b0),
 .CLKIN1     (CLK),
 .CLKFBIN    (clkfb),
 .CLKOUT0    (CLKS),
 .CLKOUT1    (),
 .CLKOUT2    (),
 .CLKOUT3    (),
 .CLKOUT4    (),
 .CLKOUT5    (),
 .CLKFBOUT   (clkfb),
 .CLKOUTDCM0 (),
 .CLKOUTDCM1 (),
 .CLKOUTDCM2 (),
 .CLKOUTDCM3 (),
 .CLKOUTDCM4 (),
 .CLKOUTDCM5 (),
 .CLKFBDCM   ()
);

reg rstxs_p1;
always @(posedge CLKS or negedge RSTXO)
  if (!RSTXO) {RSTXS, rstxs_p1} <= 2'b00;
  else        {RSTXS, rstxs_p1} <= {rstxs_p1, pll_lock};

reg div2,  div2_d1;
reg div4,  div4_d1;
reg div8,  div8_d1;
reg div16, div16_d1;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) begin
    div2_d1  <= 1'b0;
    div4_d1  <= 1'b0;
    div8_d1  <= 1'b0;
    div16_d1 <= 1'b0;
  end else begin
    div2_d1  <= div2;
    div4_d1  <= div4;
    div8_d1  <= div8;
    div16_d1 <= div16;
  end
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS) div2 <= 1'b0;
  else        div2 <= ~div2;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS)               div4 <= 1'b0;
  else if (div2 & ~div2_d1) div4 <= ~div4;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS)               div8 <= 1'b0;
  else if (div4 & ~div4_d1) div8 <= ~div8;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS)               div16 <= 1'b0;
  else if (div8 & ~div8_d1) div16 <= ~div16;
always @(posedge CLKS or negedge RSTXS)
  if (!RSTXS)                 CLKF <= 1'b0;
  else if (div16 & ~div16_d1) CLKF <= ~CLKF;

reg rstxf_p1;
always @(posedge CLKF or negedge RSTXO)
  if (!RSTXO) {RSTXF, rstxf_p1} <= 2'b00;
  else        {RSTXF, rstxf_p1} <= {rstxf_p1, pll_lock};

endmodule
