`timescale 1ps/1ps

module tb;

wire CLK;
reg  RSTX;
reg  CLR;

tb_clk_gen clk_gen(.clk(CLK));

synth dut(
 .CLK  (CLK),
 .RSTX (RSTX),
 .CLR  (CLR),
 .SEQ  ()
);

initial begin
  #0.1e6;
  RSTX = 1'b0;
  CLR  = 1'b1;
  clk_gen.en = 1'b1;
  repeat (4) @(negedge CLK);
  RSTX = 1'b1;
  repeat (4) @(negedge CLK);
  CLR  = 1'b0;
  repeat (100) @(negedge CLK);
  $finish;
end

endmodule
