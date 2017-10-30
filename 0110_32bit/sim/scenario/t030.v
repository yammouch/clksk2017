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
  repeat (5) begin
    BTN_2 = 1'b0; #1100e6; // 1.1ms
    BTN_2 = 1'b1; #1100e6; // 1.1ms
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
  f_hdl = $fopen("result/t030.log");
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
