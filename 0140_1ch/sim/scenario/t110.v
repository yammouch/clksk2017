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
  force dut.i_button_ctrl.i_dechat_bt1.TIMEOUT = 15'd255;
  force dut.i_button_ctrl.i_dechat_bt2.TIMEOUT = 15'd255;
  force dut.i_button_ctrl.i_dechat_bt3.TIMEOUT = 15'd255;
end
endtask

task compare_dig_m(input [31:0] f_hdl, input [15:0] i);
reg [4:0] dig_m2_exp;
reg [3:0] dig_m1_exp;
reg [3:0] dig_m0_exp;
begin
  dig_m2_exp =  i / 100;
  dig_m1_exp = (i /  10) % 10;
  dig_m0_exp =  i        % 10;

  if (dig_m2_exp == dut.i_handle_7seg.dig_m2)
    $fwrite(f_hdl, "[OK] ");
  else
    $fwrite(f_hdl, "[ER] at %6.3f [ms] ", $time * 1e-9);
  $fwrite(f_hdl, "dig_m2 val: %d, exp: %d\n",
          dut.i_handle_7seg.dig_m2, dig_m2_exp);

  if (dig_m1_exp == dut.i_handle_7seg.dig_m1)
    $fwrite(f_hdl, "[OK] ");
  else
    $fwrite(f_hdl, "[ER] at %6.3f [ms] ", $time * 1e-9);
  $fwrite(f_hdl, "dig_m1 val: %d, exp: %d\n",
          dut.i_handle_7seg.dig_m1, dig_m1_exp);

  if (dig_m0_exp == dut.i_handle_7seg.dig_m0)
    $fwrite(f_hdl, "[OK] ");
  else
    $fwrite(f_hdl, "[ER] at %6.3f [ms] ", $time * 1e-9);
  $fwrite(f_hdl, "dig_m0 val: %d, exp: %d\n",
          dut.i_handle_7seg.dig_m0, dig_m0_exp);
end
endtask

task test1(input [31:0] f_hdl);
integer i;
begin
  #10e6; // 10us
  for (i = 0; i < 256; i = i+1) begin
    compare_dig_m(f_hdl, i);
    BTN_2 = 1'b0; #24e6; // 24us
    BTN_2 = 1'b1; #24e6; // 24us
  end
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
  7'b0111111: decode_7seg = 4'd6;
  7'b0100111: decode_7seg = 4'd7;
  7'b1111111: decode_7seg = 4'd8;
  7'b1101111: decode_7seg = 4'd9;
  default   : decode_7seg = 4'dx;
  endcase
endfunction

wire [3:0] dig_m1   = decode_7seg(dut.i_handle_7seg.dig_m  [13: 7]);
wire [3:0] dig_m0   = decode_7seg(dut.i_handle_7seg.dig_m  [ 6: 0]);
wire [3:0] dig_s1   = decode_7seg(dut.i_handle_7seg.dig_s  [13: 7]);
wire [3:0] dig_s0   = decode_7seg(dut.i_handle_7seg.dig_s  [ 6: 0]);
wire [3:0] dig_ber3 = decode_7seg(dut.i_handle_7seg.dig_ber[27:21]);
wire [3:0] dig_ber2 = decode_7seg(dut.i_handle_7seg.dig_ber[20:14]);
wire [3:0] dig_ber1 = decode_7seg(dut.i_handle_7seg.dig_ber[13: 7]);
wire [3:0] dig_ber0 = decode_7seg(dut.i_handle_7seg.dig_ber[ 6: 0]);

task test_main;
reg [31:0] f_hdl;
begin
  f_hdl = $fopen("result/t110.log");
  fork
    begin
      init;
      test1(f_hdl);
      $fclose(f_hdl);
      $finish;
    end
    begin
      #20e9; // 10ms
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
