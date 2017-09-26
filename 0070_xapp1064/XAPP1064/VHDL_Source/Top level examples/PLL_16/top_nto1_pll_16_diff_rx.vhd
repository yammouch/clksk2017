------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: top_nto1_pll_16_diff_rx.vhd
--  /   /        Date Last Modified:  May 18 2010
-- /___/   /\    Date Created: May 18 2010
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	Example differential input receiver for clock and data using PLL
--		Serdes factor and number of data lines are set by constants in the code
--		Version for serdes factors of 10, 12, 14 and 16
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created (nicks)
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

entity top_nto1_pll_16_diff_rx is port (
	reset			:  in std_logic ;                     		-- reset (active high)
	clkin_p, clkin_n	:  in std_logic ;                     		-- lvds clock input
	datain_p, datain_n	:  in std_logic_vector(5 downto 0) ;  		-- lvds data inputs
	dummy_out		: out std_logic_vector(95 downto 0)) ;          -- dummy outputs
end top_nto1_pll_16_diff_rx ;

architecture arch_top_nto1_pll_16_diff_rx of top_nto1_pll_16_diff_rx is

component serdes_1_to_n_data_s16_diff generic (
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	D 			: integer := 16 ;				-- Set the number of inputs and outputs
	DIFF_TERM		: boolean := TRUE) ;				-- Enable or disable internal differential termination
port 	(
	use_phase_detector	:  in std_logic ;				-- Set generation of phase detector logic
	datain_p		:  in std_logic_vector(D-1 downto 0) ;		-- Input from LVDS receiver pin
	datain_n		:  in std_logic_vector(D-1 downto 0) ;		-- Input from LVDS receiver pin
	rxioclk			:  in std_logic ;				-- IO Clock network
	rx_serdesstrobe		:  in std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset line
	rx_toggle		:  in std_logic ;				-- control line
	rx_bufg_pll_x1		:  in std_logic ;				-- Global clock
	rx_bufg_pll_x2		:  in std_logic ;				-- Global clock
	bitslip			:  in std_logic ;				-- Bitslip control line
	debug_in  		:  in std_logic_vector(1 downto 0) ;		-- input debug data, set to "00" if not required
	data_out		: out std_logic_vector((D*S)-1 downto 0) ;  	-- Output data
	debug			: out std_logic_vector((3*D)+5 downto 0)) ;  	-- Debug bus, 5D+5 = 3 lines per input (from inc, mux and ce) + 6, leave nc if debug not required
end component ;

component serdes_1_to_n_clk_pll_s16_diff generic (
	PLLD 			: integer := 1 ;   				-- Parameter to set division for PLL 
	CLKIN_PERIOD		: real := 6.700 ;   				-- Set PLL multiplier
	PLLX 			: integer := 2 ;   				-- Set PLL multiplier
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	BS 			: boolean := FALSE ;   				-- Parameter to enable bitslip TRUE or FALSE
	DIFF_TERM		: boolean := TRUE) ;				-- Enable or disable internal differential termination
port 	(
	clkin_p			:  in std_logic ;				-- Input from LVDS receiver pin
	clkin_n			:  in std_logic ;				-- Input from LVDS receiver pin
	rxioclk			: out std_logic ;				-- IO Clock network
	rx_serdesstrobe		: out std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset line
	pattern1		:  in std_logic_vector(S-1 downto 0) ;  	-- Data to define pattern that bitslip should search for if enabled, set to '0's if not required
	rx_bufg_pll_x1		: out std_logic ;				-- Global clock
	rx_bufg_pll_x2		: out std_logic ;				-- Global clock x2
	bitslip			: out std_logic ;				-- Bitslip control line
	rx_toggle		: out std_logic ;				-- Control line to data receiver
	datain			: out std_logic_vector(S-1 downto 0) ;  	-- Output data
	rx_bufpll_lckd		: out std_logic); 				-- BUFPLL locked
end component ;

-- Parameters for serdes factor and number of IO pins

constant S 	: integer := 16 ;						-- Set the serdes factor to be 4
constant D 	: integer := 6 ;						-- Set the number of inputs and outputs to be 6
constant DS 	: integer := (D*S)-1 ;						-- Used for bus widths = serdes factor * number of inputs - 1

signal 	clk_iserdes_data 	: std_logic_vector(S-1 downto 0) ;        
signal 	rx_bufg_x1		: std_logic ;               		
signal 	rx_bufg_x2		: std_logic ;               		
signal 	rxd			: std_logic_vector(DS downto 0)  ;	
signal	capture 		: std_logic_vector(6 downto 0)  ;
signal	counter			: std_logic_vector(3 downto 0)  ;
signal 	bitslip 		: std_logic  ;
signal	rst	 		: std_logic  ;
signal	rx_serdesstrobe		: std_logic  ;
signal	rx_bufpll_clk_xn	: std_logic  ;
signal	rx_bufpll_lckd		: std_logic  ;
signal	not_bufpll_lckd		: std_logic  ;
signal	rx_toggle		: std_logic  ;

begin

rst <= reset ; 							-- active high reset pin

-- Clock Input, Generate ioclocks via PLL

inst_clkin : serdes_1_to_n_clk_pll_s16_diff generic map(
      	CLKIN_PERIOD		=> 16.000,
	PLLD 			=> 1,
      	PLLX			=> S,
      	S			=> S,
	BS 			=> TRUE)    			-- Parameter to enable bitslip TRUE or FALSE (has to be true for video applications)
port map (
	clkin_p    		=> clkin_p,
	clkin_n    		=> clkin_n,
	rxioclk    		=> rx_bufpll_clk_xn,
	pattern1		=> "0000000011111111",			
	rx_serdesstrobe 	=> rx_serdesstrobe,
	rx_bufg_pll_x1 		=> rx_bufg_x1,
	rx_bufg_pll_x2 		=> rx_bufg_x2,
	bitslip   		=> bitslip,
	reset     		=> rst,
	rx_toggle     		=> rx_toggle,
	datain  		=> clk_iserdes_data,
	rx_bufpll_lckd		=> rx_bufpll_lckd) ;

-- Data Inputs

not_bufpll_lckd <= not rx_bufpll_lckd ;

datain : serdes_1_to_n_data_s16_diff generic map(
      	S			=> S,
      	D			=> D)
port map (
	use_phase_detector	=> '1',
	datain_p    		=> datain_p,
	datain_n    		=> datain_n,
	rxioclk    		=> rx_bufpll_clk_xn,
	rx_serdesstrobe 	=> rx_serdesstrobe,
	rx_bufg_pll_x1 		=> rx_bufg_x1,
	rx_bufg_pll_x2 		=> rx_bufg_x2,
	bitslip   		=> bitslip,
	reset   		=> not_bufpll_lckd,
	rx_toggle     		=> rx_toggle,
	debug_in  		=> "00",
	data_out  		=> rxd,
	debug	  		=> open) ;

process (rx_bufg_x1)
begin
if rx_bufg_x1'event and rx_bufg_x1 = '1' then
	dummy_out <= rxd ;
end if ;

end process ;

end arch_top_nto1_pll_16_diff_rx ;