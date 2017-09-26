------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.2
--  \   \        Filename: serdes_1_to_n_clk_pll_s16_diff.vhd
--  /   /        Date Last Modified:  May 5 2010
-- /___/   /\    Date Created: August 1 2008
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	1-bit generic 1:n clock receiver module where n is 10, 12, 14 or 16
-- 		Instantiates necessary clock buffers and PLL
--		Contains state machine to calibrate clock input delay line, and perform bitslip if required.
--		The required search pattern for bitslip to function should be modified around line 142
--		Takes in 1 bit of differential data and deserialises this to n bits for where this data is required
-- 		data is received LSB first
-- 		0, 1, 2 ......
--
--Reference:
--    
--    Rev 1.0 - First created (nicks)
--    Rev 1.1 - Modifications (nicks)
--    		- Rewritten to run a bit faster
--    Rev 1.2 - Modifications (nicks)
--    		- Gearbox phase logic changed to make sure it works under all conditions
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

entity serdes_1_to_n_clk_pll_s16_diff is generic (
	PLLD 			: integer := 1 ;   			-- Parameter to set division for PLL 
	PLLX 			: integer := 2 ;   			-- Parameter to set multiplier for PLL
	CLKIN_PERIOD 		: real := 6.000 ;			-- clock period (ns) of input clock on clkin_p
	S			: integer := 16 ;			-- Parameter to set the serdes factor 1..8
	BS 			: boolean := FALSE ;   			-- Parameter to enable bitslip TRUE or FALSE
	DIFF_TERM		: boolean := TRUE) ;			-- Enable or disable internal differential termination
port 	(
	clkin_p			:  in std_logic ;			-- Input from LVDS receiver pin
	clkin_n			:  in std_logic ;			-- Input from LVDS receiver pin
	rxioclk			: out std_logic ;			-- IO Clock network
	rx_serdesstrobe		: out std_logic ;			-- Parallel data capture strobe
	reset			:  in std_logic ;			-- Reset line
	pattern1		:  in std_logic_vector(S-1 downto 0) ;  -- Data to define pattern that bitslip should search for if enabled, set to '0's if not required
	rx_bufg_pll_x1		: out std_logic ;			-- Global clock
	rx_bufg_pll_x2		: out std_logic ;			-- Global clock x2
	bitslip			: out std_logic ;			-- Bitslip control line
	rx_toggle		: out std_logic ;			-- Control line to data receiver
	datain			: out std_logic_vector(S-1 downto 0) ;  -- Output data
	rx_bufpll_lckd		: out std_logic); 			-- BUFPLL locked
end serdes_1_to_n_clk_pll_s16_diff ;

architecture arch_serdes_1_to_n_clk_pll_s16_diff of serdes_1_to_n_clk_pll_s16_diff is

signal 	P_clk 			: std_logic;       			-- P clock out to BUFIO2
signal 	buf_pll_fb_clk 		: std_logic;  				-- PLL feedback clock into BUFIOFB
signal 	ddly_m 			: std_logic;     			-- Master output from IODELAY1
signal 	ddly_s 			: std_logic;     			-- Slave output from IODELAY1
signal	mdataout 		: std_logic_vector(7 downto 0) ;	--
signal	cascade 		: std_logic ;				--
signal	pd_edge 		: std_logic ;				--
signal	busys 			: std_logic ;				--
signal	busym 			: std_logic ;				--
signal	rx_clk_in		: std_logic ;				--
signal	feedback		: std_logic ;				--
signal	buf_P_clk		: std_logic ;				--
signal	iob_data_in		: std_logic ;				--
signal 	rx_bufg_pll_x1_int 	: std_logic ;
signal 	rx_bufg_pll_x2_int 	: std_logic ;
signal 	rxioclk_int	 	: std_logic ;
signal 	rx_serdesstrobe_int 	: std_logic ;
signal 	rx_pllout_x1	 	: std_logic ;
signal 	rx_pll_lckd		: std_logic ;
signal 	rx_toggle_int		: std_logic ;
signal 	state 			: integer range 0 to 9 ;
signal 	bslip 			: std_logic ;
signal 	bitslip_int 		: std_logic ;
signal 	count  			: std_logic_vector(3 downto 0) ;
signal 	busyd 			: std_logic ;
signal 	counter  		: std_logic_vector(11 downto 0) ;
signal 	clk_iserdes_data  	: std_logic_vector(S-1 downto 0) ;
signal 	clk_iserdes_data_int  	: std_logic_vector(S/2-1 downto 0) ;
signal 	clkh		  	: std_logic_vector(S/2-1 downto 0) ;
signal 	clkhd		  	: std_logic_vector(S/2-1 downto 0) ;
signal 	cal_clk 		: std_logic ;
signal 	rst_clk 		: std_logic ;
signal 	rx_bufplllckd 		: std_logic ;
signal 	not_rx_bufpll_lckd 	: std_logic ;
signal 	busy_clk	 	: std_logic ;
signal 	rx_pllout_xs	 	: std_logic ;
signal 	rx_pllout_x2	 	: std_logic ;
signal 	enable		 	: std_logic ;
signal 	flag1		 	: std_logic ;
signal 	change		 	: std_logic ;

