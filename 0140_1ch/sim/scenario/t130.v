// sweeps SUB_MODE, and check frequency of PLL.

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

task compare_cycle(
 input [   31:0] f_hdl,
 input [8*6-1:0] name,
 input [   63:0] val,  // integer
 input [   63:0] exp); // real
real r_exp;
begin
  r_exp = $bitstoreal(exp);
  if (r_exp*0.9 <= val && val <= r_exp*1.1)
    $fwrite(f_hdl, "[OK]");
  else
    $fwrite(f_hdl, "[ER] @ %6.3f [ms]", $time*1e-9);
  $fwrite(f_hdl, " %s cycle val %.1f [ps], exp [%f, %f] [ps]\n",
          name, $itor(val), r_exp*0.9, r_exp*1.1);
end
endtask

task check_cycle(input [31:0] f_hdl, input [31:0] mult);
time t_clk, t_pll;
real exp;
begin
  @(posedge CLK)       t_clk = $time;
  @(posedge CLK)       t_clk = $time - t_clk;

  @(posedge dut.clkss) t_pll = $time;
  @(posedge dut.clkss) t_pll = $time - t_pll;
  compare_cycle(f_hdl, "CLKSS", t_pll, $realtobits(t_clk / $itor(mult)));

  @(posedge dut.clks)  t_pll = $time;
  @(posedge dut.clks)  t_pll = $time - t_pll;
  compare_cycle(f_hdl, "CLKS", t_pll, $realtobits(t_clk / $itor(mult) * 4));

  @(posedge dut.clkf)  t_pll = $time;
  @(posedge dut.clkf)  t_pll = $time - t_pll;
  compare_cycle(f_hdl, "CLKF", t_pll, $realtobits(t_clk / $itor(mult) * 16));
end
endtask

task test1(input [31:0] f_hdl);
integer i;
begin
  #10e6; // 10us
  mode_change(0, 1, 1, 1); // MAIN_MODE -> 10
  mode_change(0, 0, 0, 1); // MAIN_MODE ->  9
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl,  2); //  1
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl,  4); //  2
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl,  6); //  3
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl,  8); //  4
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 10); //  5
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 12); //  6
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 14); //  7
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 16); //  8
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 18); //  9
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 20); // 10
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 22); // 11
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 24); // 12
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 26); // 13
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 28); // 14
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 30); // 15
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 32); // 16
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 34); // 17
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 36); // 18
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 38); // 19
  mode_change(1, 1, 0, 1); #300e6 check_cycle(f_hdl, 40); // 20
end
endtask

task test_main;
reg [31:0] f_hdl;
begin
  f_hdl = $fopen("result/t130.log");
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
