library ieee;
use ieee.std_logic_1164.all;

entity tb_part_d is
end tb_part_d;

architecture tb of tb_part_d is

    component part_d
        port (clock        : in std_logic;
              reset        : in std_logic;
              push_button  : in std_logic;
              switch       : in std_logic;
              MAC_data_out : in std_logic_vector (17 downto 0);
              address_RAM  : out std_logic_vector (15 downto 0);
              address_ROM  : out std_logic_vector (4 downto 0);
              RAM_data_in  : out std_logic_vector (7 downto 0);
              read_enable  : out std_logic;
              write_enable : out std_logic;
              control      : out std_logic);
    end component;

    signal clock        : std_logic;
    signal reset        : std_logic;
    signal push_button  : std_logic;
    signal switch       : std_logic;
    signal MAC_data_out : std_logic_vector (17 downto 0);
    signal address_RAM  : std_logic_vector (15 downto 0);
    signal address_ROM  : std_logic_vector (4 downto 0);
    signal RAM_data_in  : std_logic_vector (7 downto 0);
    signal read_enable  : std_logic;
    signal write_enable : std_logic;
    signal control      : std_logic;

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : part_d
    port map (clock        => clock,
              reset        => reset,
              push_button  => push_button,
              switch       => switch,
              MAC_data_out => MAC_data_out,
              address_RAM  => address_RAM,
              address_ROM  => address_ROM,
              RAM_data_in  => RAM_data_in,
              read_enable  => read_enable,
              write_enable => write_enable,
              control      => control);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        push_button <= '0';
        switch <= '0';
        MAC_data_out <= (others => '0');

        -- Reset generation
        -- EDIT: Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_part_d of tb_part_d is
    for tb
    end for;
end cfg_tb_part_d;