constant RX_SWAP_CLK  		: std_logic := '0' ;			-- pinswap mask for input clock (0 = no swap (default), 1 = swap). Allows input to be connected the wrong way round to ease PCB routing.

begin

rx_bufg_pll_x1 <= rx_bufg_pll_x1_int ;
rx_bufg_pll_x2 <= rx_bufg_pll_x2_int ;
rxioclk <= rxioclk_int ;
rx_serdesstrobe <= rx_serdesstrobe_int ;
rx_toggle <= rx_toggle_int ;
bitslip <= bitslip_int ;

iob_clk_in : IBUFGDS generic map(
	DIFF_TERM		=> DIFF_TERM)
port map (              	
	I    			=> clkin_p,
	IB       		=> clkin_n,
	O         		=> rx_clk_in);

iob_data_in <= rx_clk_in xor RX_SWAP_CLK ;			-- Invert clock as required

busy_clk <= busym ;
datain <= clk_iserdes_data ;

-- Bitslip and CAL state machine

process  (rx_bufg_pll_x1_int, not_rx_bufpll_lckd)
begin
if not_rx_bufpll_lckd = '1' then
	rx_toggle_int <= '0' ;
	change <= '0' ;
elsif rx_bufg_pll_x1_int'event and rx_bufg_pll_x1_int = '1' then
	if rx_toggle_int = '0' then				-- check gearbox is in the right phase
		clk_iserdes_data <= clkh & clkhd ;
	else 
		clk_iserdes_data <= clk_iserdes_data_int & clkh ;
	end if ;
	if clk_iserdes_data(S-1 downto S/2) = pattern1(S/2-1 downto 0) and change = '0' then
		rx_toggle_int <= not rx_toggle_int ;
		change <= '1' ;
	else 
		change <= '0' ;
	end if ;
end if ;
end process ;

process (rx_bufg_pll_x2_int)
begin
if rx_bufg_pll_x2_int'event and rx_bufg_pll_x2_int = '1' then
	clkh <= clk_iserdes_data_int ;
	clkhd <= clkh ;
end if ;
end process ;

process (rx_bufg_pll_x2_int, not_rx_bufpll_lckd)
begin
if not_rx_bufpll_lckd = '1' then
	state <= 0 ;
	enable <= '0' ;
	cal_clk <= '0' ;
	rst_clk <= '0' ;
	bslip <= '0' ;
	bitslip_int <= '0' ;
   	busyd <= '1' ;
	counter <= "000000000000" ;
