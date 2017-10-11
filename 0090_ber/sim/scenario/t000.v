`timescale 1ps/1ps

module tb;

`include "inst.vh"

initial begin
  fg.en = 1'b1; #1e9; // 1ms
  $finish;
end

endmodule
