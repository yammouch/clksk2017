module stimulus (
 input             RSTX,
 input             CLK,
 input             RSTXF,
 input             CLKF,
 input             CLKF_DATA,
 input             RSTXS,
 input             CLKS,
 input             CLKSS,
 input             CLR,
 input             SERDESSTROBE,
 input      [ 7:0] MAIN_MODE,
 input      [ 7:0] SUB_MODE,
 output reg [30:0] CTRL,
 output     [ 1:0] DOUT,
 input      [ 1:0] DIN,
 output            PHY_INIT,
 output     [59:0] RECV_CNT,
 output     [63:0] ERR_CNT);

localparam UNABLE = {30'd0, 1'b1};

function [43:0] ftable(input [15:0] DIN, input is_screening);
case (DIN[15:8])
8'd9: begin
  ftable[43:13] = { 16'b0000_00_1111_11_0000
                , DIN[1:0]
                , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_00_0_10_0001;
  else              ftable[12:0] = 13'b00_00_10_0_00_0100;
end
8'd10: begin
  ftable[43:13] = { 16'b0111_01_0000_11_0000
                  , DIN[1:0]
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b10_00_00_0_10_0001;
  else              ftable[12:0] = 13'b10_00_10_0_00_0100;
end
8'd11: begin
  ftable[43:13] = { 16'b0111_01_0000_11_0000
                  , DIN[1:0]
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd12: begin
  ftable[43:13] = { 16'b0111_01_0000_11_0000
                  , DIN[1:0]
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_00_0_10_0001;
  else              ftable[12:0] = 13'b00_00_10_0_00_0100;
end
8'd13: begin
  ftable[43:13] = { 8'b0000_00_00
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd14: begin
  ftable[43:13] = { 8'b0000_00_01
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd15: begin
  ftable[43:13] = { 8'b0000_00_10
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd16: begin
  ftable[43:13] = { 8'b0000_00_11
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd17: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b00_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd18: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b01_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd19: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b10_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd20: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b11_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd21: begin
  ftable[43:13] = { 8'b0101_01_11
                  , 2'b00 // D/C
                  , 1'b1
                  , 1'b0  // D/C
                  , 4'b0000
                  , 2'b00 // D/C
                  , 10'b0000_0000_00
                  , 2'b00
                  , 1'b0 }; // D/C
  if (is_screening) ftable[12:0] = 13'b00_00_00_0_10_0001;
  else              ftable[12:0] = 13'b00_00_10_0_00_0100;
end
8'd22: begin
  ftable[43:13] = { 6'b1010_10
                  , 2'b00 // D/C
                  , 2'b11
                  , 1'b0  // D/C
                  , 5'b1_0000
                  , 2'b00 // D/C
                  , 8'b0000_0000
                  , 2'b00 // D/C
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_00_0_01_0001;
  else              ftable[12:0] = 13'b00_00_01_0_00_0100;
end
8'd23: begin
  ftable[43:13] = { 8'b0101_01_00
                  , 2'b00 // D/C
                  , 1'b1
                  , 1'b0  // D/C
                  , 4'b0000
                  , 2'b00 // D/C
                  , 10'b0000_0000_00
                  , 2'b00 // D/C
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd24: begin
  ftable[43:13] = { 8'b0101_01_01
                  , 2'b00 // D/C
                  , 1'b1
                  , 1'b0  // D/C
                  , 4'b0000
                  , 2'b00 // D/C
                  , 10'b0000_0000_00
                  , 2'b00 // D/C
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd25: begin
  ftable[43:13] = { 8'b0101_01_10
                  , 2'b00 // D/C
                  , 1'b1
                  , 1'b0  // D/C
                  , 4'b0000
                  , 2'b00 // D/C
                  , 10'b0000_0000_00
                  , 2'b00 // D/C
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd26: begin
  ftable[43:13] = { 8'b0101_01_11
                  , 2'b00 // D/C
                  , 1'b1
                  , 1'b0  // D/C
                  , 4'b0000
                  , 2'b00 // D/C
                  , 10'b0000_0000_00
                  , 2'b00 // D/C
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_10_0001;
  else              ftable[12:0] = 13'b01_00_10_0_00_0100;
end
8'd27: begin
  ftable[43:13] = { 6'b1010_10
                  , 2'b00 // D/C
                  , 2'b00
                  , 1'b0  // D/C
                  , 5'b1_0000
                  , 2'b00 // D/C
                  , 8'b0000_0000
                  , 2'b00 // D/C
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd28: begin
  ftable[43:13] = { 6'b1010_10
                  , 2'b00 // D/C
                  , 2'b01
                  , 1'b0  // D/C
                  , 5'b1_0000
                  , 2'b00 // D/C
                  , 8'b0000_0000
                  , 2'b00 // D/C
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd29: begin
  ftable[43:13] = { 6'b1010_10
                  , 2'b00 // D/C
                  , 2'b10
                  , 1'b0  // D/C
                  , 5'b1_0000
                  , 2'b00 // D/C
                  , 8'b0000_0000
                  , 2'b00 // D/C
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd30: begin
  ftable[43:13] = { 6'b1010_10
                  , 2'b00 // D/C
                  , 2'b11
                  , 1'b0  // D/C
                  , 5'b1_0000
                  , 2'b00 // D/C
                  , 8'b0000_0000
                  , 2'b00 // D/C
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_00_0_01_0001;
  else              ftable[12:0] = 13'b01_00_01_0_00_0100;
end
8'd31: begin
  ftable[43:13] = { 16'b0000_00_1111_11_0000
                  , 2'b00 // D/C
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_00_0_01_0001;
  else              ftable[12:0] = 13'b00_00_00_1_00_0010;
end
8'd255: begin
  ftable[43:13] = { 16'b0000_00_1111_11_0000
                  , 2'b00 // D/C
                  , 13'b0000_0000_0000_0 };
  ftable[12:0] = 13'b11_11_11_1_11_1111;
end
default: begin
  ftable[43:13] = { 16'b0000_00_1111_11_0000
                , DIN[1:0]
                , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_00_0_10_0001;
  else              ftable[12:0] = 13'b00_00_10_0_00_0100;
end
endcase
endfunction

wire [43:0] table_dout = ftable({MAIN_MODE, SUB_MODE}, 1'b1);

always @(posedge CLK or negedge RSTX)
  if (!RSTX) CTRL <= UNABLE;
  else       CTRL <= table_dout[43:13];

lvds1 i_lvds1 (
 .RSTXS        (RSTXS),
 .CLKS         (CLKS),
 .CLKSS        (CLKSS),
 .RSTXF        (RSTXF),
 .CLKF         (CLKF),
 .CLKF_DATA    (CLKF_DATA),
 .CLR          (CLR),
 .SERDESSTROBE (SERDESSTROBE),
 .PATTERN      (table_dout[12:11]),
 .INV          (1'b0),
 .DIN          (DIN),
 .PHY_INIT     (PHY_INIT),
 .RECV_CNT     (RECV_CNT),
 .ERR_CNT      (ERR_CNT),
 .DOUT         (DOUT)
);

endmodule
