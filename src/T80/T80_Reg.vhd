-- ****
-- T80(b) core. In an effort to merge and maintain bug fixes ....
--
--
-- Ver 300 started tidyup
-- MikeJ March 2005
-- Latest version from www.fpgaarcade.com (original www.opencores.org)
--
-- ****
--
-- T80 Registers, technology independent
--
-- Version : 0244
--
-- Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--
--      0242 : Initial release
--
--      0244 : Changed to single register file
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity T80_Reg is
	port(
		Clk                     : in std_logic;
		CEN                     : in std_logic;
		WEH                     : in std_logic;
		WEL                     : in std_logic;
		AddrA           : in std_logic_vector(2 downto 0);
		AddrB           : in std_logic_vector(2 downto 0);
		AddrC           : in std_logic_vector(2 downto 0);
		DIH                     : in std_logic_vector(7 downto 0);
		DIL                     : in std_logic_vector(7 downto 0);
		DOAH            : out std_logic_vector(7 downto 0);
		DOAL            : out std_logic_vector(7 downto 0);
		DOBH            : out std_logic_vector(7 downto 0);
		DOBL            : out std_logic_vector(7 downto 0);
		DOCH            : out std_logic_vector(7 downto 0);
		DOCL            : out std_logic_vector(7 downto 0);
        RegFileData     : out std_logic_vector(127 downto 0)
        );
end T80_Reg;

architecture rtl of T80_Reg is

	type Register_Image is array (natural range <>) of std_logic_vector(7 downto 0);
	signal      RegsH   : Register_Image(0 to 7);
	signal      RegsL   : Register_Image(0 to 7);

begin

    RegFileData( 7  downto   0) <= RegsL(0);
    RegFileData( 15 downto   8) <= RegsH(0);
    RegFileData( 23 downto  16) <= RegsL(1);
    RegFileData( 31 downto  24) <= RegsH(1);
    RegFileData( 39 downto  32) <= RegsL(2);
    RegFileData( 47 downto  40) <= RegsH(2);
    RegFileData( 55 downto  48) <= RegsL(3);
    RegFileData( 63 downto  56) <= RegsH(3);
    RegFileData( 71 downto  64) <= RegsL(4);
    RegFileData( 79 downto  72) <= RegsH(4);
    RegFileData( 87 downto  80) <= RegsL(5);
    RegFileData( 95 downto  88) <= RegsH(5);
    RegFileData(103 downto  96) <= RegsL(6);
    RegFileData(111 downto 104) <= RegsH(6);
    RegFileData(119 downto 112) <= RegsL(7);
    RegFileData(127 downto 120) <= RegsH(7);
    
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			if CEN = '1' then
				if WEH = '1' then
					RegsH(to_integer(unsigned(AddrA))) <= DIH;
				end if;
				if WEL = '1' then
					RegsL(to_integer(unsigned(AddrA))) <= DIL;
				end if;
			end if;
		end if;
	end process;

	DOAH <= RegsH(to_integer(unsigned(AddrA)));
	DOAL <= RegsL(to_integer(unsigned(AddrA)));
	DOBH <= RegsH(to_integer(unsigned(AddrB)));
	DOBL <= RegsL(to_integer(unsigned(AddrB)));
	DOCH <= RegsH(to_integer(unsigned(AddrC)));
	DOCL <= RegsL(to_integer(unsigned(AddrC)));

end;
