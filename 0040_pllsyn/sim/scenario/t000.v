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
  RSTX   = 1'b1; #1e9; // 1ms
  repeat (20) begin
    BTN_UP = 1'b0; #100e9;  // 100ms
    BTN_UP = 1'b1; #1900e9; // 1900ms
  end
  repeat (20) begin
    BTN_DN = 1'b0; #100e9;  // 100ms
    BTN_DN = 1'b1; #1900e9; // 1900ms
  end
end
endtask

initial begin
  test_main;
  $finish;
end

endmodule
