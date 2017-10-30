`timescale 1ps/1ps

module tb;

`include "inst.vh"

task init;
begin
  tap_sel = 8'd128;
  BTN_1   = 1'b1;
  BTN_2   = 1'b1;
  BTN_3   = 1'b1;
  fg.en   = 1'b1;
end
endtask

task test1(input [31:0] f_hdl);
begin
  wait (lvds_p[63:0] == 64'hAAAA_AAAA_AAAA_AAAA);
  wait (lvds_p[63:0] == 64'h0000_0000_0000_0000);
  repeat (64*256) @(dut.i_pll_ctrl.CLKS);
  lvds_p[64] = !lvds_p[64];
  lvds_n[64] = !lvds_n[64];
  repeat (64*256) @(dut.i_pll_ctrl.CLKS);
  lvds_p[64] = !lvds_p[64];
  lvds_n[64] = !lvds_n[64];
  wait (lvds_p[63:0] == 64'h0000_0000_0000_0000);
  wait (lvds_p[63:0] == 64'hAAAA_AAAA_AAAA_AAAA);
  if (dut.i_lvds1.ERR_CNT == 64'd2) $fwrite(f_hdl, "[OK]");
  else                              $fwrite(f_hdl, "[ER]");
  $fwrite(f_hdl, " ERR_CNT %d, expected 2\n", dut.i_lvds1.ERR_CNT);
  if (dut.i_lvds1.RECV_CNT == 58'h00_0000_0000_0400) $fwrite(f_hdl, "[OK]");
  else                                               $fwrite(f_hdl, "[ER]");
  $fwrite(f_hdl, " RECV_CNT 'h%x, expected 'h400\n", dut.i_lvds1.RECV_CNT);
end
endtask

task test_main;
reg [31:0] f_hdl;
begin
  f_hdl = $fopen("result/t010.log");
  fork
    begin
      init;
      test1(f_hdl);
      $fclose(f_hdl);
      $finish;
    end
    begin
      #10e9; // 10ms
      $fdisplay(f_hdl, "[ER] simulation timeout.");
      $fclose(f_hdl);
      $finish;
    end
  join
end
endtask

initial begin
  test_main;
end

endmodule
