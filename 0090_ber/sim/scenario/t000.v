`timescale 1ps/1ps

module tb;

`include "inst.vh"

initial begin
  BTN_1 = 1'b1;
  BTN_2 = 1'b1;
  BTN_3 = 1'b1;
  fg.en = 1'b1; #1e9; // 1ms
  $finish;
end

endmodule