elsif rx_bufg_pll_x2_int'event and rx_bufg_pll_x2_int = '1' then
   	bitslip_int <= bslip ;
   	busyd <= busy_clk ;
   	if counter(5) = '1' then
		enable <= '1' ;
   	end if ;
   	if counter(11) = '1' then
		state <= 0 ;
		cal_clk <= '0' ;
		rst_clk <= '0' ;
		bslip <= '0' ;
   		busyd <= '1' ;
		counter <= "000000000000" ;
   	else
   		counter <= counter + 1 ;
   		if clk_iserdes_data /= pattern1 then flag1 <= '1' ; else flag1 <= '0' ; end if ;
   		case state is 
   		when 0 	=> 
   			if enable = '1' and busyd = '0' then
   				state <= 1 ;
   			end if ;
   		when 1 => 					-- cal high
   			cal_clk <= '1' ; state <= 2 ;
   		when 2 	=> 
   			if busyd = '1' then			-- wait for busy high
  				state <= 3 ;			-- cal low
  			end if ;
   		when 3	=> 
  			cal_clk <= '0' ;			-- cal low
   			if busyd = '0' then			-- wait for busy low
   				rst_clk <= '1' ; state <= 4 ;	-- rst high
   			end if ;
   		when 4	=>					-- rst low
   			rst_clk <= '0' ; state <= 5 ;
   		when 5	=> 
   			if busyd = '0' then			-- wait for busy low
   				state <= 6 ;
   				count <= "0000" ;
   			end if ;
   		when 6	=>					-- hang around
   			count <= count + 1 ;
   			if count = "1111" then
        			state <= 7 ;
        		end if ;
     		when 7	=>
   			if BS = TRUE and flag1 = '1' then
     		   		bslip <= '1' ;			-- bitslip needed
     		   		state <= 8 ;
     		   		count <= "0000" ;
     		   	end if ;
   		when 8 	=>
     		   	bslip <= '0' ;				-- bitslip low
     		   	count <= count + 1 ;
   			if count = "1111" then
     		   		state <= 7 ;
     		   	end if ;
     		when others => 
     			state <= 0 ;
   		end case ;
   	end if ;
end if ;
end process ;

loop0 : for i in 0 to (S/2 - 1) generate			-- Limit the output data bus to the most significant 'S' number of bits
clk_iserdes_data_int(i) <= mdataout(8+i-S/2) ;
end generate ;

iodelay_m : IODELAY2 generic map(
	DATA_RATE      		=> "SDR", 			-- <SDR>, DDR
	SIM_TAPDELAY_VALUE	=> 50,  			-- nominal tap delay (sim parameter only)
	IDELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY2_VALUE 		=> 0, 				-- {0 ... 255}
	ODELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY_MODE   		=> "NORMAL", 			-- "NORMAL", "PCI"
	SERDES_MODE   		=> "MASTER", 			-- <NONE>, MASTER, SLAVE
	IDELAY_TYPE   		=> "VARIABLE_FROM_HALF_MAX", 	-- "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	COUNTER_WRAPAROUND 	=> "STAY_AT_LIMIT", 		-- <STAY_AT_LIMIT>, WRAPAROUND
	DELAY_SRC     		=> "IDATAIN" )			-- "IO", "IDATAIN", "ODATAIN"
port map (
	IDATAIN  		=> iob_data_in, 		-- data from master IOB
	TOUT     		=> open, 			-- tri-state signal to IOB
	DOUT     		=> open, 			-- output data to IOB
	T        		=> '1', 			-- tri-state control from OLOGIC/OSERDES2
	ODATAIN  		=> '0', 			-- data from OLOGIC/OSERDES2
	DATAOUT  		=> ddly_m, 			-- Output data 1 to ILOGIC/ISERDES2
	DATAOUT2 		=> open, 			-- Output data 2 to ILOGIC/ISERDES2
	IOCLK0   		=> rxioclk_int, 		-- High speed clock for calibration
	IOCLK1   		=> '0', 			-- High speed clock for calibration
	CLK      		=> rx_bufg_pll_x2_int, 		-- Fabric clock (GCLK) for control signals
	CAL      		=> cal_clk, 			-- Calibrate enable signal
	INC      		=> '0', 			-- Increment counter
	CE       		=> '0', 			-- Clock Enable
	RST      		=> rst_clk, 			-- Reset delay line to 1/2 max in this case
	BUSY      		=> busym) ;  			-- output signal indicating sync circuit has finished / calibration has finished


