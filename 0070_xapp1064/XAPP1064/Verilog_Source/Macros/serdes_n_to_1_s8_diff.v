////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.1
//  \   \        Filename: serdes_n_to_1_s8_diff.v
//  /   /        Date Last Modified:  May 5 2010
// /___/   /\    Date Created: August 1 2008
// \   \  /  \
//  \___\/\___\
// 
//Device: 	Spartan 6
//Purpose:  	D-bit generic n:1 transmitter module
// 		Takes in n bits of data and serialises this to 1 bit
// 		data is transmitted LSB first
// 		Parallel input word : D*S-1, D*S-2 ..... 1, 0
//		Serial output words when DATA_STRIPING = PER_CLOCK (default) :
//		Line0     : 0,   ...... D*S-(S+0)
// 		Line1 	  : 1,   ...... D*S-(S+1)
// 		Line(D-2) : .           .
// 		Line(D-1) : D-1, ...... D*S-1
//
//		Serial output words when DATA_STRIPING = PER_CHANL :
//		Line0     : 0,       ...... S-1
// 		Line1 	  : 1*S,     ...... 2*S-1
// 		Line(D-2) : .               .
// 		Line(D-1) : (D-1)*S, ...... D*S-1
//
//		Data inversion can be accomplished via the TX_SWAP_MASK 
//		parameter if required
//
//Reference:
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - Modified (nicks)
//		- OSERDES2 OUTPUT_MODE parameters changed to SINGLE_ENDED
//		- DATA_STRIPING added
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module serdes_n_to_1_s8_diff (txioclk, txserdesstrobe, reset, gclk, datain, dataout_p, dataout_n) ;

parameter integer 	S = 8 ;   			// Parameter to set the serdes factor 1..8
parameter integer 	D = 16 ;			// Set the number of inputs and outputs
parameter  		DATA_STRIPING = "PER_CLOCK" ;	// Used to determine method for mapping input parallel word to output serial words

input 			txioclk ;			// IO Clock network
input 			txserdesstrobe ;		// Parallel data capture strobe
input 			reset ;				// Reset
input 			gclk ;				// Global clock
input 	[D*S-1:0]	datain ;  			// Data for output
output 	[D-1:0]		dataout_p ;			// output data
output 	[D-1:0]		dataout_n ;			// output data
                                                	
wire	[D-1:0]		cascade_di ;			//
wire	[D-1:0]		cascade_do ;			//
wire	[D-1:0]		cascade_ti ;			//
wire	[D-1:0]		cascade_to ;			//
wire	[D-1:0]		tx_data_out ;			//
wire	[D*8-1:0]	mdataina ;			//
                                                	
parameter [D-1:0] TX_SWAP_MASK = 16'h0000 ;		// pinswap mask for output bits (0 = no swap (default), 1 = swap). Allows outputs to be connected the 'wrong way round' to ease PCB routing.

genvar i ;
genvar j ;

generate
for (i = 0 ; i <= (D-1) ; i = i+1)
begin : loop0

OBUFDS io_data_out (
	.O    			(dataout_p[i]),
	.OB       		(dataout_n[i]),
	.I         		(tx_data_out[i]));

for (j = 0 ; j <= 7 ; j = j+1)
begin : loop1
// re-arrange data bits for transmission, connect unused serdes inputs to '0' and invert lines as given by the mask
// NOTE If pin inversion is required (non-zero SWAP MASK) then inverters will be implemented in fabric, as there are no inverters in the ISERDES2 data inputs
// This can be avoided by doing the inversion (if required) in the user logic
if (DATA_STRIPING == "PER_CLOCK") begin 	
  if (j <= S-1) begin
    assign mdataina[(8*i)+j] = datain[i+(D*j)] ^ TX_SWAP_MASK[i] ;
  end
  if (j > S-1) begin
    assign mdataina[(8*i)+j] = 1'b0 ;
  end
end
if (DATA_STRIPING == "PER_CHANL") begin  	
  if (j <= S-1) begin
    assign mdataina[(8*i)+j] = datain[S*i+j] ^ TX_SWAP_MASK[i] ;
  end
  if (j > S-1) begin
    assign mdataina[(8*i)+j] = 1'b0 ;
  end
