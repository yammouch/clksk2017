------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.1
--  \   \        Filename: serdes_1_to_n_data_ddr_s8_se.vhd
--  /   /        Date Last Modified:  February 5 2010
-- /___/   /\    Date Created: August 1 2008
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	D-bit generic 1:n data receiver module with differential inputs for DDR systems
-- 		Takes in 1 bit of differential data and deserialises this to n bits
-- 		data is received LSB first
--		Serial input words
--		Line0     : 0,   ...... DS-(S+1)
-- 		Line1 	  : 1,   ...... DS-(S+2)
-- 		Line(D-1) : .           .
-- 		Line(D)  : D-1, ...... DS
-- 		Parallel output word
--		DS, DS-1 ..... 1, 0
--
--		Includes state machine to control CAL and the phase detector if required
--		Note for serdes factors of 4 and less, only one input delay and serdes is needed, this
--		makes use of the phase detector impossible unless USE_PD is set TRUE.
--		Data inversion can be accomplished via the RX_SWAP_MASK parameter if required
--
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created (nicks)
--    Rev 1.1 - Modified (nicks)
--		- phase detector state machine moved down in the hierarchy to line up with the version in coregen, will need adding to ISE project
--
------------------------------------------------------------------------------
--
--  Disclaimer: 
--
--		This disclaimer is not a license and does not grant any rights to the materials 
--              distributed herewith. Except as otherwise provided in a valid license issued to you 
--              by Xilinx, and to the maximum extent permitted by applicable law: 
--              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
--              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
--              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
--              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
--              or tort, including negligence, or under any other theory of liability) for any loss or damage 
--              of any kind or nature related to, arising under or in connection with these materials, 
--              including for any direct, or any indirect, special, incidental, or consequential loss 
--              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
--              as a result of any action brought by a third party) even if such damage or loss was 
--              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
--  Critical Applications:
--
--		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
--		requiring fail-safe performance, such as life-support or safety devices or systems, 
--		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
--		or any other applications that could lead to death, personal injury, or severe property or 
--		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
--		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
--		to applicable laws and regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

library unisim ;
use unisim.vcomponents.all ;

entity serdes_1_to_n_data_ddr_s8_se is generic (
	USE_PD			: boolean := FALSE ;				-- Parameter to set generation of phase detector logic
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	D 			: integer := 16) ;				-- Set the number of inputs and outputs
port 	(
	use_phase_detector	:  in std_logic ;				-- '1' enables the phase detector logic if USE_PD = TRUE
	datain			:  in std_logic_vector(D-1 downto 0) ;		-- Input from se receiver pin
	rxioclkp		:  in std_logic ;				-- IO Clock network
	rxioclkn		:  in std_logic ;				-- IO Clock network
	rxserdesstrobe		:  in std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset line
	gclk			:  in std_logic ;				-- Global clock
	bitslip			:  in std_logic ;				-- Bitslip control line
	data_out		: out std_logic_vector((D*S)-1 downto 0) ;  	-- Output data
	debug_in		:  in std_logic_vector(1 downto 0) ;  		-- Debug Inputs, set to '0' if not required
	debug			: out std_logic_vector((3*D)+5 downto 0)) ;  	-- Debug bus, 3D+5 = 3 lines per input (from inc, mux and ce) + 6, leave nc if debug not required
end serdes_1_to_n_data_ddr_s8_se ;

architecture arch_serdes_1_to_n_data_ddr_s8_se of serdes_1_to_n_data_ddr_s8_se is

component phase_detector generic (
	D 			: integer := 16) ;				-- Set the number of inputs
port (
	use_phase_detector	:  in std_logic ;				-- Set generation of phase detector logic
	busy			:  in std_logic_vector(D-1 downto 0) ;		-- BUSY inputs from IODELAY2s
	valid			:  in std_logic_vector(D-1 downto 0) ;		-- VALID inputs from IODELAY2s
	inc_dec			:  in std_logic_vector(D-1 downto 0) ;		-- INC_DEC inputs from ISERDES2s
	reset			:  in std_logic ;				-- Reset line
	gclk			:  in std_logic ;				-- Global clock
	debug_in  		:  in std_logic_vector(1 downto 0) ;		-- input debug data
	cal_master		: out std_logic ;				-- Output to cal pins on master IODELAY2s
	cal_slave		: out std_logic ;				-- Output to cal pins on slave IODELAY2s
	rst_out			: out std_logic ;				-- Output to rst pins on master & slave IODELAY2s
	ce			: out std_logic_vector(D-1 downto 0) ;  	-- Outputs to ce pins on IODELAY2s
	inc			: out std_logic_vector(D-1 downto 0) ;  	-- Outputs to inc pins on IODELAY2s
	debug			: out std_logic_vector((3*D)+5 downto 0)) ;  	-- Debug bus, 3D+5 = 3 lines per input (from inc, mux and ce) + 6, leave nc if debug not required
