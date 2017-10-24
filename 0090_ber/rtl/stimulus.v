module stimulus (
 input             RSTX,
 input             CLK,
 input      [ 7:0] MAIN_MODE,
 input      [ 7:0] SUB_MODE,
 output reg [30:0] NT_CTRL,
 output reg [30:0] ET_CTRL,
 output reg [30:0] ST_CTRL,
 output reg [30:0] SC_CTRL);

localparam UNABLE = {30'd0, 1'b1};

function [34:0] ftable(input [15:0] DIN);
  case (DIN[15:8])
  8'd9   : ftable = { 16'b0000_00_1111_11_0000
                    , DIN[1:0]
                    , 17'b0000_0000_0000_0_0100 };
  8'd10  : ftable = { 16'b0111_01_0000_11_0000
                    , DIN[1:0]
                    , 17'b0000_0000_0000_0_0100 };
  8'd11  : ftable = { 16'b0111_01_0000_11_0000
                    , DIN[1:0]
                    , 17'b0000_0000_0000_0_0100 };
  8'd12  : ftable = { 16'b0111_01_0000_11_0000
                    , DIN[1:0]
                    , 17'b0000_0000_0000_0_0100 };
  8'd13  : ftable = { 8'b0000_00_00
                    , DIN[5:4]
                    , 6'b11_0000
                    , DIN[3:2]
                    , 10'b0000_0000_00
                    , DIN[1:0]
                    , 5'b0_0100 };
  8'd14  : ftable = { 8'b0000_00_01
                    , DIN[5:4]
                    , 6'b11_0000
                    , DIN[3:2]
                    , 10'b0000_0000_00
                    , DIN[1:0]
                    , 5'b0_0100 };
  8'd15  : ftable = { 8'b0000_00_10
                    , DIN[5:4]
                    , 6'b11_0000
                    , DIN[3:2]
                    , 10'b0000_0000_00
                    , DIN[1:0]
                    , 5'b0_0100 };
  8'd16  : ftable = { 8'b0000_00_11
                    , DIN[5:4]
                    , 6'b11_0000
                    , DIN[3:2]
                    , 10'b0000_0000_00
                    , DIN[1:0]
                    , 5'b0_0100 };
  8'd17  : ftable = { 6'b0000_00
                    , DIN[5:4]
                    , 8'b00_11_0000
                    , DIN[3:2]
                    , 8'b0000_0000
                    , DIN[1:0]
                    , 7'b00_0_0100 };
  8'd18  : ftable = { 6'b0000_00
                    , DIN[5:4]
                    , 8'b01_11_0000
                    , DIN[3:2]
                    , 8'b0000_0000
                    , DIN[1:0]
                    , 7'b00_0_0100 };
  8'd19  : ftable = { 6'b0000_00
                    , DIN[5:4]
                    , 8'b10_11_0000
                    , DIN[3:2]
                    , 8'b0000_0000
                    , DIN[1:0]
                    , 7'b00_0_0100 };
  8'd20  : ftable = { 6'b0000_00
                    , DIN[5:4]
                    , 8'b11_11_0000
                    , DIN[3:2]
                    , 8'b0000_0000
                    , DIN[1:0]
                    , 7'b00_0_0100 };
  8'd21  : ftable = { 8'b0101_01_11
                    , 2'b00 // D/C
                    , 1'b1
                    , 1'b0  // D/C
                    , 4'b0000
                    , 2'b00 // D/C
                    , 10'b0000_0000_00
                    , 2'b00 // D/C
                    , 5'b0_0100 };
  8'd22  : ftable = { 6'b1010_10
                    , 2'b00 // D/C
                    , 2'b11
                    , 1'b0  // D/C
                    , 5'b1_0000
                    , 2'b00 // D/C
                    , 8'b0000_0000
                    , 2'b00 // D/C
                    , 7'b00_0_0100 };
  8'd23  : ftable = { 8'b0101_01_00
                    , 2'b00 // D/C
                    , 1'b1
                    , 1'b0  // D/C
                    , 4'b0000
                    , 2'b00 // D/C
                    , 10'b0000_0000_00
                    , 2'b00 // D/C
                    , 5'b0_0100 };
  8'd24  : ftable = { 8'b0101_01_01
                    , 2'b00 // D/C
                    , 1'b1
                    , 1'b0  // D/C
                    , 4'b0000
                    , 2'b00 // D/C
                    , 10'b0000_0000_00
                    , 2'b00 // D/C
                    , 5'b0_0100 };
  8'd25  : ftable = { 8'b0101_01_10
                    , 2'b00 // D/C
                    , 1'b1
                    , 1'b0  // D/C
                    , 4'b0000
                    , 2'b00 // D/C
                    , 10'b0000_0000_00
                    , 2'b00 // D/C
                    , 5'b0_0100 };
  8'd26  : ftable = { 8'b0101_01_11
                    , 2'b00 // D/C
                    , 1'b1
                    , 1'b0  // D/C
                    , 4'b0000
                    , 2'b00 // D/C
                    , 10'b0000_0000_00
                    , 2'b00 // D/C
                    , 5'b0_0100 };
  8'd27  : ftable = { 6'b1010_10
                    , 2'b00 // D/C
                    , 2'b00
                    , 1'b0  // D/C
                    , 5'b1_0000
                    , 2'b00 // D/C
                    , 8'b0000_0000
                    , 2'b00 // D/C
                    , 7'b00_0_0100 };
  8'd28  : ftable = { 6'b1010_10
                    , 2'b00 // D/C
                    , 2'b01
                    , 1'b0  // D/C
                    , 5'b1_0000
                    , 2'b00 // D/C
                    , 8'b0000_0000
                    , 2'b00 // D/C
                    , 7'b00_0_0100 };
  8'd29  : ftable = { 6'b1010_10
                    , 2'b00 // D/C
                    , 2'b10
                    , 1'b0  // D/C
                    , 5'b1_0000
                    , 2'b00 // D/C
                    , 8'b0000_0000
                    , 2'b00 // D/C
                    , 7'b00_0_0100 };
  8'd30  : ftable = { 6'b1010_10
                    , 2'b00 // D/C
                    , 2'b11
                    , 1'b0  // D/C
                    , 5'b1_0000
                    , 2'b00 // D/C
                    , 8'b0000_0000
                    , 2'b00 // D/C
                    , 7'b00_0_0100 };
  8'd31  : ftable = { 16'b0000_00_1111_11_0000
                    , 2'b00 // D/C
                    , 17'b0000_0000_0000_0_0010 };
  default: ftable = UNABLE;
  endcase
endfunction

wire [34:0] table_dout = ftable({MAIN_MODE, SUB_MODE});

wire is_screening = 1'b1;
wire [3:0] stimu_en = is_screening ? 4'b0001 : table_dout[3:0];

always @(posedge CLK or negedge RSTX)
  if (!RSTX)            NT_CTRL <= UNABLE;
  else if (stimu_en[3]) NT_CTRL <= table_dout[34:4];
  else                  NT_CTRL <= UNABLE;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)            ET_CTRL <= UNABLE;
  else if (stimu_en[2]) ET_CTRL <= table_dout[34:4];
  else                  ET_CTRL <= UNABLE;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)            ST_CTRL <= UNABLE;
  else if (stimu_en[1]) ST_CTRL <= table_dout[34:4];
  else                  ST_CTRL <= UNABLE;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)            SC_CTRL <= UNABLE;
  else if (stimu_en[0]) SC_CTRL <= table_dout[34:4];
  else                  SC_CTRL <= UNABLE;

endmodule