iodelay_s : IODELAY2 generic map(
	DATA_RATE      		=> "SDR", 			-- <SDR>, DDR
	SIM_TAPDELAY_VALUE	=> 50,  			-- nominal tap delay (sim parameter only)
	IDELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY2_VALUE 		=> 0, 				-- {0 ... 255}
	ODELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY_MODE   		=> "NORMAL", 			-- "NORMAL", "PCI"
	SERDES_MODE   		=> "SLAVE", 			-- <NONE>, MASTER, SLAVE
	IDELAY_TYPE 		=> "FIXED", 			-- <DEFAULT>, FIXED, VARIABLE
	COUNTER_WRAPAROUND 	=> "STAY_AT_LIMIT", 		-- <STAY_AT_LIMIT>, WRAPAROUND
	DELAY_SRC     		=> "IDATAIN") 			-- "IO", "IDATAIN", "ODATAIN"
port map (
	IDATAIN 		=> iob_data_in, 		-- data from slave IOB
	TOUT     		=> open, 			-- tri-state signal to IOB
	DOUT     		=> open, 			-- output data to IOB
	T        		=> '1', 			-- tri-state control from OLOGIC/OSERDES2
	ODATAIN  		=> '0', 			-- data from OLOGIC/OSERDES2
	DATAOUT 		=> ddly_s, 			-- Output data 1 to ILOGIC/ISERDES2
	DATAOUT2 		=> open, 			-- Output data 2 to ILOGIC/ISERDES2
	IOCLK0    		=> '0', 			-- High speed clock for calibration
	IOCLK1   		=> '0', 			-- High speed clock for calibration
	CLK      		=> '0', 			-- Fabric clock (GCLK) for control signals
	CAL      		=> '0', 			-- Calibrate control signal, never needed as the slave supplies the clock input to the PLL
	INC      		=> '0', 			-- Increment counter
	CE       		=> '0', 			-- Clock Enable
	RST      		=> '0', 			-- Reset delay line
	BUSY      		=> open) ;			-- output signal indicating sync circuit has finished / calibration has finished

P_clk_bufio2_inst : BUFIO2  generic map(
      DIVIDE			=> 1,               		-- The DIVCLK divider divide-by value; default 1
      DIVIDE_BYPASS		=> TRUE)    			-- DIVCLK output sourced from Divider (FALSE) or from I input, by-passing Divider (TRUE); default TRUE
port map (
      I				=> P_clk,               	-- P_clk input from IDELAY
      IOCLK			=> open,        		-- Output Clock
      DIVCLK			=> buf_P_clk,                	-- Output Divided Clock
      SERDESSTROBE		=> open) ;           		-- Output SERDES strobe (Clock Enable)

P_clk_bufio2fb_inst : BUFIO2FB  generic map(
      DIVIDE_BYPASS		=> TRUE)    			-- DIVCLK output sourced from Divider (FALSE) or from I input, by-passing Divider (TRUE); default TRUE
port map (
      I				=> feedback,             	-- PLL generated Clock
      O				=> buf_pll_fb_clk) ;   		-- PLL Output Feedback Clock

iserdes_m : ISERDES2  generic map(
	DATA_WIDTH     		=> S/2, 			-- SERDES word width.  This should match the setting in BUFPLL
	DATA_RATE      		=> "SDR", 			-- <SDR>, DDR
	BITSLIP_ENABLE 		=> TRUE, 			-- <FALSE>, TRUE
	SERDES_MODE    		=> "MASTER", 			-- <DEFAULT>, MASTER, SLAVE
	INTERFACE_TYPE 		=> "RETIMED") 			-- NETWORKING, NETWORKING_PIPELINED, <RETIMED>
