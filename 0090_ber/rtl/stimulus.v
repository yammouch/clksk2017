module stimulus (
 input             RSTX,
 input             CLK,
 input             RSTXF,
 input             CLKF,
 input             RSTXS,
 input             CLKS,
 input             CLR,
 input      [ 7:0] MAIN_MODE,
 input      [ 7:0] SUB_MODE,
 output reg [30:0] NT_CTRL,
 output     [ 1:0] NTA_DOUT,
 input      [ 1:0] NTA_DIN,
 output     [ 1:0] NTB_DOUT,
 input      [ 1:0] NTB_DIN,
 output reg [30:0] ET_CTRL,
 output     [ 1:0] ETA_DOUT,
 input      [ 1:0] ETA_DIN,
 output     [ 1:0] ETB_DOUT,
 input      [ 1:0] ETB_DIN,
 output reg [30:0] ST_CTRL,
 output     [ 1:0] ST_DOUT,
 input      [ 1:0] ST_DIN,
 output reg [30:0] SC_CTRL,
 output     [ 1:0] SCA_DOUT,
 input      [ 1:0] SCA_DIN,
 output     [ 1:0] SCB_DOUT,
 input      [ 1:0] SCB_DIN,
 output     [57:0] RECV_CNT,
 output     [63:0] ERR_CNT);

localparam UNABLE = {30'd0, 1'b1};

