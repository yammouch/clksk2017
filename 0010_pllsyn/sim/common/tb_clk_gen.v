`timescale 1ps/1ps

module tb_clk_gen(CLK);

output CLK;
reg    CLK;

integer period_hi;
integer period_lo;
reg     en;

initial begin
  period_hi = 50_000; // 50ns 10MHz
  period_lo = 50_000; // 50ns
  en        = 1'b0;
  CLK       = 1'b0;
end

always @(en) begin
  while (en == 1'b1) begin
    CLK = 1'b1; #(period_hi);
    CLK = 1'b0; #(period_lo);
  end
end

endmodule