end component ;

signal 	ddly_m			: std_logic_vector(D-1 downto 0) ;     			-- Master output from IODELAY1
signal 	ddly_s			: std_logic_vector(D-1 downto 0) ;     			-- Slave output from IODELAY1
signal	cascade 		: std_logic_vector(D-1 downto 0) ;
signal	rx_data_in 		: std_logic_vector(D-1 downto 0) ;
signal	rx_data_in_fix 		: std_logic_vector(D-1 downto 0) ;
signal	busy_data		: std_logic_vector(D-1 downto 0) ;
signal	pd_edge			: std_logic_vector(D-1 downto 0) ;
signal	cal_data_slave		: std_logic ;
signal	cal_data_master		: std_logic ;
signal	valid_data		: std_logic_vector(D-1 downto 0) ;
signal	rst_data		: std_logic ;
signal	mdataout 		: std_logic_vector((8*D)-1 downto 0) ;
signal	inc_data		: std_logic_vector(D-1 downto 0) ;
signal	ce_data			: std_logic_vector(D-1 downto 0) ;
signal	incdec_data		: std_logic_vector(D-1 downto 0) ;
	
constant RX_SWAP_MASK 		: std_logic_vector(D-1 downto 0) := (others => '0') ;	-- pinswap mask for input bits (0 = no swap (default), 1 = swap). Allows inputs to be connected the wrong way round to ease PCB routing.

begin

pd_state_machine : phase_detector generic map (
	D		      	=> D) 				-- Set the number of inputs
port map (
	use_phase_detector 	=> use_phase_detector,
	busy			=> busy_data,
	valid 			=> valid_data,	
	inc_dec 		=> incdec_data,	
	reset 			=> reset,	
	gclk 			=> gclk,		
	debug_in		=> debug_in,		
	cal_master		=> cal_data_master,
	cal_slave 		=> cal_data_slave,	
	rst_out 		=> rst_data,
	ce 			=> ce_data,
	inc			=> inc_data,
	debug			=> debug) ;

loop0 : for i in 0 to (D - 1) generate

rx_data_in_fix(i) <= rx_data_in(i) xor RX_SWAP_MASK(i) ;			-- Invert signals as required

iob_clk_in : IBUF port map (
	I    			=> datain(i),
	O         		=> rx_data_in(i));

loop2 : if (USE_PD = TRUE or S > 4) generate 	--Two oserdes are needed

iodelay_m : IODELAY2 generic map(
	DATA_RATE      		=> "DDR", 		-- <SDR>, DDR
	IDELAY_VALUE  		=> 0, 			-- {0 ... 255}
	IDELAY2_VALUE 		=> 0, 			-- {0 ... 255}
	IDELAY_MODE  		=> "NORMAL" , 		-- NORMAL, PCI
	ODELAY_VALUE  		=> 0, 			-- {0 ... 255}
	IDELAY_TYPE   		=> "DIFF_PHASE_DETECTOR",-- "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	COUNTER_WRAPAROUND 	=> "WRAPAROUND", 	-- <STAY_AT_LIMIT>, WRAPAROUND
	DELAY_SRC     		=> "IDATAIN", 		-- "IO", "IDATAIN", "ODATAIN"
	SERDES_MODE   		=> "MASTER", 		-- <NONE>, MASTER, SLAVE
	SIM_TAPDELAY_VALUE   	=> 49) 			--
port map (
	IDATAIN  		=> rx_data_in_fix(i), 	-- data from primary IOB
	TOUT     		=> open, 		-- tri-state signal to IOB
	DOUT     		=> open, 		-- output data to IOB
	T        		=> '1', 		-- tri-state control from OLOGIC/OSERDES2
	ODATAIN  		=> '0', 		-- data from OLOGIC/OSERDES2
	DATAOUT  		=> ddly_m(i), 		-- Output data 1 to ILOGIC/ISERDES2
	DATAOUT2 		=> open, 		-- Output data 2 to ILOGIC/ISERDES2
	IOCLK0   		=> rxioclkp, 		-- High speed clock for calibration
	IOCLK1   		=> rxioclkn, 		-- High speed clock for calibration
	CLK      		=> gclk, 		-- Fabric clock (GCLK) for control signals
	CAL      		=> cal_data_master,	-- Calibrate control signal
	INC      		=> inc_data(i),		-- Increment counter
	CE       		=> ce_data(i),		-- Clock Enable
	RST      		=> rst_data,		-- Reset delay line
	BUSY      		=> open) ; 		-- output signal indicating sync circuit has finished / calibration has finished

