------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: top_nto1_pll_16_diff_tx
--  /   /        Date Last Modified:  May 18 2010
-- /___/   /\    Date Created: May 18 2010
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	Example differential output transmitter for clock and data using PLL
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

entity top_nto1_pll_16_diff_tx is port (
	refclkin_p,  refclkin_n	:  in std_logic ;  				-- reference clock input
	reset			:  in std_logic ;                     		-- reset (active high)
	clkout_p, clkout_n	: out std_logic ;             			-- lvds clock output
	dataout_p, dataout_n	: out std_logic_vector(5 downto 0)) ;  		-- lvds data outputs
		
end top_nto1_pll_16_diff_tx ;

architecture arch_top_nto1_pll_16_diff_tx of top_nto1_pll_16_diff_tx is

component serdes_n_to_1_s16_diff is generic (
	S			: integer := 10 ;				-- Parameter to set the serdes factor 1..8
	D			: integer := 16) ;				-- Set the number of inputs and outputs
port 	(
	txioclk			:  in std_logic ;				-- IO Clock network
	txserdesstrobe		:  in std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset
	tx_bufg_pll_x2		:  in std_logic ;				-- Global clock
	tx_bufg_pll_x1		:  in std_logic ;				-- Global clock
	datain			:  in std_logic_vector((D*S)-1 downto 0) ;  	-- Data for output
	clkin			:  in std_logic_vector(S-1 downto 0) ;  	-- Data for clock
	dataout_p		: out std_logic_vector(D-1 downto 0) ;		-- output
	dataout_n		: out std_logic_vector(D-1 downto 0) ;		-- output
	clkout_p		: out std_logic ;				-- output
	clkout_n		: out std_logic) ;				-- output
end component ;

component clock_generator_pll_s16_diff is generic (
	PLLD			: integer := 1 ;		-- Parameter to set the division factor in the PLL
	PLLX			: integer := 8 ;		-- Parameter to set the multiplication factor in the PLL
	S			: integer := 8 ;		-- Parameter to set the serdes factor 1..8
	CLKIN_PERIOD		: real := 6.000 ;		-- clock period (ns) of input clock on clkin_p
	DIFF_TERM		: boolean := TRUE) ;		-- Enable or disable internal differential termination
port 	(
	reset			:  in std_logic ;              	-- reset (active high)
	clkin_p, clkin_n	:  in std_logic ;              	-- differential clock input
	ioclk			: out std_logic ;             	-- ioclock from BUFPLL
	serdesstrobe		: out std_logic ;             	-- serdes strobe from BUFPLL
	gclk1			: out std_logic ;             	-- global clock output from BUFG x1
	gclk2			: out std_logic ;             	-- global clock output from BUFG x2
	bufpll_lckd		: out std_logic) ; 		-- Locked output from BUFPLL
end component ;

-- Parameters for serdes factor and number of IO pins

constant S 	: integer := 16 ;					-- Set the serdes factor to be 7
constant D 	: integer := 6 ;					-- Set the number of inputs and outputs to be 6
constant DS 	: integer := (D*S)-1 ;					-- Used for bus widths = serdes factor * number of inputs - 1

signal 	tx_bufpll_lckd		: std_logic  ;				
signal 	txd			: std_logic_vector(DS downto 0)  ;	
signal 	tx_bufg_x1 		: std_logic  ;
signal 	tx_bufg_x2 		: std_logic  ;
signal	rst	 		: std_logic  ;
signal	tx_bufpll_clk_xn	: std_logic  ;
signal	tx_serdesstrobe		: std_logic  ;

-- Parameters for clock generation

constant TX_CLK_GEN : std_logic_vector(S-1 downto 0) := "0000000011111111" ;	-- Transmit a constant to make a clock

begin

rst <= reset ; 								-- active high reset pin

-- Frequency Generator Clock Input

clkgen : clock_generator_pll_s16_diff generic map(
	S 			=> S,
	PLLX			=> S,
	PLLD			=> 1,
	CLKIN_PERIOD 		=> 16.000)
port map (                        
	reset			=> rst,
	clkin_p			=> refclkin_p,
	clkin_n			=> refclkin_n,
	ioclk			=> tx_bufpll_clk_xn,
	serdesstrobe		=> tx_serdesstrobe,
	gclk1			=> tx_bufg_x1,
	gclk2			=> tx_bufg_x2,
	bufpll_lckd		=> tx_bufpll_lckd) ;
	
process (tx_bufg_x1, rst)			-- Generate some data to transmit
begin
if rst = '1' then
	txd <= (0 => '1', others => '0') ;
elsif tx_bufg_x1'event and tx_bufg_x1 = '1' then
	txd <= txd(95 downto 94) + 1 & txd(92 downto 0) & txd(93) ;
end if ;
end process ;

-- Transmitter Logic - Instantiate serialiser to generate forwarded clock and output data lines

clkout : serdes_n_to_1_s16_diff generic map (
      	S			=> S,
      	D			=> D)
port map (
	dataout_p   		=> dataout_p,
	dataout_n   		=> dataout_n,
	clkout_p   		=> clkout_p,
	clkout_n   		=> clkout_n,
	txioclk    		=> tx_bufpll_clk_xn,
	txserdesstrobe 		=> tx_serdesstrobe,
	tx_bufg_pll_x1 		=> tx_bufg_x1,
	tx_bufg_pll_x2 		=> tx_bufg_x2,
	reset     		=> rst,
	datain  		=> txd,
	clkin	  		=> TX_CLK_GEN);			-- Transmit a constant to make the clock

end arch_top_nto1_pll_16_diff_tx ;