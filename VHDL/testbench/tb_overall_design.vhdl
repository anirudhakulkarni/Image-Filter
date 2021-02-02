library ieee;
use ieee.std_logic_1164.all;

entity tb_overall_design is
end tb_overall_design;

architecture tb of tb_overall_design is

    component overall_design
        port (clock       : in std_logic;
              reset       : in std_logic;
              switch      : in std_logic;
              push_button : in std_logic;
              done        : out std_logic);
    end component;

    signal clock       : std_logic;
    signal reset       : std_logic;
    signal switch      : std_logic;
    signal push_button : std_logic;
    signal done        : std_logic;

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : overall_design
    port map (clock       => clock,
              reset       => reset,
              switch      => switch,
              push_button => push_button,
              done        => done);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        switch <= '0';
        push_button <= '0';

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

configuration cfg_tb_overall_design of tb_overall_design is
    for tb
    end for;
end cfg_tb_overall_design;