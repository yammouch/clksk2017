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
  //force dut.i_handle_7seg.i_cnt_down_s.VAL     = 25'd4095;
  force dut.i_button_ctrl.i_dechat_bt1.TIMEOUT = 25'd255;
  force dut.i_button_ctrl.i_dechat_bt2.TIMEOUT = 25'd255;
  force dut.i_button_ctrl.i_dechat_bt3.TIMEOUT = 25'd255;
end
endtask

task set_sub_mode;
begin
  #24e6; // 24us
  BTN_3 = 1'b0; #24e6; // 24us
  repeat (3) begin // SUB_MODE -> 3
    BTN_2 = 1'b0; #24e6; // 24us
    BTN_2 = 1'b1; #24e6; // 24us
  end
  BTN_3 = 1'b1; #24e6; // 24us
end
endtask

function [3:0] decode_7seg(input [6:0] seg);
  case (seg)
  7'b0111111: decode_7seg = 4'd0;
  7'b0000110: decode_7seg = 4'd1;
  7'b1011011: decode_7seg = 4'd2;
  7'b1001111: decode_7seg = 4'd3;
  7'b1100110: decode_7seg = 4'd4;
  7'b1101101: decode_7seg = 4'd5;
  7'b1111101: decode_7seg = 4'd6;
  7'b0100111: decode_7seg = 4'd7;
  7'b1111111: decode_7seg = 4'd8;
  7'b1101111: decode_7seg = 4'd9;
  default   : decode_7seg = 4'dx;
  endcase
endfunction

task test1(input [31:0] f_hdl);
integer dig0, dig1, dig2, dig3;
real ber, ber_exp;
begin
  wait (lvds_p[63:0] == 64'hAAAA_AAAA_AAAA_AAAA);
  wait (lvds_p[63:0] == 64'h0000_0000_0000_0000);
  repeat (16*256) @(dut.i_pll_ctrl.CLKSS);
  lvds_p[64] = !lvds_p[64];
  lvds_n[64] = !lvds_n[64];
  repeat (16*256) @(dut.i_pll_ctrl.CLKSS);
  lvds_p[64] = !lvds_p[64];
  lvds_n[64] = !lvds_n[64];
  wait (lvds_p[63:0] == 64'h0000_0000_0000_0000);
  wait (lvds_p[63:0] == 64'hAAAA_AAAA_AAAA_AAAA);
  if (dut.i_stimulus.ERR_CNT == 64'd2) $fwrite(f_hdl, "[OK]");
  else                                 $fwrite(f_hdl, "[ER]");
  $fwrite(f_hdl, " ERR_CNT %d, expected 2\n", dut.i_stimulus.ERR_CNT);
  if (dut.i_stimulus.RECV_CNT == 58'h00_0000_0000_0400) $fwrite(f_hdl, "[OK]");
  else                                                  $fwrite(f_hdl, "[ER]");
  $fwrite(f_hdl, " RECV_CNT 'h%x, expected 'h400\n", dut.i_stimulus.RECV_CNT);
  wait (dut.i_handle_7seg.i_ber_7seg.BUSY == 1'b1);
  wait (dut.i_handle_7seg.i_ber_7seg.BUSY == 1'b0);
  @(posedge CLK);

  dig0 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT0);
  dig1 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT1);
  dig2 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT2);
  dig3 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT3);

  ber = (dig3 + 0.1*dig2)*0.1**(10*dig1 + dig0);
  ber_exp = 2.0 / (1024*16);

  if (0.9*ber_exp <= ber && ber <= 1.1*ber_exp)
    $fwrite(f_hdl, "[OK]");
  else
    $fwrite(f_hdl, "[NG] @ %6.3f [ms]", $time*1e-9);
  $fwrite(f_hdl, " ber val: %e, exp [%e, %e]\n", ber, ber_exp*0.9, ber_exp*1.1);
end
endtask

task test_main;
reg [31:0] f_hdl;
begin
  f_hdl = $fopen("result/t010.log");
  fork
    begin
      init;
      set_sub_mode;
      test1(f_hdl);
      #24e6; // 24us
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
