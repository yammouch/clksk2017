///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.0
//  \   \        Filename: top_nto1_pll_16_diff_rx_and_tx.v
//  /   /        Date Last Modified:  May 18 2010
// /___/   /\    Date Created: May 18 2010
// \   \  /  \
//  \___\/\___\
// 
//Device: 	Spartan 6
//Purpose:  	Example differential input receiver and transmitter for clock and data using PLL
//		Serdes factor and number of data lines are set by constants in the code
//		Version for serdes factors of 10, 12, 14 and 16
//Reference:
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//
///////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer: 
//
//		This disclaimer is not a license and does not grant any rights to the materials 
//              distributed herewith. Except as otherwise provided in a valid license issued to you 
//              by Xilinx, and to the maximum extent permitted by applicable law: 
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
//              or tort, including negligence, or under any other theory of liability) for any loss or damage 
//              of any kind or nature related to, arising under or in connection with these materials, 
//              including for any direct, or any indirect, special, incidental, or consequential loss 
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
//              as a result of any action brought by a third party) even if such damage or loss was 
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
//		requiring fail-safe performance, such as life-support or safety devices or systems, 
//		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//		or any other applications that could lead to death, personal injury, or severe property or 
//		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
//		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
//		to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module top_nto1_pll_16_diff_rx_and_tx (
input		reset,				// reset (active high)
input	[5:0]	datain_p, datain_n,		// lvds data inputs
input		clkin_p,  clkin_n,		// lvds clock input
output	[5:0]	dataout_p, dataout_n,		// lvds data outputs
output		clkout_p,  clkout_n) ;		// lvds clock output

// Parameters for serdes factor and number of IO pins

parameter integer     S = 16 ;			// Set the serdes factor to 8
parameter integer     D = 6 ;			// Set the number of inputs and outputs
parameter integer     DS = (D*S)-1 ;		// Used for bus widths = serdes factor * number of inputs - 1

wire       	rst ;
wire	[DS:0] 	rxd ;				// Data from serdeses
reg	[DS:0] 	txd ;				// Data to serdeses
wire	[S-1:0]	clk_iserdes_data ;

parameter [S-1:0] TX_CLK_GEN   = 16'h00FF ;	// Transmit a constant to make a clock

assign rst = reset ; 				// active high reset pin

// Clock Input. Generate ioclocks via BUFIO2

serdes_1_to_n_clk_pll_s16_diff #(
      	.S			(S), 		
      	.CLKIN_PERIOD		(16.000),
	.PLLD 			(1),
      	.PLLX			(S),
	.BS 			("TRUE"),    		// Parameter to enable bitslip TRUE or FALSE (has to be true for video applications)
      	.DIFF_TERM		("TRUE"))		// Enable or disable diff termination
inst_clkin (
	.clkin_p   		(clkin_p),
	.clkin_n   		(clkin_n),
	.rxioclk    		(rx_bufpll_clk_xn),
	.pattern1		(16'h00FF),		// pattern to searh for
	.rx_serdesstrobe	(rx_serdesstrobe),
	.rx_bufg_pll_x1		(rx_bufg_x1),
	.rx_bufg_pll_x2		(rx_bufg_x2),
	.bitslip   		(bitslip),
	.reset     		(rst),
	.datain  		(clk_iserdes_data),
	.rx_toggle 		(rx_toggle),		
	.rx_bufpll_lckd		(rx_bufpll_lckd)) ;
	
// Data Inputs

assign not_bufpll_lckd = ~rx_bufpll_lckd ;

serdes_1_to_n_data_s16_diff #(
      	.S			(S),			
      	.D			(D),
      	.DIFF_TERM		("TRUE"))		// Enable or disable diff termination
inst_datain (
	.use_phase_detector 	(1'b1),			// '1' enables the phase detector logic
	.datain_p     		(datain_p),
	.datain_n     		(datain_n),
	.rxioclk    		(rx_bufpll_clk_xn),
	.rx_serdesstrobe 	(rx_serdesstrobe),
	.rx_bufg_pll_x1		(rx_bufg_x1),
	.rx_bufg_pll_x2		(rx_bufg_x2),
	.bitslip   		(bitslip),
	.reset   		(not_bufpll_lckd),
	.data_out  		(rxd),
	.rx_toggle 		(rx_toggle),		
	.debug_in  		(2'b00),
	.debug    		());

always @ (posedge rx_bufg_x1)				// process received data
begin
	txd <= rxd ;
end

// Transmitter Logic - Instantiate serialiser to generate forwarded clock and output data lines

serdes_n_to_1_s16_diff #(
      	.S			(S),
      	.D			(D))
inst_clk_data_out (
	.clkout_p  		(clkout_p),
	.clkout_n  		(clkout_n),
	.dataout_p  		(dataout_p),
	.dataout_n  		(dataout_n),
	.txioclk    		(rx_bufpll_clk_xn),
	.txserdesstrobe 	(rx_serdesstrobe),
	.tx_bufg_pll_x1		(rx_bufg_x1),
	.tx_bufg_pll_x2		(rx_bufg_x2),
	.reset     		(rst),
	.datain  		(txd),
	.clkin  		(TX_CLK_GEN));			// Transmit a constant to make the clock
	
endmodule
