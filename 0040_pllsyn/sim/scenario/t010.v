`timescale 1ps/1ps

module tb;

`include "inst.vh"

task init;
begin
  RSTX   = 1'b0;
  BTN_UP = 1'b1;
  BTN_DN = 1'b1;
end
endtask

task test_main;
begin
  fg.en  = 1'b1; #1e6; // 1us
  RSTX   = 1'b1; #5e6; // 5us
  BTN_UP = 1'b0; #40e9; // 40ms
  BTN_UP = 1'b1; #40e9; // 40ms
  BTN_DN = 1'b0; #40e9; // 40ms
  BTN_DN = 1'b1; #40e9; // 40ms
end
endtask

initial begin
  init;
  test_main;
  $finish;
end

endmodule
