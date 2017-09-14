///////////////////////////////////////////////////////
//  Copyright (c) 2008 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version     : 
//  \  \           Description : 
//  /  /                      
// /__/   /\       Filename    : PLL_ADV.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:	
//    10/04/11 - Initial version 
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module PLL_ADV (
        CLKFBDCM,
        CLKFBOUT,
        CLKOUT0,
        CLKOUT1,
        CLKOUT2,
        CLKOUT3,
        CLKOUT4,
        CLKOUT5,
        CLKOUTDCM0,
        CLKOUTDCM1,
        CLKOUTDCM2,
        CLKOUTDCM3,
        CLKOUTDCM4,
        CLKOUTDCM5,
        DO,
        DRDY,
        LOCKED,
        CLKFBIN,
        CLKIN1,
        CLKIN2,
        CLKINSEL,
        DADDR,
        DCLK,
        DEN,
        DI,
        DWE,
        REL,
        RST
);
parameter BANDWIDTH = "OPTIMIZED";
parameter CLK_FEEDBACK = "CLKFBOUT";
parameter CLKFBOUT_DESKEW_ADJUST = "NONE";
parameter CLKOUT0_DESKEW_ADJUST = "NONE";
parameter CLKOUT1_DESKEW_ADJUST = "NONE";
parameter CLKOUT2_DESKEW_ADJUST = "NONE";
parameter CLKOUT3_DESKEW_ADJUST = "NONE";
parameter CLKOUT4_DESKEW_ADJUST = "NONE";
parameter CLKOUT5_DESKEW_ADJUST = "NONE";
parameter integer CLKFBOUT_MULT = 1;
parameter real CLKFBOUT_PHASE = 0.0;
parameter real CLKIN1_PERIOD = 0.000;
parameter real CLKIN2_PERIOD = 0.000;
parameter integer CLKOUT0_DIVIDE = 1;
parameter real CLKOUT0_DUTY_CYCLE = 0.5;
parameter real CLKOUT0_PHASE = 0.0;
parameter integer CLKOUT1_DIVIDE = 1;
parameter real CLKOUT1_DUTY_CYCLE = 0.5;
parameter real CLKOUT1_PHASE = 0.0;
parameter integer CLKOUT2_DIVIDE = 1;
parameter real CLKOUT2_DUTY_CYCLE = 0.5;
parameter real CLKOUT2_PHASE = 0.0;
parameter integer CLKOUT3_DIVIDE = 1;
parameter real CLKOUT3_DUTY_CYCLE = 0.5;
parameter real CLKOUT3_PHASE = 0.0;
parameter integer CLKOUT4_DIVIDE = 1;
parameter real CLKOUT4_DUTY_CYCLE = 0.5;
parameter real CLKOUT4_PHASE = 0.0;
parameter integer CLKOUT5_DIVIDE = 1;
parameter real CLKOUT5_DUTY_CYCLE = 0.5;
parameter real CLKOUT5_PHASE = 0.0;
parameter COMPENSATION = "SYSTEM_SYNCHRONOUS";
parameter integer DIVCLK_DIVIDE = 1;
parameter EN_REL = "FALSE";
parameter PLL_PMCD_MODE = "FALSE";
parameter real REF_JITTER = 0.100;
parameter RESET_ON_LOSS_OF_LOCK = "FALSE";
parameter RST_DEASSERT_CLK = "CLKIN1";
parameter SIM_DEVICE = "VIRTEX5";

output CLKFBDCM;
output CLKFBOUT;
output CLKOUT0;
output CLKOUT1;
output CLKOUT2;
output CLKOUT3;
output CLKOUT4;
output CLKOUT5;
output CLKOUTDCM0;
output CLKOUTDCM1;
output CLKOUTDCM2;
output CLKOUTDCM3;
output CLKOUTDCM4;
output CLKOUTDCM5;
output DRDY;
output LOCKED;
output [15:0] DO;

input CLKFBIN;
input CLKIN1;
input CLKIN2;
input CLKINSEL;
input DCLK;
input DEN;
input DWE;
input REL;
input RST;
input [15:0] DI;
input [4:0] DADDR;

localparam comp_val = (COMPENSATION == "SYSTEM_SYNCHRONOUS") ? "ZHOLD" :
                      (COMPENSATION == "SOURCE_SYNCHRONOUS") ? "BUF_IN" :
                      COMPENSATION; 

  PLLE2_ADV #(
            .BANDWIDTH(BANDWIDTH),
            .COMPENSATION(comp_val),
            .CLKOUT1_DIVIDE(CLKOUT1_DIVIDE),
            .CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),
            .CLKOUT3_DIVIDE(CLKOUT3_DIVIDE),
            .CLKOUT4_DIVIDE(CLKOUT4_DIVIDE),
            .CLKOUT5_DIVIDE(CLKOUT5_DIVIDE),
            .DIVCLK_DIVIDE(DIVCLK_DIVIDE),
            .CLKFBOUT_MULT(CLKFBOUT_MULT),
            .CLKFBOUT_PHASE(CLKFBOUT_PHASE),
            .CLKIN1_PERIOD(CLKIN1_PERIOD),
            .CLKIN2_PERIOD(CLKIN2_PERIOD),
            .CLKOUT0_DIVIDE(CLKOUT0_DIVIDE),
            .CLKOUT0_DUTY_CYCLE(CLKOUT0_DUTY_CYCLE),
            .CLKOUT0_PHASE(CLKOUT0_PHASE),
            .CLKOUT1_DUTY_CYCLE(CLKOUT1_DUTY_CYCLE),
            .CLKOUT1_PHASE(CLKOUT1_PHASE),
            .CLKOUT2_DUTY_CYCLE(CLKOUT2_DUTY_CYCLE),
            .CLKOUT2_PHASE(CLKOUT2_PHASE),
            .CLKOUT3_DUTY_CYCLE(CLKOUT3_DUTY_CYCLE),
            .CLKOUT3_PHASE(CLKOUT3_PHASE),
            .CLKOUT4_DUTY_CYCLE(CLKOUT4_DUTY_CYCLE),
            .CLKOUT4_PHASE(CLKOUT4_PHASE),
            .CLKOUT5_DUTY_CYCLE(CLKOUT5_DUTY_CYCLE),
            .CLKOUT5_PHASE(CLKOUT5_PHASE),
            .REF_JITTER1(REF_JITTER) 
      )
      plle2_adv_1 (
        .CLKFBIN (CLKFBIN),
        .CLKFBOUT (CLKFBOUT),
        .CLKIN1 (CLKIN1),
        .CLKIN2 (CLKIN2),
        .CLKINSEL (CLKINSEL),
        .CLKOUT0 (CLKOUT0),
        .CLKOUT1 (CLKOUT1),
        .CLKOUT2 (CLKOUT2),
        .CLKOUT3 (CLKOUT3),
        .CLKOUT4 (CLKOUT4),
        .CLKOUT5 (CLKOUT5),
        .DADDR ({2'b0, DADDR}),
        .DCLK (DCLK),
        .DEN (DEN),
        .DI (DI),
        .DO (DO),
        .DRDY (DRDY),
        .DWE (DWE),
        .LOCKED (LOCKED),
        .PWRDWN(PWRDWN),
        .RST (RST)
    );

  specify

      specparam PATHPULSE$ = 0;

  endspecify
endmodule