port map (
	D       		=> ddly_m,
	CE0     		=> '1',
	CLK0    		=> rxioclk_int,
	CLK1    		=> '0',
	IOCE    		=> rx_serdesstrobe_int,
	RST     		=> not_rx_bufpll_lckd,
	CLKDIV  		=> rx_bufg_pll_x2_int,
	SHIFTIN 		=> pd_edge,
	BITSLIP 		=> bitslip_int,
	FABRICOUT 		=> open,
	DFB 			=> open,
	CFB0 			=> open,
	CFB1 			=> open,
	Q4 			=> mdataout(7),
	Q3 			=> mdataout(6),
	Q2 			=> mdataout(5),
	Q1 			=> mdataout(4),
	VALID    		=> open,
	INCDEC   		=> open,
	SHIFTOUT 		=> cascade);

iserdes_s : ISERDES2 generic map(
	DATA_WIDTH     		=> S/2, 			-- SERDES word width.  This should match the setting is BUFPLL
	DATA_RATE      		=> "SDR", 			-- <SDR>, DDR
	BITSLIP_ENABLE 		=> TRUE, 			-- <FALSE>, TRUE
	SERDES_MODE    		=> "SLAVE", 			-- <DEFAULT>, MASTER, SLAVE
	INTERFACE_TYPE 		=> "RETIMED") 			-- NETWORKING, NETWORKING_PIPELINED, <RETIMED>
port map (
	D       		=> ddly_s,
	CE0     		=> '1',
	CLK0    		=> rxioclk_int,
	CLK1    		=> '0',
	IOCE    		=> rx_serdesstrobe_int,
	RST     		=> reset,
	CLKDIV  		=> rx_bufg_pll_x2_int,
	SHIFTIN 		=> cascade,
	BITSLIP 		=> bitslip_int,
	FABRICOUT 		=> open,
	DFB 			=> P_clk,
	CFB0 			=> feedback,
	CFB1 			=> open,
	Q4  			=> mdataout(3),
	Q3  			=> mdataout(2),
	Q2  			=> mdataout(1),
	Q1  			=> mdataout(0),
	VALID 			=> open,
	INCDEC 			=> open,
	SHIFTOUT 		=> pd_edge);

rx_pll_adv_inst : PLL_ADV generic map(
      	BANDWIDTH		=> "OPTIMIZED",  		-- "high", "low" or "optimized"
      	CLKFBOUT_MULT		=> PLLX,       			-- multiplication factor for all output clocks
      	CLKFBOUT_PHASE		=> 0.0,     			-- phase shift (degrees) of all output clocks
      	CLKIN1_PERIOD		=> CLKIN_PERIOD,  		-- clock period (ns) of input clock on clkin1
      	CLKIN2_PERIOD		=> CLKIN_PERIOD,  		-- clock period (ns) of input clock on clkin2
      	CLKOUT0_DIVIDE		=> 1,       			-- division factor for clkout0 (1 to 128)
      	CLKOUT0_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout0 (0.01 to 0.99)
      	CLKOUT0_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout0 (0.0 to 360.0)
      	CLKOUT1_DIVIDE		=> S/2,   			-- division factor for clkout1 (1 to 128)
      	CLKOUT1_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout1 (0.01 to 0.99)
      	CLKOUT1_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout1 (0.0 to 360.0)
      	CLKOUT2_DIVIDE		=> S,   			-- division factor for clkout2 (1 to 128)
      	CLKOUT2_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout2 (0.01 to 0.99)
      	CLKOUT2_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout2 (0.0 to 360.0)
      	CLKOUT3_DIVIDE		=> 7,   			-- division factor for clkout3 (1 to 128)
      	CLKOUT3_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout3 (0.01 to 0.99)
      	CLKOUT3_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout3 (0.0 to 360.0)
      	CLKOUT4_DIVIDE		=> 7,   			-- division factor for clkout4 (1 to 128)
      	CLKOUT4_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout4 (0.01 to 0.99)
      	CLKOUT4_PHASE		=> 0.0,      			-- phase shift (degrees) for clkout4 (0.0 to 360.0)
      	CLKOUT5_DIVIDE		=> 7,       			-- division factor for clkout5 (1 to 128)
      	CLKOUT5_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout5 (0.01 to 0.99)
      	CLKOUT5_PHASE		=> 0.0,      			-- phase shift (degrees) for clkout5 (0.0 to 360.0)
  	COMPENSATION		=> "SOURCE_SYNCHRONOUS",	-- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "INTERNAL", "EXTERNAL", "DCM2PLL", "PLL2DCM"
      	DIVCLK_DIVIDE		=> PLLD,        		-- division factor for all clocks (1 to 52)
	CLK_FEEDBACK		=> "CLKOUT0",
      	REF_JITTER		=> 0.100)	   		-- input reference jitter (0.000 to 0.999 ui%)
