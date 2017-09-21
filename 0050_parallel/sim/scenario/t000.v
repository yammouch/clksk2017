`timescale 1ps/1ps

module tb;

`include "inst.vh"

task init;
begin
  RSTX = 1'b0;
  CLR  = 1'b1;
end
endtask

task test_main;
begin
  fg.en = 1'b1;
  repeat (4) @(negedge CLK);
  RSTX = 1'b1;
  repeat (4) @(negedge CLK);
  CLR = 1'b1;
  #1e9; // 1ms
end
endtask

initial begin
  init;
  test_main;
  $finish;
end

endmodule
