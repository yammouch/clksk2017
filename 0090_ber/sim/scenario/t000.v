`timescale 1ps/1ps

module tb;

`include "inst.vh"

initial begin
  tap_sel = 8'd0;
  BTN_1   = 1'b1;
  BTN_2   = 1'b1;
  BTN_3   = 1'b1;
  fg.en   = 1'b1; #1e9; // 1ms
  wait (lvds_p[63:0] == 64'd0);
  repeat (4) begin
    tap_sel = tap_sel + 8'd1; #1e9;
    wait (lvds_p[63:0] == 64'd0);
  end
  $finish;
end

endmodule