iodelay_s : IODELAY2 generic map(
	DATA_RATE      		=> "DDR", 		-- <SDR>, DDR
	IDELAY_VALUE  		=> 0, 			-- {0 ... 255}
	IDELAY2_VALUE 		=> 0, 			-- {0 ... 255}
	IDELAY_MODE  		=> "NORMAL" , 		-- NORMAL, PCI
	ODELAY_VALUE  		=> 0, 			-- {0 ... 255}
	IDELAY_TYPE   		=> "DIFF_PHASE_DETECTOR",-- "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	COUNTER_WRAPAROUND 	=> "WRAPAROUND", 	-- <STAY_AT_LIMIT>, WRAPAROUND
	DELAY_SRC     		=> "IDATAIN", 		-- "IO", "IDATAIN", "ODATAIN"
	SERDES_MODE   		=> "SLAVE", 		-- <NONE>, MASTER, SLAVE
	SIM_TAPDELAY_VALUE   	=> 49) 			--
port map (
	IDATAIN  		=> rx_data_in_fix(i), 	-- data from primary IOB
	TOUT     		=> open, 		-- tri-state signal to IOB
	DOUT     		=> open, 		-- output data to IOB
	T        		=> '1', 		-- tri-state control from OLOGIC/OSERDES2
	ODATAIN  		=> '0', 		-- data from OLOGIC/OSERDES2
	DATAOUT  		=> ddly_s(i), 		-- Output data 1 to ILOGIC/ISERDES2
	DATAOUT2 		=> open, 		-- Output data 2 to ILOGIC/ISERDES2
	IOCLK0   		=> rxioclkp, 		-- High speed clock for calibration
	IOCLK1   		=> rxioclkn, 		-- High speed clock for calibration
	CLK      		=> gclk, 		-- Fabric clock (GCLK) for control signals
	CAL      		=> cal_data_slave,	-- Calibrate control signal
	INC      		=> inc_data(i),		-- Increment counter
	CE       		=> ce_data(i),		-- Clock Enable
	RST      		=> rst_data,		-- Reset delay line
	BUSY      		=> busy_data(i)) ; 	-- output signal indicating sync circuit has finished / calibration has finished
		
iserdes_m : ISERDES2 generic map (
	DATA_WIDTH     		=> S, 			-- SERDES word width.  This should match the setting is BUFPLL
	DATA_RATE      		=> "DDR", 		-- <SDR>, DDR
	BITSLIP_ENABLE 		=> TRUE, 		-- <FALSE>, TRUE
	SERDES_MODE    		=> "MASTER", 		-- <DEFAULT>, MASTER, SLAVE
	INTERFACE_TYPE 		=> "RETIMED") 		-- NETWORKING, NETWORKING_PIPELINED, <RETIMED>
port map (
	D       		=> ddly_m(i),
	CE0     		=> '1',
	CLK0    		=> rxioclkp,
	CLK1    		=> rxioclkn,
	IOCE    		=> rxserdesstrobe,
	RST     		=> reset,
	CLKDIV  		=> gclk,
	SHIFTIN 		=> pd_edge(i),
	BITSLIP 		=> bitslip,
	FABRICOUT 		=> open,
	Q4  			=> mdataout((8*i)+7),
	Q3  			=> mdataout((8*i)+6),
	Q2  			=> mdataout((8*i)+5),
	Q1  			=> mdataout((8*i)+4),
	DFB  			=> open,			-- are these the same as above? These were in Johns design
	CFB0 			=> open,
	CFB1 			=> open,
	VALID    		=> open,
	INCDEC   		=> open,
	SHIFTOUT 		=> cascade(i));

iserdes_s : ISERDES2 generic map(
	DATA_WIDTH     		=> S, 			-- SERDES word width.  This should match the setting is BUFPLL
	DATA_RATE      		=> "DDR", 		-- <SDR>, DDR
	BITSLIP_ENABLE 		=> TRUE, 		-- <FALSE>, TRUE
	SERDES_MODE    		=> "SLAVE", 		-- <DEFAULT>, MASTER, SLAVE
	INTERFACE_TYPE 		=> "RETIMED") 		-- NETWORKING, NETWORKING_PIPELINED, <RETIMED>
