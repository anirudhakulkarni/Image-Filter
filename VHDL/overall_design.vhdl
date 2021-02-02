library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity overall_design is
    port (
        clock: in std_logic;
        reset: in std_logic;
        switch: in std_logic;
        push_button: in std_logic
  ) ;
end overall_design;
architecture overall_design_arch of overall_design is
    --component instantiation
    component RAM_64Kx8
        port (
            clock : in std_logic;
            read_enable, write_enable : in std_logic; -- signals that enable read/write operation
            address : in std_logic_vector(15 downto 0); -- 2^16 = 64K
            data_in : in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0)
            );
    end component ;
    
    component ROM_32x9
        port (
            clock : in std_logic;
            read_enable : in std_logic; -- signal that enables read operation
            address : in std_logic_vector(4 downto 0); -- 2^5 = 32
            data_out : out std_logic_vector(8 downto 0)
        );
    end component ;

    component MAC
        port (
            clock : in std_logic;
            control : in std_logic; -- '0' for initializing the sum
            data_in1, data_in2 : in std_logic_vector(17 downto 0);
            data_out : out std_logic_vector(17 downto 0)
        );
    end component ;

    component part_d
        port (
            clock : in std_logic;
            reset : in std_logic;
            push_button : in std_logic; -- signals that enable read/write operation
            switch : in std_logic;
            MAC_data_out : in std_logic_vector(17 downto 0);        
            address_RAM : out std_logic_vector(15 downto 0); 
            address_ROM : out std_logic_vector(4 downto 0); 
            read_enable, write_enable : out std_logic; -- signals that enable read/write operation
            control : out std_logic -- '0' for initializing the sum   
        ) ;
    end component ;
    
    signal control: std_logic;
    signal read_enable: std_logic;
    signal write_enable: std_logic;
    signal MAC_data_out: std_logic_vector(17 downto 0);
    signal address_ROM: std_logic_vector(4 downto 0);
    signal address_RAM: std_logic_vector(15 downto 0); 
    signal RAM_data_in: std_logic_vector(7 downto 0); 
       
    signal ROM_data_out: std_logic_vector(8 downto 0);
    signal RAM_data_out: std_logic_vector(7 downto 0);
    signal RAM_data_out_m:std_logic_vector(17 downto 0):="0000000000"&RAM_data_out; --temperary signal created to make output of RAM to 18 bits vector
    signal ROM_data_out_m:std_logic_vector(17 downto 0):="000000000"&ROM_data_out; --temperary signal created to make output of ROM to 18 bits vector
    

begin--port=>new signal
    
    fsmmap: part_d port map(clock=>clock, reset=>reset, push_button=>push_button,switch=>switch, MAC_data_out=>MAC_data_out,address_ROM=>address_ROM,address_RAM=>address_RAM, read_enable=>read_enable,write_enable=>write_enable,control=>control);
    rammap: RAM_64Kx8 port map(clock=>clock, read_enable=>read_enable,write_enable=>write_enable, address=>address_RAM, data_in=> RAM_data_in, data_out=>RAM_data_out );
    macmap: MAC port map(clock=>clock, control=>control, data_in1=>ROM_data_out_m , data_in2=>RAM_data_out_m , data_out=> MAC_data_out);
    rommap: ROM_32x9 port map(clock=>clock, address=>address_ROM ,data_out=> ROM_data_out);

end overall_design_arch ; -- overall_design_arch