port map (
      	CLKFBDCM		=> open,              		-- output feedback signal used when pll feeds a dcm
      	CLKFBOUT		=> open,              		-- general output feedback signal
      	CLKOUT0			=> rx_pllout_xs,   		-- x7 clock for transmitter
      	CLKOUT1			=> rx_pllout_x2,              	-- x2 clock for BUFG
      	CLKOUT2			=> rx_pllout_x1,              	-- x1 clock for BUFG
      	CLKOUT3			=> open,
      	CLKOUT4			=> open,              		-- one of six general clock output signals
      	CLKOUT5			=> open,              		-- one of six general clock output signals
      	CLKOUTDCM0		=> open,            		-- one of six clock outputs to connect to the dcm
      	CLKOUTDCM1		=> open,            		-- one of six clock outputs to connect to the dcm
      	CLKOUTDCM2		=> open,            		-- one of six clock outputs to connect to the dcm
      	CLKOUTDCM3		=> open,            		-- one of six clock outputs to connect to the dcm
      	CLKOUTDCM4		=> open,            		-- one of six clock outputs to connect to the dcm
      	CLKOUTDCM5		=> open,            		-- one of six clock outputs to connect to the dcm
      	DO			=> open,                	-- dynamic reconfig data output (16-bits)
      	DRDY			=> open,                	-- dynamic reconfig ready output
      	LOCKED			=> rx_pll_lckd,	        	-- active high pll lock signal
      	CLKFBIN			=> buf_pll_fb_clk,		-- clock feedback input
      	CLKIN1			=> buf_P_clk,     		-- primary clock input
      	CLKIN2			=> '0', 	    		-- secondary clock input
      	CLKINSEL		=> '1',             		-- selects '1' = clkin1, '0' = clkin2
      	DADDR			=> "00000",            		-- dynamic reconfig address input (5-bits)
      	DCLK			=> '0',               		-- dynamic reconfig clock input
      	DEN			=> '0',                		-- dynamic reconfig enable input
      	DI			=> "0000000000000000", 		-- dynamic reconfig data input (16-bits)
      	DWE			=> '0',                		-- dynamic reconfig write enable input
      	RST			=> reset,               	-- asynchronous pll reset
      	REL			=> '0') ;               	-- used to force the state of the PFD outputs (test only)

bufg_pll_x1 : BUFG	port map (I => rx_pllout_x1, O => rx_bufg_pll_x1_int) ;
bufg_pll_x2 : BUFG	port map (I => rx_pllout_x2, O => rx_bufg_pll_x2_int) ;

rx_bufpll_inst : BUFPLL generic map(
      DIVIDE			=> S/2)              		-- PLLIN0 divide-by value to produce rx_serdesstrobe (1 to 8); default 1
port map (
      PLLIN			=> rx_pllout_xs,        	-- PLL Clock input
      GCLK			=> rx_bufg_pll_x2_int, 		-- Global Clock input
      LOCKED			=> rx_pll_lckd,            	-- Clock0 locked input
      IOCLK			=> rxioclk_int, 		-- Output PLL Clock
      LOCK			=> rx_bufplllckd,         	-- BUFPLL Clock and strobe locked
      serdesstrobe		=> rx_serdesstrobe_int) ; 		-- Output SERDES strobe

rx_bufpll_lckd <= rx_pll_lckd and rx_bufplllckd ;
not_rx_bufpll_lckd <= not (rx_pll_lckd and rx_bufplllckd) ;

end arch_serdes_1_to_n_clk_pll_s16_diff ;
