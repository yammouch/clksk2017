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

function [29:0] ctrl_signal_exp(input [7:0] i);
case (ctrl_signal_exp)
8'd9   : ctrl_signal_exp = 30'b0000_00_1111_11_0000_00_0000_0000_0000;
8'd10  : ctrl_signal_exp = 30'b0111_01_0000_11_0000_00_0000_0000_0000;
8'd11  : ctrl_signal_exp = 30'b0111_01_0000_11_0000_00_0000_0000_0000;
8'd12  : ctrl_signal_exp = 30'b0111_01_0000_11_0000_00_0000_0000_0000;

8'd13  : ctrl_signal_exp = 30'b0000_00_0000_11_0000_00_0000_0000_0000;
8'd14  : ctrl_signal_exp = 30'b0000_00_0100_11_0000_00_0000_0000_0000;
8'd15  : ctrl_signal_exp = 30'b0000_00_1000_11_0000_00_0000_0000_0000;
8'd16  : ctrl_signal_exp = 30'b0000_00_1100_11_0000_00_0000_0000_0000;

8'd17  : ctrl_signal_exp = 30'b0000_00_0000_11_0000_00_0000_0000_0000;
8'd18  : ctrl_signal_exp = 30'b0000_00_0001_11_0000_00_0000_0000_0000;
8'd19  : ctrl_signal_exp = 30'b0000_00_0010_11_0000_00_0000_0000_0000;
8'd20  : ctrl_signal_exp = 30'b0000_00_0011_11_0000_00_0000_0000_0000;

8'd21  : ctrl_signal_exp = 30'b0101_01_1100_10_0000_00_0000_0000_0000;
8'd22  : ctrl_signal_exp = 30'b1010_10_0011_01_0000_00_0000_0000_0000;

8'd23  : ctrl_signal_exp = 30'b0101_01_0000_10_0000_00_0000_0000_0000;
8'd24  : ctrl_signal_exp = 30'b0101_01_0100_10_0000_00_0000_0000_0000;
8'd25  : ctrl_signal_exp = 30'b0101_01_1000_10_0000_00_0000_0000_0000;
8'd26  : ctrl_signal_exp = 30'b0101_01_1100_10_0000_00_0000_0000_0000;

8'd27  : ctrl_signal_exp = 30'b1010_10_0000_01_0000_00_0000_0000_0000;
8'd28  : ctrl_signal_exp = 30'b1010_10_0001_01_0000_00_0000_0000_0000;
8'd29  : ctrl_signal_exp = 30'b1010_10_0010_01_0000_00_0000_0000_0000;
8'd30  : ctrl_signal_exp = 30'b1010_10_0011_01_0000_00_0000_0000_0000;

8'd31  : ctrl_signal_exp = 30'b0000_00_1111_11_0000_00_0000_0000_0000;

default: ctrl_signal_exp = 30'b0000_00_1111_11_0000_00_0000_0000_0000;
endcase
endfunction

task cmp1(
 input [    31:0] f_hdl,
 input [16*8-1:0] name,
 input            sig,
 input            exp);
begin
  if (sig == exp)
    $fwrite(f_hdl, "[OK]");
  else
    $fwrite(f_hdl, "[ER] at %6.3f [ms]", $time * 1e-9);
  $fwrite(f_hdl, " %s val: %b exp: %b\n", name, sig, exp);
end
endtask

task compare_ctrl(input [31:0] f_hdl, input [7:0] i);
reg [29:0] exp;
begin
  $fwrite(f_hdl, "MAIN_MODE = %d\n", i);
  exp = ctrl_signal_exp(i);
  cmp1(f_hdl, "SEL_RX_A"     , dut.SEL_RX_A     , exp[29]);
  cmp1(f_hdl, "SEL_RX_B"     , dut.SEL_RX_B     , exp[28]);
  cmp1(f_hdl, "SEL_TX_A"     , dut.SEL_TX_A     , exp[27]);
  cmp1(f_hdl, "SEL_TX_B"     , dut.SEL_TX_B     , exp[26]);
  cmp1(f_hdl, "PD_BIAS_A"    , dut.PD_BIAS_A    , exp[25]);
  cmp1(f_hdl, "PD_BIAS_B"    , dut.PD_BIAS_B    , exp[24]);
  cmp1(f_hdl, "IDSET_A[1]"   , dut.IDSET_A[1]   , exp[23]);
  cmp1(f_hdl, "IDSET_A[0]"   , dut.IDSET_A[0]   , exp[22]);
  cmp1(f_hdl, "IDSET_B[1]"   , dut.IDSET_B[1]   , exp[21]);
  cmp1(f_hdl, "IDSET_B[0]"   , dut.IDSET_B[0]   , exp[20]);
  cmp1(f_hdl, "HYST_A"       , dut.HYST_A       , exp[19]);
  cmp1(f_hdl, "HYST_B"       , dut.HYST_B       , exp[18]);
  cmp1(f_hdl, "DRV_STR_A[1]" , dut.DRV_STR_A[1] , exp[17]);
  cmp1(f_hdl, "DRV_STR_A[0]" , dut.DRV_STR_A[0] , exp[16]);
  cmp1(f_hdl, "DRV_STR_B[1]" , dut.DRV_STR_B[1] , exp[15]);
  cmp1(f_hdl, "DRV_STR_B[0]" , dut.DRV_STR_B[0] , exp[14]);
  cmp1(f_hdl, "SR_A"         , dut.SR_A         , exp[13]);
  cmp1(f_hdl, "SR_B"         , dut.SR_B         , exp[12]);
  cmp1(f_hdl, "PUDEN_TX_A"   , dut.PUDEN_TX_A   , exp[11]);
  cmp1(f_hdl, "PUDEN_TX_B"   , dut.PUDEN_TX_B   , exp[10]);
  cmp1(f_hdl, "PUDEN_RX_A"   , dut.PUDEN_RX_A   , exp[ 9]);
  cmp1(f_hdl, "PUDEN_RX_B"   , dut.PUDEN_RX_B   , exp[ 8]);
  cmp1(f_hdl, "PUDPOL_TX_A"  , dut.PUDPOL_TX_A  , exp[ 7]);
  cmp1(f_hdl, "PUDPOL_TX_B"  , dut.PUDPOL_TX_B  , exp[ 6]);
  cmp1(f_hdl, "PUDPOL_RX_A"  , dut.PUDPOL_RX_A  , exp[ 5]);
  cmp1(f_hdl, "PUDPOL_RX_B"  , dut.PUDPOL_RX_B  , exp[ 4]);
  cmp1(f_hdl, "TEST_A[1]"    , dut.TEST_A[1]    , exp[ 3]);
  cmp1(f_hdl, "TEST_A[0]"    , dut.TEST_A[0]    , exp[ 2]);
  cmp1(f_hdl, "TEST_B[1]"    , dut.TEST_B[1]    , exp[ 1]);
  cmp1(f_hdl, "TEST_B[0]"    , dut.TEST_B[0]    , exp[ 0]);
end
endtask

task test1(input [31:0] f_hdl);
integer i;
begin
  #10e6; // 10us
  for (i = 0; i < 256; i = i+1) begin
    compare_ctrl(f_hdl, i);
    BTN_2 = 1'b0; #24e6; // 24us
    BTN_2 = 1'b1; #24e6; // 24us
  end
end
endtask

task test_main;
reg [31:0] f_hdl;
begin
  f_hdl = $fopen("result/t200.log");
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
