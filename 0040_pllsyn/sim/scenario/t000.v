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
  force dut.i_dechat_up.TIMEOUT = 19'd19; // 1us
  force dut.i_dechat_dn.TIMEOUT = 19'd19; // 1us
  fg.en  = 1'b1; #1e6; // 1us
  RSTX   = 1'b1; #5e6; // 5us
  repeat (20) begin
    BTN_UP = 1'b0; #2e6;  // 2us
    BTN_UP = 1'b1; #28e6; // 28us
  end
  repeat (20) begin
    BTN_DN = 1'b0; #2e6;  // 2us
    BTN_DN = 1'b1; #28e6; // 28us
  end
end
endtask

initial begin
  init;
  test_main;
  $finish;
end

endmodule
