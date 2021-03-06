`timescale 1ps/1ps

module tb;

`include "inst.vh"

task init;
begin
  RSTX = 1'b0;
  BTN_UP = 1'b1;
  BTN_DN = 1'b1; #1e6; // 1us
  fg.en = 1'b1;
  repeat (4) @(negedge CLK);
  RSTX = 1'b1;
end
endtask

initial begin
  init;
  #1e9; // 1ms
  $finish;
end

endmodule