function [34:0] ftable(input [15:0] DIN, input is_screening);
case (DIN[15:8])
8'd9: begin
  ftable[43:13] = { 16'b0000_00_1111_11_0000
                , DIN[1:0]
                , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_10_0_00_0100;
  else              ftable[12:0] = 13'b00_00_00_0_10_0001;
end
8'd10: begin
  ftable[43:13] = { 16'b0111_01_0000_11_0000
                  , DIN[1:0]
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b10_00_10_0_00_0100;
  else              ftable[12:0] = 13'b10_00_00_0_10_0001;
end
8'd11: begin
  ftable[43:13] = { 16'b0111_01_0000_11_0000
                  , DIN[1:0]
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
end
8'd12: begin
  ftable[43:13] = { 16'b0111_01_0000_11_0000
                  , DIN[1:0]
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_10_0_00_0100;
  else              ftable[12:0] = 13'b00_00_00_0_10_0001;
end
8'd13: begin
  ftable[43:13] = { 8'b0000_00_00
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
end
8'd14: begin
  ftable[43:13] = { 8'b0000_00_01
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
end
8'd15: begin
  ftable[43:13] = { 8'b0000_00_10
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
end
8'd16: begin
  ftable[43:13] = { 8'b0000_00_11
                  , DIN[5:4]
                  , 6'b11_0000
                  , DIN[3:2]
                  , 10'b0000_0000_00
                  , DIN[1:0]
                  , 1'b0 };
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
end
8'd17: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b00_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
end
8'd18: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b01_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
end
8'd19: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b10_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
end
8'd20: begin
  ftable[43:13] = { 6'b0000_00
                  , DIN[5:4]
                  , 8'b11_11_0000
                  , DIN[3:2]
                  , 8'b0000_0000
                  , DIN[1:0]
                  , 3'b00_0 };
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
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
  if (is_screening) ftable[12:0] = 13'b00_00_10_0_00_0100;
  else              ftable[12:0] = 13'b00_00_00_0_10_0001;
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
  if (is_screening) ftable[12:0] = 13'b00_00_01_0_00_0100;
  else              ftable[12:0] = 13'b00_00_00_0_01_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_10_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_10_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
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
  if (is_screening) ftable[12:0] = 13'b01_00_01_0_00_0100;
  else              ftable[12:0] = 13'b01_00_00_0_01_0001;
end
8'd31: begin
  ftable[43:13] = { 16'b0000_00_1111_11_0000
                  , 2'b00 // D/C
                  , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_00_1_00_0010;
  else              ftable[12:0] = 13'b00_00_00_0_01_0001;
end
default: begin
  ftable[43:13] = { 16'b0000_00_1111_11_0000
                , DIN[1:0]
                , 13'b0000_0000_0000_0 };
  if (is_screening) ftable[12:0] = 13'b00_00_10_0_00_0100;
  else              ftable[12:0] = 13'b00_00_00_0_10_0001;
end
endcase
endfunction

wire [43:0] table_dout = ftable({MAIN_MODE, SUB_MODE}, 1'b1);

always @(posedge CLK or negedge RSTX)
  if (!RSTX)              NT_CTRL <= UNABLE;
  else if (table_dout[3]) NT_CTRL <= table_dout[43:13];
  else                    NT_CTRL <= UNABLE;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)              ET_CTRL <= UNABLE;
  else if (table_dout[2]) ET_CTRL <= table_dout[43:13];
  else                    ET_CTRL <= UNABLE;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)              ST_CTRL <= UNABLE;
  else if (table_dout[1]) ST_CTRL <= table_dout[43:13];
  else                    ST_CTRL <= UNABLE;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)              SC_CTRL <= UNABLE;
  else if (table_dout[0]) SC_CTRL <= table_dout[43:13];
  else                    SC_CTRL <= UNABLE;

wire [57:0] recv_cnt_nta, recv_cnt_ntb, recv_cnt_eta, recv_cnt_etb,
            recv_cnt_st , recv_cnt_sca, recv_cnt_scb;
wire [63:0] err_cnt_nta , err_cnt_ntb , err_cnt_eta , err_cnt_etb ,
            err_cnt_st  , err_cnt_sca , err_cnt_scb ;

lvds1 i_lvds_nta (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .RSTXF    (RSTXF),
 .CLKF     (CLKF),
 .RSTXP    (RSTX),
 .CLKP     (CLK),
 .CLR      (CLR || !table_dout[10]),
 .PATTERN  (table_dout[12:11]),
 .INV      (1'b0),
 .DIN      (NTA_DIN),
 .RECV_CNT (recv_cnt_nta),
 .ERR_CNT  (err_cnt_nta),
 .DOUT     (NTA_DOUT)
);

lvds1 i_lvds_ntb (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .RSTXF    (RSTXF),
 .CLKF     (CLKF),
 .RSTXP    (RSTX),
 .CLKP     (CLK),
 .CLR      (CLR || !table_dout[9]),
 .PATTERN  (table_dout[12:11]),
 .INV      (1'b0),
 .DIN      (NTB_DIN),
 .RECV_CNT (recv_cnt_ntb),
 .ERR_CNT  (err_cnt_ntb),
 .DOUT     (NTB_DOUT)
);

lvds1 i_lvds_eta (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .RSTXF    (RSTXF),
 .CLKF     (CLKF),
 .RSTXP    (RSTX),
 .CLKP     (CLK),
 .CLR      (CLR || !table_dout[8]),
 .PATTERN  (table_dout[12:11]),
 .INV      (1'b0),
 .DIN      (ETA_DIN),
 .RECV_CNT (recv_cnt_eta),
 .ERR_CNT  (err_cnt_eta),
 .DOUT     (ETA_DOUT)
);

lvds1 i_lvds_etb (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .RSTXF    (RSTXF),
 .CLKF     (CLKF),
 .RSTXP    (RSTX),
 .CLKP     (CLK),
 .CLR      (CLR || !table_dout[7]),
 .PATTERN  (table_dout[12:11]),
 .INV      (1'b0),
 .DIN      (ETB_DIN),
 .RECV_CNT (recv_cnt_etb),
 .ERR_CNT  (err_cnt_etb),
 .DOUT     (ETB_DOUT)
);

lvds1 i_lvds_st (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .RSTXF    (RSTXF),
 .CLKF     (CLKF),
 .RSTXP    (RSTX),
 .CLKP     (CLK),
 .CLR      (CLR || !table_dout[6]),
 .PATTERN  (table_dout[12:11]),
 .INV      (1'b0),
 .DIN      (ST_DIN),
 .RECV_CNT (recv_cnt_st),
 .ERR_CNT  (err_cnt_st),
 .DOUT     (ST_DOUT)
);

lvds1 i_lvds_sca (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .RSTXF    (RSTXF),
 .CLKF     (CLKF),
 .RSTXP    (RSTX),
 .CLKP     (CLK),
 .CLR      (CLR || !table_dout[5]),
 .PATTERN  (table_dout[12:11]),
 .INV      (1'b0),
 .DIN      (SCA_DIN),
 .RECV_CNT (recv_cnt_sca),
 .ERR_CNT  (err_cnt_sca),
 .DOUT     (SCA_DOUT)
);

lvds1 i_lvds_scb (
 .RSTXS    (RSTXS),
 .CLKS     (CLKS),
 .RSTXF    (RSTXF),
 .CLKF     (CLKF),
 .RSTXP    (RSTX),
 .CLKP     (CLK),
 .CLR      (CLR || !table_dout[4]),
 .PATTERN  (table_dout[12:11]),
 .INV      (1'b0),
 .DIN      (SCB_DIN),
 .RECV_CNT (recv_cnt_scb),
 .ERR_CNT  (err_cnt_scb),
 .DOUT     (SDB_DOUT)
);

assign RECV_CNT = {58{table_dout[10]}} & recv_cnt_nta
                | {58{table_dout[ 9]}} & recv_cnt_ntb
                | {58{table_dout[ 8]}} & recv_cnt_eta
                | {58{table_dout[ 7]}} & recv_cnt_etb
                | {58{table_dout[ 6]}} & recv_cnt_st
                | {58{table_dout[ 5]}} & recv_cnt_sca
                | {58{table_dout[ 4]}} & recv_cnt_scb;

assign ERR_CNT  = {64{table_dout[10]}} & err_cnt_nta
                | {64{table_dout[ 9]}} & err_cnt_ntb
                | {64{table_dout[ 8]}} & err_cnt_eta
                | {64{table_dout[ 7]}} & err_cnt_etb
                | {64{table_dout[ 6]}} & err_cnt_st
                | {64{table_dout[ 5]}} & err_cnt_sca
                | {64{table_dout[ 4]}} & err_cnt_scb;

endmodule
