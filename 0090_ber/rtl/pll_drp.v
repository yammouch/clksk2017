///////////////////////////////////////////////////////////////////////////////
//
// Company:          Xilinx
// Engineer:         Karl Kurbjun and Carl Ribbing
// Date:             12/10/2009
// Design Name:      PLL DRP
// Module Name:      pll_drp.v
// Version:          1.1
// Target Devices:   Spartan 6 Family
// Tool versions:    L.68 (lin)
// Description:      This calls the DRP register calculation functions and
//                   provides a state machine to perform PLL reconfiguration
//                   based on the calulated values stored in a initialized ROM.
//
//    Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
//                 INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
//                 PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
//                 PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
//                 ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
//                 APPLICATION OR STANDARD, XILINX IS MAKING NO
//                 REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
//                 FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
//                 RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
//                 REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
//                 EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
//                 RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
//                 INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//                 REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
//                 FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
//                 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//                 PURPOSE.
// 
//                 (c) Copyright 2008 Xilinx, Inc.
//                 All rights reserved.
// 
///////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module pll_drp (
      // These signals are controlled by user logic interface and are covered
      // in more detail within the XAPP.
      input      [7:0]  SADDR,
      input             SEN,
      input             SCLK,
      input             RST,
      output reg        SRDY,
      
      // These signals are to be connected to the PLL_ADV by port name.
      // Their use matches the PLL port description in the Device User Guide.
      input      [15:0] DO,
      input             DRDY,
      input             LOCKED,
      output reg        DWE,
      output reg        DEN,
      output reg [4:0]  DADDR,
      output reg [15:0] DI,
      output            DCLK,
      output reg        RST_PLL
   );

   // 100 ps delay for behavioral simulations
   localparam  TCQ = 100;

   reg [4:0]   rom_addr;
   reg [36:0]  rom_do;
   
   reg         next_srdy;

   reg [4:0]   next_rom_addr;
   reg [4:0]   next_daddr;
   reg         next_dwe;
   reg         next_den;
   reg         next_rst_pll;
   reg [15:0]  next_di;

   // Integer used to initialize remainder of unused ROM
   integer     ii;
   
    // Pass SCLK to DCLK for the PLL
   assign DCLK = SCLK;
   // include the PLL reconfiguration functions.  This contains the constant
   // functions that are used in the calculations below.  This file is 
   // required.
   `include "pll_drp_func.h"

   function [36:0] pll_encode(
    input [4:0]   addr,
    input [31:0]  S1_CLKFBOUT_MULT,
    input [31:0]  S1_CLKOUT0_DIVIDE);
    reg [31:0]  S1_CLKFBOUT_PHASE;
    reg [8*9:0] S1_BANDWIDTH;
    reg [31:0]  S1_DIVCLK_DIVIDE;
    reg [31:0]  S1_CLKOUT0_PHASE;
    reg [31:0]  S1_CLKOUT0_DUTY;
    reg [31:0]  S1_CLKOUT1_DIVIDE;
    reg [31:0]  S1_CLKOUT1_PHASE;
    reg [31:0]  S1_CLKOUT1_DUTY;
    reg [31:0]  S1_CLKOUT2_DIVIDE;
    reg [31:0]  S1_CLKOUT2_PHASE;
    reg [31:0]  S1_CLKOUT2_DUTY;
    reg [31:0]  S1_CLKOUT3_DIVIDE;
    reg [31:0]  S1_CLKOUT3_PHASE;
    reg [31:0]  S1_CLKOUT3_DUTY;
    reg [31:0]  S1_CLKOUT4_DIVIDE;
    reg [31:0]  S1_CLKOUT4_PHASE;
    reg [31:0]  S1_CLKOUT4_DUTY;
    reg [31:0]  S1_CLKOUT5_DIVIDE;
    reg [31:0]  S1_CLKOUT5_PHASE;
    reg [31:0]  S1_CLKOUT5_DUTY;
    reg [22:0]  S1_CLKFBOUT;
    reg [22:0]  S1_CLKFBOUT2;
    reg [9:0]   S1_DIGITAL_FILT;
    reg [39:0]  S1_LOCK;
    reg [22:0]  S1_DIVCLK;
    reg [22:0]  S1_CLKOUT0;
    reg [22:0]  S1_CLKOUT1;
    reg [22:0]  S1_CLKOUT2;
    reg [22:0]  S1_CLKOUT3;
    reg [22:0]  S1_CLKOUT4;
    reg [22:0]  S1_CLKOUT5;
    begin
     S1_CLKFBOUT_PHASE = 0;
     S1_BANDWIDTH      = "LOW";
     S1_DIVCLK_DIVIDE  = 1;
     S1_CLKOUT0_PHASE  = 0;
     S1_CLKOUT0_DUTY   = 50000;
     S1_CLKOUT1_DIVIDE = 128;
     S1_CLKOUT1_PHASE  = 0;
     S1_CLKOUT1_DUTY   = 50000;
     S1_CLKOUT2_DIVIDE = 128;
     S1_CLKOUT2_PHASE  = 0;
     S1_CLKOUT2_DUTY   = 50000;
     S1_CLKOUT3_DIVIDE = 128;
     S1_CLKOUT3_PHASE  = 0;
     S1_CLKOUT3_DUTY   = 50000;
     S1_CLKOUT4_DIVIDE = 128;
     S1_CLKOUT4_PHASE  = 0;
     S1_CLKOUT4_DUTY   = 50000;
     S1_CLKOUT5_DIVIDE = 128;
     S1_CLKOUT5_PHASE  = 0;
     S1_CLKOUT5_DUTY   = 50000;
     S1_CLKFBOUT =
      s6_pll_count_calc(S1_CLKFBOUT_MULT, S1_CLKFBOUT_PHASE, 50000);
	  
     S1_CLKFBOUT2 =
      s6_pll_count_calc(S1_CLKFBOUT_MULT, S1_CLKFBOUT_PHASE, 50000);
      
     S1_DIGITAL_FILT = 
      s6_pll_filter_lookup(S1_CLKFBOUT_MULT, S1_BANDWIDTH);
      
     S1_LOCK =
      s6_pll_lock_lookup(S1_CLKFBOUT_MULT);
      
     S1_DIVCLK = 
      s6_pll_count_calc(S1_DIVCLK_DIVIDE, 0, 50000); 
      
     S1_CLKOUT0 =
      s6_pll_count_calc(S1_CLKOUT0_DIVIDE, S1_CLKOUT0_PHASE, S1_CLKOUT0_DUTY); 
         
     S1_CLKOUT1 = 
      s6_pll_count_calc(S1_CLKOUT1_DIVIDE, S1_CLKOUT1_PHASE, S1_CLKOUT1_DUTY); 
         
     S1_CLKOUT2 = 
      s6_pll_count_calc(S1_CLKOUT2_DIVIDE, S1_CLKOUT2_PHASE, S1_CLKOUT2_DUTY); 
         
     S1_CLKOUT3 = 
      s6_pll_count_calc(S1_CLKOUT3_DIVIDE, S1_CLKOUT3_PHASE, S1_CLKOUT3_DUTY); 
         
     S1_CLKOUT4 = 
      s6_pll_count_calc(S1_CLKOUT4_DIVIDE, S1_CLKOUT4_PHASE, S1_CLKOUT4_DUTY); 
         
     S1_CLKOUT5 = 
      s6_pll_count_calc(S1_CLKOUT5_DIVIDE, S1_CLKOUT5_PHASE, S1_CLKOUT5_DUTY);    

     case (addr)
      5'd0 : pll_encode =
      {5'h05, 16'h50FF,  S1_CLKOUT0[19], 1'b0, S1_CLKOUT0[18], 1'b0,//bits 15 down to 12
                               S1_CLKOUT0[16], S1_CLKOUT0[17], S1_CLKOUT0[15], S1_CLKOUT0[14], 8'h00};//bits 11 downto 0
      5'd1: pll_encode =
      {5'h06, 16'h010B,  S1_CLKOUT1[4], S1_CLKOUT1[5], S1_CLKOUT1[3], S1_CLKOUT1[12], //bits 15 down to 12
                         S1_CLKOUT1[1], S1_CLKOUT1[2], S1_CLKOUT1[19], 1'b0, S1_CLKOUT1[17], S1_CLKOUT1[16], //bits 11 down to 6
                         S1_CLKOUT1[14], S1_CLKOUT1[15], 1'b0, S1_CLKOUT0[13], 2'b00}; //bits 5 down to 0
      5'd2: pll_encode =
      {5'h07, 16'hE02C,  3'b000, S1_CLKOUT1[11], S1_CLKOUT1[9], S1_CLKOUT1[10], //bits 15 down to 10
                         S1_CLKOUT1[8], S1_CLKOUT1[7], S1_CLKOUT1[6], S1_CLKOUT1[20], 1'b0, S1_CLKOUT1[13], //bits 9 down to 4 
                         2'b00, S1_CLKOUT1[21], S1_CLKOUT1[22]}; //bits 3 down to 0
      5'd3: pll_encode =
      {5'h08, 16'h4001,  S1_CLKOUT2[22], 1'b0, S1_CLKOUT2[5], S1_CLKOUT2[21], //bits 15 downto 12
                         S1_CLKOUT2[12], S1_CLKOUT2[4], S1_CLKOUT2[3], S1_CLKOUT2[2], S1_CLKOUT2[0], S1_CLKOUT2[19], //bits 11 down to 6
                         S1_CLKOUT2[17], S1_CLKOUT2[18], S1_CLKOUT2[15], S1_CLKOUT2[16], S1_CLKOUT2[14], 1'b0}; //bits 5 down to 0
      5'd4: pll_encode =
      {5'h09, 16'h0D03,  S1_CLKOUT3[14], S1_CLKOUT3[15], S1_CLKOUT0[21], S1_CLKOUT0[22], 2'b00, S1_CLKOUT2[10], 1'b0, //bits 15 downto 8
                         S1_CLKOUT2[9], S1_CLKOUT2[8], S1_CLKOUT2[6], S1_CLKOUT2[7], S1_CLKOUT2[13], S1_CLKOUT2[20], 2'b00}; //bits 7 downto 0
      5'd5: pll_encode =
      {5'h0A, 16'hB001,  1'b0, S1_CLKOUT3[13], 2'b00, S1_CLKOUT3[21], S1_CLKOUT3[22], S1_CLKOUT3[5], S1_CLKOUT3[4], //bits 15 downto 8
                         S1_CLKOUT3[12], S1_CLKOUT3[2], S1_CLKOUT3[0], S1_CLKOUT3[1], S1_CLKOUT3[18], S1_CLKOUT3[19], //bits 7 downto 2
                         S1_CLKOUT3[17], 1'b0}; //bits 1 downto 0
      5'd6: pll_encode =
      {5'h0B, 16'h0110,  S1_CLKOUT0[5], S1_CLKOUT4[19], S1_CLKOUT4[14], S1_CLKOUT4[17], //bits 15 downto 12
                         S1_CLKOUT4[15], S1_CLKOUT4[16], S1_CLKOUT0[4], 1'b0, S1_CLKOUT3[11], S1_CLKOUT3[10], //bits 11 downto 6 
                         S1_CLKOUT3[9], 1'b0, S1_CLKOUT3[7], S1_CLKOUT3[8], S1_CLKOUT3[20], S1_CLKOUT3[6]}; //bits 5 downto 0
      5'd7: pll_encode =
      {5'h0C, 16'h0B00,  S1_CLKOUT4[7], S1_CLKOUT4[8], S1_CLKOUT4[20], S1_CLKOUT4[6], 1'b0, S1_CLKOUT4[13], //bits 15 downto 10
                         2'b00, S1_CLKOUT4[22], S1_CLKOUT4[21], S1_CLKOUT4[4], S1_CLKOUT4[5], S1_CLKOUT4[3], //bits 9 downto 3
                         S1_CLKOUT4[12], S1_CLKOUT4[1], S1_CLKOUT4[2]}; //bits 2 downto 0
      5'd8: pll_encode =
      {5'h0D, 16'h0008,  S1_CLKOUT5[2], S1_CLKOUT5[3], S1_CLKOUT5[0], S1_CLKOUT5[1], S1_CLKOUT5[18], //bits 15 downto 11
                         S1_CLKOUT5[19], S1_CLKOUT5[17], S1_CLKOUT5[16], S1_CLKOUT5[15], S1_CLKOUT0[3], //bits 10 downto 6
                         S1_CLKOUT0[0], S1_CLKOUT0[2], 1'b0, S1_CLKOUT4[11], S1_CLKOUT4[9], S1_CLKOUT4[10]}; //bits 5 downto 0
      5'd9: pll_encode =
      {5'h0E, 16'h00D0,  S1_CLKOUT5[10], S1_CLKOUT5[11], S1_CLKOUT5[8], S1_CLKOUT5[9], S1_CLKOUT5[6], //bits 15 downto 11
                         S1_CLKOUT5[7], S1_CLKOUT5[20], S1_CLKOUT5[13], 2'b00, S1_CLKOUT5[22], 1'b0, //bits 10 downto 4
                         S1_CLKOUT5[5], S1_CLKOUT5[21], S1_CLKOUT5[12], S1_CLKOUT5[4]}; //bits 3 downto 0
      5'd10: pll_encode =
      {5'h0F, 16'h0003, S1_CLKFBOUT[4], S1_CLKFBOUT[5], S1_CLKFBOUT[3], S1_CLKFBOUT[12], S1_CLKFBOUT[1], //bits 15 downto 11
                        S1_CLKFBOUT[2], S1_CLKFBOUT[0], S1_CLKFBOUT[19], S1_CLKFBOUT[18], S1_CLKFBOUT[17], //bits 10 downto 6
                        S1_CLKFBOUT[15], S1_CLKFBOUT[16], S1_CLKOUT0[12], S1_CLKOUT0[1], 2'b00}; //bits 5 downto 0
      5'd11: pll_encode =
      {5'h10, 16'h800C, 1'b0, S1_CLKOUT0[9], S1_CLKOUT0[11], S1_CLKOUT0[10], S1_CLKFBOUT[10], S1_CLKFBOUT[11], //bits 15 downto 10
                        S1_CLKFBOUT[9], S1_CLKFBOUT[8], S1_CLKFBOUT[7], S1_CLKFBOUT[6], S1_CLKFBOUT[13],  //bits 9 downto 5
                        S1_CLKFBOUT[20], 2'b00, S1_CLKFBOUT[21], S1_CLKFBOUT[22]}; //bits 4 downto 0
      5'd12: pll_encode =
      {5'h11, 16'hFC00, 6'h00, S1_CLKOUT3[3], S1_CLKOUT3[16], S1_CLKOUT2[11], S1_CLKOUT2[1], S1_CLKOUT1[18], //bits 15 downto 6
                        S1_CLKOUT1[0], S1_CLKOUT0[6], S1_CLKOUT0[20], S1_CLKOUT0[8], S1_CLKOUT0[7]}; //bits 5 downto 0
      5'd13: pll_encode =
      {5'h12, 16'hF0FF, 4'h0, S1_CLKOUT5[14], S1_CLKFBOUT[14], S1_CLKOUT4[0], S1_CLKOUT4[18],  8'h00};  //bits 15 downto 0
      5'd14: pll_encode =
      {5'h13, 16'h5120, S1_DIVCLK[11], 1'b0, S1_DIVCLK[10], 1'b0, S1_DIVCLK[7], S1_DIVCLK[8],  //bits 15 downto 10
                        S1_DIVCLK[0], 1'b0, S1_DIVCLK[5], S1_DIVCLK[2], 1'b0, S1_DIVCLK[13], 4'h0};  //bits 9 downto 0
      5'd15: pll_encode =
      {5'h14, 16'h2FFF, S1_LOCK[1], S1_LOCK[2], 1'b0, S1_LOCK[0], 12'h000}; //bits 15 downto 0
      5'd16: pll_encode =
      {5'h15, 16'hBFF4, 1'b0, S1_DIVCLK[12], 10'h000, S1_LOCK[38], 1'b0, S1_LOCK[32], S1_LOCK[39]}; //bits 15 downto 0								  
      5'd17: pll_encode =
      {5'h16, 16'h0A55, S1_LOCK[15], S1_LOCK[13], S1_LOCK[27], S1_LOCK[16], 1'b0, S1_LOCK[10],   //bits 15 downto 10
                        1'b0, S1_DIVCLK[9], S1_DIVCLK[1], 1'b0, S1_DIVCLK[6], 1'b0, S1_DIVCLK[3],  //bits 9 downto 3
                        1'b0, S1_DIVCLK[4], 1'b0};  //bits 2 downto 0
      5'd18: pll_encode =
      {5'h17, 16'hFFD0, 10'h000, S1_LOCK[17], 1'b0, S1_LOCK[8], S1_LOCK[9], S1_LOCK[23], S1_LOCK[22]}; //bits 15 downto 0	  
      5'd19: pll_encode = 
      {5'h18, 16'h1039, S1_DIGITAL_FILT[6], S1_DIGITAL_FILT[7], S1_DIGITAL_FILT[0], 1'b0, //bits 15 downto 12
                        S1_DIGITAL_FILT[2], S1_DIGITAL_FILT[1], S1_DIGITAL_FILT[3], S1_DIGITAL_FILT[9], //bits 11 downto 8
                        S1_DIGITAL_FILT[8], S1_LOCK[26], 3'h0, S1_LOCK[19], S1_LOCK[18], 1'b0}; //bits 7 downto 0								
      5'd20: pll_encode =
      {5'h19, 16'h0000, S1_LOCK[24], S1_LOCK[25], S1_LOCK[21], S1_LOCK[14], S1_LOCK[11], //bits 15 downto 11
                        S1_LOCK[12], S1_LOCK[20], S1_LOCK[6], S1_LOCK[35], S1_LOCK[36], //bits 10 downto 6
                        S1_LOCK[37], S1_LOCK[3], S1_LOCK[33], S1_LOCK[31], S1_LOCK[34], S1_LOCK[30]}; //bits 5 downto 0
      5'd21: pll_encode =
      {5'h1A, 16'hFFFC, 14'h0000, S1_LOCK[28], S1_LOCK[29]};  //bits 15 downto 0
      5'd22: pll_encode =
      {5'h1D, 16'h2FFF, S1_LOCK[7], S1_LOCK[4], 1'b0, S1_LOCK[5], 12'h000};	//bits 15 downto 0
      default: pll_encode = 37'dx;
     endcase
    end
   endfunction

   // Output the initialized rom value based on rom_addr each clock cycle
   always @(posedge SCLK) begin
      case (SADDR) // 2nd arg: multiplier, 3rd arg: divisor, src: 25 MHz
      8'd1   : rom_do <= #TCQ pll_encode(rom_addr, 32, 32); //  25 MHz
      8'd2   : rom_do <= #TCQ pll_encode(rom_addr, 32, 16); //  50 MHz
      8'd3   : rom_do <= #TCQ pll_encode(rom_addr, 24,  8); //  75 MHz
      8'd4   : rom_do <= #TCQ pll_encode(rom_addr, 32,  8); // 100 MHz
      8'd5   : rom_do <= #TCQ pll_encode(rom_addr, 20,  4); // 125 MHz
      8'd6   : rom_do <= #TCQ pll_encode(rom_addr, 24,  4); // 150 MHz
      8'd7   : rom_do <= #TCQ pll_encode(rom_addr, 28,  4); // 175 MHz
      8'd8   : rom_do <= #TCQ pll_encode(rom_addr, 32,  4); // 200 MHz
      8'd9   : rom_do <= #TCQ pll_encode(rom_addr, 36,  4); // 225 MHz
      8'd10  : rom_do <= #TCQ pll_encode(rom_addr, 20,  2); // 250 MHz
      8'd11  : rom_do <= #TCQ pll_encode(rom_addr, 22,  2); // 275 MHz
      8'd12  : rom_do <= #TCQ pll_encode(rom_addr, 24,  2); // 300 MHz
      8'd13  : rom_do <= #TCQ pll_encode(rom_addr, 26,  2); // 325 MHz
      8'd14  : rom_do <= #TCQ pll_encode(rom_addr, 28,  2); // 350 MHz
      8'd15  : rom_do <= #TCQ pll_encode(rom_addr, 30,  2); // 375 MHz
      8'd16  : rom_do <= #TCQ pll_encode(rom_addr, 32,  2); // 400 MHz
      8'd17  : rom_do <= #TCQ pll_encode(rom_addr, 34,  2); // 425 MHz
      8'd18  : rom_do <= #TCQ pll_encode(rom_addr, 36,  2); // 450 MHz
      8'd19  : rom_do <= #TCQ pll_encode(rom_addr, 38,  2); // 475 MHz
      8'd20  : rom_do <= #TCQ pll_encode(rom_addr, 40,  2); // 500 MHz
      default: rom_do <= #TCQ pll_encode(rom_addr, 32, 32); //  25 MHz
      endcase
   end
   
   //**************************************************************************
   // Everything below is associated whith the state machine that is used to
   // Read/Modify/Write to the PLL.
   //**************************************************************************

   // State Definitions
   localparam RESTART      = 4'h1;
   localparam WAIT_LOCK    = 4'h2;
   localparam WAIT_SEN     = 4'h3;
   localparam ADDRESS      = 4'h4;
   localparam WAIT_A_DRDY  = 4'h5;
   localparam BITMASK      = 4'h6;
   localparam BITSET       = 4'h7;
   localparam WRITE        = 4'h8;
   localparam WAIT_DRDY    = 4'h9;
   
   // State sync
   reg [3:0]  current_state   = RESTART;
   reg [3:0]  next_state      = RESTART;
   
   // These variables are used to keep track of the number of iterations that 
   //    each state takes to reconfigure
   // STATE_COUNT_CONST is used to reset the counters and should match the
   //    number of registers necessary to reconfigure each state.
   localparam STATE_COUNT_CONST = 23;
   reg [4:0] state_count         = STATE_COUNT_CONST; 
   reg [4:0] next_state_count    = STATE_COUNT_CONST;
   
   // This block assigns the next register value from the state machine below
   always @(posedge SCLK) begin
      DADDR       <= #TCQ next_daddr;
      DWE         <= #TCQ next_dwe;
      DEN         <= #TCQ next_den;
      RST_PLL     <= #TCQ next_rst_pll;
      DI          <= #TCQ next_di;
      
      SRDY        <= #TCQ next_srdy;
      
      rom_addr    <= #TCQ next_rom_addr;
      state_count <= #TCQ next_state_count;
   end
   
   // This block assigns the next state, reset is syncronous.
   always @(posedge SCLK) begin
      if(RST) begin
         current_state <= #TCQ RESTART;
      end else begin
         current_state <= #TCQ next_state;
      end
   end
   
   always @* begin
      // Setup the default values
      next_srdy         = 1'b0;
      next_daddr        = DADDR;
      next_dwe          = 1'b0;
      next_den          = 1'b0;
      next_rst_pll      = RST_PLL;
      next_di           = DI;
      next_rom_addr     = rom_addr;
      next_state_count  = state_count;
   
      case (current_state)
         // If RST is asserted reset the machine
         RESTART: begin
            next_daddr     = 5'h00;
            next_di        = 16'h0000;
            next_rom_addr  = 5'h00;
            next_rst_pll   = 1'b1;
            next_state     = WAIT_LOCK;
         end
         
         // Waits for the PLL to assert LOCKED - once it does asserts SRDY
         WAIT_LOCK: begin
            // Make sure reset is de-asserted
            next_rst_pll   = 1'b0;
            // Reset the number of registers left to write for the next 
            // reconfiguration event.
            next_state_count = STATE_COUNT_CONST;
            
            if(LOCKED) begin
               // PLL is locked, go on to wait for the SEN signal
               next_state  = WAIT_SEN;
               // Assert SRDY to indicate that the reconfiguration module is
               // ready
               next_srdy   = 1'b1;
            end else begin
               // Keep waiting, locked has not asserted yet
               next_state  = WAIT_LOCK;
            end
         end
         
         // Wait for the next SEN pulse and set the ROM addr appropriately 
         //    based on SADDR
         WAIT_SEN: begin
            if(SEN) begin
               // SEN was asserted
               next_rom_addr = 5'h00;
               // Go on to address the PLL
               next_state = ADDRESS;
            end else begin
               // Keep waiting for SEN to be asserted
               next_state = WAIT_SEN;
            end
         end
         
         // Set the address on the PLL and assert DEN to read the value
         ADDRESS: begin
            // Reset the DCM through the reconfiguration
            next_rst_pll  = 1'b1;
            // Enable a read from the PLL and set the PLL address
            next_den       = 1'b1;
            next_daddr     = rom_do[36:32];
            
            // Wait for the data to be ready
            next_state     = WAIT_A_DRDY;
         end
         
         // Wait for DRDY to assert after addressing the PLL
         WAIT_A_DRDY: begin
            if(DRDY) begin
               // Data is ready, mask out the bits to save
               next_state = BITMASK;
            end else begin
               // Keep waiting till data is ready
               next_state = WAIT_A_DRDY;
            end
         end
         
         // Zero out the bits that are not set in the mask stored in rom
         BITMASK: begin
            // Do the mask
            next_di     = rom_do[31:16] & DO;
            // Go on to set the bits
            next_state  = BITSET;
         end
         
         // After the input is masked, OR the bits with calculated value in rom
         BITSET: begin
            // Set the bits that need to be assigned
            next_di           = rom_do[15:0] | DI;
            // Set the next address to read from ROM
            next_rom_addr     = rom_addr + 5'b1;
            // Go on to write the data to the PLL
            next_state        = WRITE;
         end
         
         // DI is setup so assert DWE, DEN, and RST_PLL.  Subtract one from the
         //    state count and go to wait for DRDY.
         WRITE: begin
            // Set WE and EN on PLL
            next_dwe          = 1'b1;
            next_den          = 1'b1;
            
            // Decrement the number of registers left to write
            next_state_count  = state_count - 1'b1;
            // Wait for the write to complete
            next_state        = WAIT_DRDY;
         end
         
         // Wait for DRDY to assert from the PLL.  If the state count is not 0
         //    jump to ADDRESS (continue reconfiguration).  If state count is
         //    0 wait for lock.
         WAIT_DRDY: begin
            if(DRDY) begin
               // Write is complete
               if(state_count > 0) begin
                  // If there are more registers to write keep going
                  next_state  = ADDRESS;
               end else begin
                  // There are no more registers to write so wait for the PLL
                  // to lock
                  next_state  = WAIT_LOCK;
               end
            end else begin
               // Keep waiting for write to complete
               next_state     = WAIT_DRDY;
            end
         end
         
         // If in an unknown state reset the machine
         default: begin
            next_state = RESTART;
         end
      endcase
   end
   
endmodule
