`timescale 1ps/1ps

module tb;

`include "inst.vh"

initial begin
  rst = 1'b1;
  iodelay_rst = 1'b0;
  iodelay_cal = 1'b0;
  assign dinp = dut.pll_clk_out_p;
  assign dinn = dut.pll_clk_out_n;

  #100_000; // 0.1us
  clk_gen.en = 1'b1;
  repeat (4) @(negedge clk_in);
  rst = 1'b0;
  #10e6; // 10us
  @(negedge clk_in); iodelay_cal = 1'b1;
  @(negedge clk_in); iodelay_cal = 1'b0;
  #10e6; // 10us
  $finish;
end

endmodule