end
end

if (S > 4) begin 					// Two oserdes are needed for serdes > 4

OSERDES2 #(
	.DATA_WIDTH     	(S), 			// SERDES word width. 
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_OT      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("MASTER"), 		// <DEFAULT>, MASTER, SLAVE
	.OUTPUT_MODE 		("SINGLE_ENDED"))
oserdes_m (
	.OQ       		(tx_data_out[i]),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(gclk),
	.D4  			(mdataina[(8*i)+7]),
	.D3  			(mdataina[(8*i)+6]),
	.D2  			(mdataina[(8*i)+5]),
	.D1  			(mdataina[(8*i)+4]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TRAIN    		(1'b0),
	.TCE	   		(1'b1),
	.SHIFTIN1 		(1'b1),			// Dummy input in Master
	.SHIFTIN2 		(1'b1),			// Dummy input in Master
	.SHIFTIN3 		(cascade_do[i]),	// Cascade output D data from slave
	.SHIFTIN4 		(cascade_to[i]),	// Cascade output T data from slave
	.SHIFTOUT1 		(cascade_di[i]),	// Cascade input D data to slave
	.SHIFTOUT2 		(cascade_ti[i]),	// Cascade input T data to slave
	.SHIFTOUT3 		(),			// Dummy output in Master
	.SHIFTOUT4 		()) ;			// Dummy output in Master

OSERDES2 #(
	.DATA_WIDTH     	(S), 			// SERDES word width.
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_OT      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("SLAVE"), 		// <DEFAULT>, MASTER, SLAVE
	.OUTPUT_MODE 		("SINGLE_ENDED"))
oserdes_s (
	.OQ       		(),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(gclk),
	.D4  			(mdataina[(8*i)+3]),
	.D3  			(mdataina[(8*i)+2]),
	.D2  			(mdataina[(8*i)+1]),
	.D1  			(mdataina[(8*i)+0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3  			(1'b0),
	.T4  			(1'b0),
	.TRAIN 			(1'b0),
	.TCE	 		(1'b1),
	.SHIFTIN1 		(cascade_di[i]),	// Cascade input D from Master
	.SHIFTIN2 		(cascade_ti[i]),	// Cascade input T from Master
	.SHIFTIN3 		(1'b1),			// Dummy input in Slave
	.SHIFTIN4 		(1'b1),			// Dummy input in Slave
	.SHIFTOUT1 		(),			// Dummy output in Slave
	.SHIFTOUT2 		(),			// Dummy output in Slave
	.SHIFTOUT3 		(cascade_do[i]),   	// Cascade output D data to Master
	.SHIFTOUT4 		(cascade_to[i])) ; 	// Cascade output T data to Master
end

if (S < 5) begin 					// Only one oserdes needed for serdes < 5

OSERDES2 #(
	.DATA_WIDTH     	(S), 			// SERDES word width.
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_OT      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("NONE"), 		// <DEFAULT>, MASTER, SLAVE
	.OUTPUT_MODE 		("SINGLE_ENDED"))
oserdes_m (
	.OQ       		(tx_data_out[i]),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(gclk),
	.D4  			(mdataina[(8*i)+3]),
	.D3  			(mdataina[(8*i)+2]),
	.D2  			(mdataina[(8*i)+1]),
	.D1  			(mdataina[(8*i)+0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TRAIN    		(1'b0),
	.TCE	   		(1'b1),
	.SHIFTIN1 		(1'b1),			// No cascades needed
	.SHIFTIN2 		(1'b1),			// No cascades needed
	.SHIFTIN3 		(1'b1),			// No cascades needed
	.SHIFTIN4 		(1'b1),			// No cascades needed
	.SHIFTOUT1 		(),			// No cascades needed
	.SHIFTOUT2 		(),			// No cascades needed
	.SHIFTOUT3 		(),			// No cascades needed
	.SHIFTOUT4 		()) ;			// No cascades needed
end
end
endgenerate
endmodule
