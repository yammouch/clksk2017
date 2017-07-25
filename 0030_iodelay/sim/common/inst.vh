reg  rst;
reg  iodelay_rst;
reg  iodelay_cal;
reg  dinp;
reg  dinn;
wire clk_in;

tb_clk_gen clk_gen(.CLK(clk_in));

clksk dut(
 .clk_in        (clk_in),
 .rst           (rst),
 .iodelay_rst   (iodelay_rst),
 .iodelay_cal   (iodelay_cal),
 .dinp          (dinp),
 .dinn          (dinn),
 .dout          (),
 .pll_clk_out_p (),
 .pll_clk_out_n (),
 .iodelay_busy  ()
);
