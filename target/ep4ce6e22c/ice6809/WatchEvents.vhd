LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY WatchEvents IS
	PORT
	(
		clk		: IN STD_LOGIC ;
		din		: IN STD_LOGIC_VECTOR (71 DOWNTO 0);
		rd_en		: IN STD_LOGIC ;
		wr_en		: IN STD_LOGIC ;
		srst		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		dout		: OUT STD_LOGIC_VECTOR (71 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END WatchEvents;


ARCHITECTURE SYN OF watchevents IS

	SIGNAL sub_wire0	: STD_LOGIC ;
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC_VECTOR (71 DOWNTO 0);
	SIGNAL sub_wire3	: STD_LOGIC_VECTOR (8 DOWNTO 0);

	COMPONENT scfifo
	GENERIC (
		add_ram_output_register		: STRING;
		intended_device_family		: STRING;
		lpm_numwords		: NATURAL;
		lpm_showahead		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL;
		lpm_widthu		: NATURAL;
		overflow_checking		: STRING;
		underflow_checking		: STRING;
		use_eab		: STRING
	);
	PORT (
			clock	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (71 DOWNTO 0);
			rdreq	: IN STD_LOGIC ;
			wrreq	: IN STD_LOGIC ;
			empty	: OUT STD_LOGIC ;
			full	: OUT STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (71 DOWNTO 0);
			usedw	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
	END COMPONENT;

BEGIN

	scfifo_component : scfifo
	GENERIC MAP (
		add_ram_output_register => "OFF",
		intended_device_family => "Cyclone IV E",
		lpm_numwords => 512,
		lpm_showahead => "OFF",
		lpm_type => "scfifo",
		lpm_width => 72,
		lpm_widthu => 9,
		overflow_checking => "ON",
		underflow_checking => "ON",
		use_eab => "ON"
	)
	PORT MAP (
		clock => clk,
		data => din,
		rdreq => rd_en,
		wrreq => wr_en,
		empty => empty,
		full => full,
		q => dout,
      usedw => open
	);

END SYN;
