`timescale 1ps/1ps

module tb;

`include "inst_cmos.vh"

task init;
begin
  BTN_1   = 1'b1;
  BTN_2   = 1'b1;
  BTN_3   = 1'b1;
  fg.en   = 1'b1;
  force dut.i_button_ctrl.i_dechat_bt1.TIMEOUT = 15'd255;
  force dut.i_button_ctrl.i_dechat_bt2.TIMEOUT = 15'd255;
  force dut.i_button_ctrl.i_dechat_bt3.TIMEOUT = 15'd255;
end
endtask

task mode_change(input sub, input inc, input ten, input [31:0] n);
begin
  #24e6; // 24us
  if (ten) begin
    if (inc) BTN_1 = 1'b0;
    else     BTN_2 = 1'b0;
  end
  if (sub) BTN_3 = 1'b0; #24e6; // 24us
  repeat (n) begin
    if (inc) begin
      BTN_2 = 1'b0; #24e6; // 24us
      BTN_2 = 1'b1; #24e6; // 24us
    end else begin
      BTN_1 = 1'b0; #24e6; // 24us
      BTN_1 = 1'b1; #24e6; // 24us
    end
  end
  if (ten) begin
    if (inc) BTN_1 = 1'b1;
    else     BTN_2 = 1'b1;
  end
  if (sub) BTN_3 = 1'b1; #24e6; // 24us
end
endtask

function [29:0] ctrl_signal_exp(input [7:0] main_mode, input [7:0] sub_mode);
case (main_mode)
8'd32  : ctrl_signal_exp = 30'b1111_00_0000_00_0000_00_0000_0000_0000;
8'd46  : 
  if (sub_mode[0])
         ctrl_signal_exp = 30'b1111_00_0000_00_0000_00_0010_0010_0000;
  else
         ctrl_signal_exp = 30'b1111_00_0000_00_0000_00_0010_0000_0000;
8'd48  : ctrl_signal_exp = 30'b1111_00_0000_00_0000_00_0000_0000_1000;
8'd62  : 
  if (sub_mode[0])
         ctrl_signal_exp = 30'b1111_00_0000_00_0000_00_0010_1000_1000;
  else
         ctrl_signal_exp = 30'b1111_00_0000_00_0000_00_0010_0000_1000;
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

task compare_ctrl(
 input [31:0] f_hdl,
 input [ 7:0] main_mode,
 input [ 7:0] sub_mode);
reg [29:0] exp;
begin
  $fwrite(f_hdl, "MAIN_MODE = %d, SUB_MODE = %d\n", main_mode, sub_mode);
  exp = ctrl_signal_exp(main_mode, sub_mode);
  cmp1(f_hdl, "POR     "     , dut.POR          , 1'b0   );
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
  mode_change(0, 1, 1, 3); // MAIN_MODE -> 30
  mode_change(0, 1, 0, 2); // MAIN_MODE -> 32
  #300e6; // 300us
  compare_ctrl(f_hdl, 32, 0);

  mode_change(0, 1, 1, 1); // MAIN_MODE -> 42
  mode_change(0, 1, 0, 4); // MAIN_MODE -> 46
  #300e6; // 300us
  compare_ctrl(f_hdl, 46, 0);

  mode_change(1, 1, 0, 1); // SUB_MODE -> 1
  #300e6; // 300us
  compare_ctrl(f_hdl, 46, 1);
  mode_change(1, 0, 0, 1); // SUB_MODE -> 0

  mode_change(0, 1, 0, 2); // MAIN_MODE -> 48
  #300e6; // 300us
  compare_ctrl(f_hdl, 48, 0);

  mode_change(0, 1, 1, 1); // MAIN_MODE -> 58
  mode_change(0, 1, 0, 4); // MAIN_MODE -> 62
  #300e6; // 300us
  compare_ctrl(f_hdl, 62, 0);

  mode_change(1, 1, 0, 1); // SUB_MODE -> 1
  #300e6; // 300us
  compare_ctrl(f_hdl, 62, 1);
  mode_change(1, 0, 0, 1); // SUB_MODE -> 0
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
