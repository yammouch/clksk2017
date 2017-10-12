module parallel_send (
 input             CLK,
 input             RSTX,
 input             DOPULL,
 input             CLR,

 output reg        DOPUSH,
 output reg        PHY_INIT,
 output reg [63:0] DOUT
);

localparam INIT          = 2'd0,
           DELAY_ADJUST  = 2'd1,
           WORD_ALIGN    = 2'd2,
           DATA_TRANSFER = 2'd3;

reg [9:0] cnt;
reg [1:0] state, state_next;

always @(posedge CLK or negedge RSTX)
  if (!RSTX)    state <= INIT;
  else if (CLR) state <= INIT;
  else          state <= state_next;
always @*
  case (state)
  INIT:
    if (cnt == 0 && DOPULL) state_next = DELAY_ADJUST;
    else                    state_next = state;
  DELAY_ADJUST:
    if (cnt == 0 && DOPULL) state_next = WORD_ALIGN;
    else                    state_next = state;
  WORD_ALIGN:
    if (cnt == 0 && DOPULL) state_next = DATA_TRANSFER;
    else                    state_next = state;
  DATA_TRANSFER:
    if (cnt == 0 && DOPULL) state_next = DELAY_ADJUST;
    else                    state_next = state;
  endcase

always @(posedge CLK or negedge RSTX)
  if (!RSTX)    DOPUSH <= 1'b0;
  else if (CLR) DOPUSH <= 1'b0;
  else          DOPUSH <= DOPULL
                       && (  state_next == DELAY_ADJUST
                          || state_next == WORD_ALIGN
                          || state_next == DATA_TRANSFER );

reg [9:0] cnt_next;
always @*
  if (!DOPULL)      cnt_next = cnt;
  else if (state != state_next)
    case (state_next)
    DELAY_ADJUST  : cnt_next =  10'd255;
    WORD_ALIGN    : cnt_next =    10'd0;
    DATA_TRANSFER : cnt_next = 10'd1023;
    default       : cnt_next =    10'd0;
    endcase
  else              cnt_next = cnt - 10'd1;

always @(posedge CLK or negedge RSTX)
  if (!RSTX)        cnt <= 10'd63;
  else if (CLR)     cnt <= 10'd63;
  else              cnt <= cnt_next;

always @(posedge CLK or negedge RSTX)
  if (!RSTX)    PHY_INIT <= 1'b0;
  else if (CLR) PHY_INIT <= 1'b0;
  else          PHY_INIT <= state_next == DELAY_ADJUST
                         && 10'd64 < cnt_next
                         && cnt_next < 10'd196;

reg  [63:0] test_data;
wire [63:0] test_data_inc;
lfsr32x2 i_lfsr32x2 (.DIN(test_data), .DOUT(test_data_inc));
wire [63:0] test_data_next = DOPULL && state_next == DATA_TRANSFER
                           ? test_data_inc
                           : test_data;
always @(posedge CLK or negedge RSTX)
  if (!RSTX)    test_data <= 64'd0;
  else if (CLR) test_data <= 64'd0;
  else          test_data <= test_data_next;

always @(posedge CLK or negedge RSTX)
  if (!RSTX)       DOUT <= 64'd0;
  else if (CLR)    DOUT <= 64'd0;
  else
    case (state_next)
    DELAY_ADJUST :
      if (10'd32 < cnt_next && cnt_next < 10'd224)
                   DOUT <= 64'hAAAA_AAAA_AAAA_AAAA;
      else         DOUT <=                   64'd0;
    WORD_ALIGN   : DOUT <= 64'hF731_8CEF_137F_FEC8;
    DATA_TRANSFER: DOUT <=          test_data_next;
    default      : DOUT <=                   64'd0;
    endcase

endmodule
