// sweeps MAIN_MODE, and check frequency of PLL.

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

task mode_change(input sub, input inc, input [31:0] n);
begin
  #24e6; // 24us
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
  mode_change(1'b1, 1'b1, 3); // SUB_MODE -> 3
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  1
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  2
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  3
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  4
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  5
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  6
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  7
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  8
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); //  9
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 10
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 11
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl, 16); // 12
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 13
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 14
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 15
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 16
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 17
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 18
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 19
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  4); // 20
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 21
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 22
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 23
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 24
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 25
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 26
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 27
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 28
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 29
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 30
  mode_change(1'b0, 1'b1, 1); #300e6 check_cycle(f_hdl,  6); // 31
end
endtask

task test_main;
reg [31:0] f_hdl;
begin
  f_hdl = $fopen("result/t120.log");
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
