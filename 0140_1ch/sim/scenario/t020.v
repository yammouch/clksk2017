// align sliding

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
  force dut.i_button_ctrl.i_dechat_bt1.TIMEOUT = 25'd255;
  force dut.i_button_ctrl.i_dechat_bt2.TIMEOUT = 25'd255;
  force dut.i_button_ctrl.i_dechat_bt3.TIMEOUT = 25'd255;
end
endtask

task inc_sub_mode(input [31:0] n);
begin
  #24e6; // 24us
  BTN_3 = 1'b0; #24e6; // 24us
  repeat (n) begin
    BTN_2 = 1'b0; #24e6; // 24us
    BTN_2 = 1'b1; #24e6; // 24us
  end
  BTN_3 = 1'b1; #24e6; // 24us
end
endtask

task dec_sub_mode(input [31:0] n);
begin
  #24e6; // 24us
  BTN_3 = 1'b0; #24e6; // 24us
  repeat (n) begin
    BTN_1 = 1'b0; #24e6; // 24us
    BTN_1 = 1'b1; #24e6; // 24us
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

task compare_err_cnt(
 input [31:0] f_hdl,
 input [59:0] recv_cnt_exp,
 input [63:0] err_cnt_exp);
begin
  if (dut.i_stimulus.ERR_CNT == err_cnt_exp)
    $fwrite(f_hdl, "[OK]");
  else
    $fwrite(f_hdl, "[ER] @ %6.3f [ms]", $time*1e-9);
  $fwrite(f_hdl, " ERR_CNT %d, expected %d\n",
          dut.i_stimulus.ERR_CNT, err_cnt_exp);

  if (dut.i_stimulus.RECV_CNT == recv_cnt_exp)
    $fwrite(f_hdl, "[OK]");
  else
    $fwrite(f_hdl, "[ER] @ %6.3f [ms]", $time*1e-9);
  $fwrite(f_hdl, " RECV_CNT 'h%x, expected 'h%x\n",
          dut.i_stimulus.RECV_CNT, recv_cnt_exp);
end
endtask

task compare_ber(input [31:0] f_hdl, input [63:0] exp);
integer dig0, dig1, dig2, dig3;
real ber, ber_exp;
begin
  dig0 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT0);
  dig1 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT1);
  dig2 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT2);
  dig3 = decode_7seg(dut.i_handle_7seg.i_ber_7seg.DIGIT3);

  ber = (dig3 + 0.1*dig2)*0.1**(10*dig1 + dig0);
  ber_exp = $bitstoreal(exp);

  if (0.9*ber_exp <= ber && ber <= 1.1*ber_exp)
    $fwrite(f_hdl, "[OK]");
  else
    $fwrite(f_hdl, "[ER] @ %6.3f [ms]", $time*1e-9);
  $fwrite(f_hdl, " ber val: %e, exp [%e, %e]\n", ber, ber_exp*0.9, ber_exp*1.1);
end
endtask

task test1(
 input [31:0] f_hdl,
 input [31:0] err_bit,
 input [63:0] ber_exp,
 input [59:0] recv_cnt_exp,
 input [63:0] err_cnt_exp);
begin
  repeat (16*256) @(dut.i_pll_ctrl.CLKSS);
  repeat (err_bit) begin
    lvds_p[64] = !lvds_p[64];
    lvds_n[64] = !lvds_n[64];
    repeat (31) @(dut.i_pll_ctrl.CLKSS);
  end
  wait (lvds_p[63:0] == 64'h0000_0000_0000_0000);
  wait (lvds_p[63:0] == 64'hAAAA_AAAA_AAAA_AAAA);
  compare_err_cnt(f_hdl, recv_cnt_exp, err_cnt_exp);

  wait (dut.i_handle_7seg.i_ber_7seg.BUSY == 1'b1);
  wait (dut.i_handle_7seg.i_ber_7seg.BUSY == 1'b0);
  @(posedge CLK);
  compare_ber(f_hdl, ber_exp);
end
endtask

task main_loop(input [31:0] f_hdl);
integer i;
begin
  for (i = 128; i < 200; i = i+1) begin
    tap_sel = i;
    inc_sub_mode(1); // clear
    dec_sub_mode(1);
    wait (lvds_p[63:0] == 64'hAAAA_AAAA_AAAA_AAAA);
    wait (lvds_p[63:0] == 64'h0000_0000_0000_0000);
    test1(f_hdl, 2, $realtobits(2.0/(16*1024)), 60'h400, 64'd2);
    test1(f_hdl, 0, $realtobits(2.0/(16*2048)), 60'h800, 64'd2);
  end
end
endtask

task test_main;
reg [31:0] f_hdl;
begin
  f_hdl = $fopen("result/t020.log");
  fork
    begin
      init;
      inc_sub_mode(1);
      main_loop(f_hdl);
      #24e6; // 24us
      $fclose(f_hdl);
      $finish;
    end
    begin
      #150e9; // 10ms
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
