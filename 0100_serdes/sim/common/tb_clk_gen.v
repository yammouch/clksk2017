`timescale 1ps/1ps

module tb_clk_gen(clk);

output clk;
reg    clk;

integer period_hi;
integer period_lo;
reg     en;

initial begin
  period_hi = 25_000; // 25ns 20MHz
  period_lo = 25_000; // 25ns
  en        = 1'b0;
  clk       = 1'b0;
end

always @(en) begin
  while (en == 1'b1) begin
    clk = 1'b1; #(period_hi);
    clk = 1'b0; #(period_lo);
  end
end

endmodule
