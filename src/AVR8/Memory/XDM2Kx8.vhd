--************************************************************************************************
-- 2Kx8(16 KB) DM RAM for AVR Core(Xilinx)
-- Version 0.2
-- Designed by Ruslan Lepetenok 
-- Jack Gassett for use with Papilio
-- Modified 30.07.2005
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use WORK.SynthCtrlPack.all; -- Synthesis control

-- For Synplicity Synplify
--library virtexe;
--use	virtexe.components.all; 

-- Aldec
library	unisim;
use unisim.vcomponents.all;

entity XDM2Kx8 is port(
	                    cp2       : in  std_logic;
						ce        : in  std_logic; 
	                    address   : in  std_logic_vector(CDATAMEMSIZE downto 0); 
					    din       : in  std_logic_vector(7 downto 0);		                
					    dout      : out std_logic_vector(7 downto 0);
					    we        : in  std_logic
					   );
end XDM2Kx8;

architecture RTL of XDM2Kx8 is

signal RAMBlDOut     : std_logic_vector(dout'range);

signal WEB      : std_logic;
signal cp2n     : std_logic;
signal gnd      : std_logic;

signal DIP : STD_LOGIC_VECTOR(0 downto 0) := "1";

signal SSR : STD_LOGIC := '0'; -- Don't use the output resets.

begin

gnd  <= '0';	

WEB <= '1' when we='1' else '0';


RAM_Byte:component RAMB16_S9 port map(
                                      DO   => RAMBlDOut(7 downto 0),
                                      ADDR => address(10 downto 0),
                                      DI   => din(7 downto 0),
												  DIP  => DIP,
                                      EN   => ce,
									  SSR  => SSR,
                                      CLK  => cp2,
                                      WE   => WEB
                                      );

-- Output data mux
dout <= RAMBlDOut;

end RTL;
