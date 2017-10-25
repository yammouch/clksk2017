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
  force dut.i_handle_7seg.i_cnt_down_s.VAL = 25'd4095;
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
  if (dut.i_stimulus.ERR_CNT == 64'd2) $fwrite(f_hdl, "[OK]");
  else                                 $fwrite(f_hdl, "[ER]");
  $fwrite(f_hdl, " ERR_CNT %d, expected 2\n", dut.i_stimulus.ERR_CNT);
  if (dut.i_stimulus.RECV_CNT == 58'h00_0000_0000_0400) $fwrite(f_hdl, "[OK]");
  else                                                  $fwrite(f_hdl, "[ER]");
  $fwrite(f_hdl, " RECV_CNT 'h%x, expected 'h400\n", dut.i_stimulus.RECV_CNT);
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
  f_hdl = $fopen("result/t020.log");
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
