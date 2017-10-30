module pseudo_sram
 #( parameter BW = 32
  , parameter AW =  6
  , parameter WC = 64 ) (
 input               CLKDI,
 input               WEN,
 input      [AW-1:0] WADDR,
 input      [BW-1:0] DIN,

 input               CLKDO,
 input               REN,
 input      [AW-1:0] RADDR,
 output reg [BW-1:0] DOUT
);

reg [BW-1:0] mem [0:WC-1];

always @(posedge CLKDI) if (WEN) mem[WADDR] <= DIN;
always @(posedge CLKDO) if (REN) DOUT <= mem[RADDR];

endmodule
