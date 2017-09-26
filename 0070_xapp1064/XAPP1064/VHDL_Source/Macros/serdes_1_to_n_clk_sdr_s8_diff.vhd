------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.1
--  \   \        Filename: serdes_1_to_n_clk_sdr_s8_diff.vhd
--  /   /        Date Last Modified:  February 5 2010
-- /___/   /\    Date Created: August 1 2008
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	1-bit generic 1:n DDR clock receiver module for serdes factors from 2 to 8 with differential inputs
-- 		Instantiates IOB and necessary BUFIO2 clock buffer and BUFG global clock buffer
--
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created (nicks)
--    Rev 1.1 - Modifications (nicks)
--		- Input delay removed
-- 		- Unused reset input removed
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

entity serdes_1_to_n_clk_sdr_s8_diff is generic (
	S			: integer := 8 ;	-- Parameter to set the serdes factor 1..8
	DIFF_TERM		: boolean := TRUE) ;	-- Enable or disable internal differential termination
port 	(
	clkin_p			:  in std_logic ;	-- Input from LVDS receiver pin
	clkin_n			:  in std_logic ;	-- Input from LVDS receiver pin
	rxioclk			: out std_logic ;	-- IO Clock network
	rx_serdesstrobe		: out std_logic ;	-- Parallel data capture strobe
	rx_bufg_x1		: out std_logic) ;	-- Global clock
end serdes_1_to_n_clk_sdr_s8_diff ;

architecture arch_serdes_1_to_n_clk_sdr_s8_diff of serdes_1_to_n_clk_sdr_s8_diff is

signal	iob_data_in 		: std_logic;		--
signal	rx_clk_in 		: std_logic;		--
signal	rx_bufio2_x1 		: std_logic;		--

constant RX_SWAP_CLK  		: std_logic := '0' ;		-- pinswap mask for input clock (0 = no swap (default), 1 = swap). Allows input to be connected the wrong way round to ease PCB routing.

begin

iob_clk_in : IBUFGDS generic map(
	DIFF_TERM		=> DIFF_TERM)
port map (
	I    			=> clkin_p,
	IB       		=> clkin_n,
	O         		=> rx_clk_in) ;

iob_data_in <= rx_clk_in xor RX_SWAP_CLK ;			-- Invert clock as required

bufg_pll_x1 : BUFG port map	(I => rx_bufio2_x1, O => rx_bufg_x1) ;

bufio2_2clk_inst : BUFIO2 generic map(
      DIVIDE			=> S, 
      DIVIDE_BYPASS		=> FALSE)               	-- The DIVCLK divider divide-by value; default 1
port map (
      I				=> iob_data_in,  		-- Input source clock 0 degrees
      IOCLK			=> rxioclk,        		-- Output Clock for IO
      DIVCLK			=> rx_bufio2_x1,                -- Output Divided Clock
      SERDESSTROBE		=> rx_serdesstrobe) ;           -- Output SERDES strobe (Clock Enable)

end arch_serdes_1_to_n_clk_sdr_s8_diff ;