port map (
	D       		=> ddly_s(i),
	CE0     		=> '1',
	CLK0    		=> rxioclkp,
	CLK1    		=> rxioclkn,
	IOCE    		=> rxserdesstrobe,
	RST     		=> reset,
	CLKDIV  		=> gclk,
	SHIFTIN 		=> cascade(i),
	BITSLIP 		=> bitslip,
	FABRICOUT 		=> open,
	Q4  			=> mdataout((8*i)+3),
	Q3  			=> mdataout((8*i)+2),
	Q2  			=> mdataout((8*i)+1),
	Q1  			=> mdataout((8*i)+0),
	DFB  			=> open,			-- are these the same as above? These were in Johns design
	CFB0 			=> open,
	CFB1 			=> open,
	VALID 			=> open,
	INCDEC 			=> open,
	SHIFTOUT 		=> pd_edge(i));

end generate ;

loop3 : if (USE_PD /= TRUE and S < 5) generate  	-- Only one oserdes is needed, CAL will occur once only at reset

iodelay_m : IODELAY2 generic map(
	DATA_RATE      		=> "DDR", 		-- <SDR>, DDR
	IDELAY_VALUE  		=> 0, 			-- {0 ... 255}
	IDELAY2_VALUE 		=> 0, 			-- {0 ... 255}
	IDELAY_MODE  		=> "NORMAL" , 		-- NORMAL, PCI
	ODELAY_VALUE  		=> 0, 			-- {0 ... 255}
	IDELAY_TYPE   		=> "VARIABLE_FROM_HALF_MAX",-- "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	COUNTER_WRAPAROUND 	=> "WRAPAROUND", 	-- <STAY_AT_LIMIT>, WRAPAROUND
	DELAY_SRC     		=> "IDATAIN", 		-- "IO", "IDATAIN", "ODATAIN"
	SERDES_MODE   		=> "NONE", 		-- <NONE>, MASTER, SLAVE
	SIM_TAPDELAY_VALUE   	=> 49) 			--
port map (
	IDATAIN  		=> rx_data_in_fix(i), 	-- data from primary IOB
	TOUT     		=> open, 		-- tri-state signal to IOB
	DOUT     		=> open, 		-- output data to IOB
	T        		=> '1', 		-- tri-state control from OLOGIC/OSERDES2
	ODATAIN  		=> '0', 		-- data from OLOGIC/OSERDES2
	DATAOUT  		=> ddly_m(i), 		-- Output data 1 to ILOGIC/ISERDES2
	DATAOUT2 		=> open, 		-- Output data 2 to ILOGIC/ISERDES2
	IOCLK0   		=> rxioclkp, 		-- High speed clock for calibration
	IOCLK1   		=> rxioclkn, 		-- High speed clock for calibration
	CLK      		=> gclk, 		-- Fabric clock (GCLK) for control signals
	CAL      		=> cal_data_master,	-- Calibrate control signal
	INC      		=> '0',			-- Increment counter
	CE       		=> '0',			-- Clock Enable
	RST      		=> rst_data,		-- Reset delay line
	BUSY      		=> busy_data(i)) ; 	-- output signal indicating sync circuit has finished / calibration has finished

iserdes_m : ISERDES2 generic map (
	DATA_WIDTH     		=> S, 			-- SERDES word width.  This should match the setting is BUFPLL
	DATA_RATE      		=> "DDR", 		-- <SDR>, DDR
	BITSLIP_ENABLE 		=> TRUE, 		-- <FALSE>, TRUE
	SERDES_MODE    		=> "NONE", 		-- <NONE>, MASTER, SLAVE
	INTERFACE_TYPE 		=> "RETIMED") 		-- NETWORKING, NETWORKING_PIPELINED, <RETIMED>
port map (
	D       		=> ddly_m(i),
	CE0     		=> '1',
	CLK0    		=> rxioclkp,
	CLK1    		=> rxioclkn,
	IOCE    		=> rxserdesstrobe,
	RST     		=> reset,
	CLKDIV  		=> gclk,
	SHIFTIN 		=> '0',
	BITSLIP 		=> bitslip,
	FABRICOUT 		=> open,
	Q4  			=> mdataout((8*i)+7),
	Q3  			=> mdataout((8*i)+6),
	Q2  			=> mdataout((8*i)+5),
	Q1  			=> mdataout((8*i)+4),
	DFB  			=> open,			
	CFB0 			=> open,
	CFB1 			=> open,
	VALID    		=> open,
	INCDEC   		=> open,
	SHIFTOUT 		=> open);

end generate ;
	
loop1 : for j in 7 downto (8-S) generate
data_out(((D*(j+S-8))+i)) <= mdataout((8*i)+j) ;
end generate ;
end generate ;

end arch_serdes_1_to_n_data_ddr_s8_se ;
