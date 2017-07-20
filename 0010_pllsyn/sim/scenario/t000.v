`timescale 1ps/1ps

module tb;

`include "inst.vh"

initial begin
  rst = 1'b1;

  #100_000; // 0.1us
  clk_gen.en = 1'b1;
  repeat (4) @(negedge clk_in);
  rst = 1'b0;
  #1e9; // 1ms
  $finish;
end

endmodule
