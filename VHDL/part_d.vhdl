--Assignment 3 submission by Anirudha Kulkarni 2019CS50421 for COL215 
--General abbreviation
--Ld : Load - loads predecided value
--I : Increment by 1
--I3 : Increment by 3
--p : pth pixel in the matrix
--c : cth coefficient in the matrix
--r : reminder of p by 160 or current column of p pixel
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity part_d is
    port (
        clock : in std_logic;
        reset : in std_logic;
        push_button : in std_logic; -- signals that enable read/write operation
        switch : in std_logic;
        MAC_data_out : in std_logic_vector(17 downto 0);        
        address_RAM : out std_logic_vector(15 downto 0); 
        address_ROM : out std_logic_vector(4 downto 0); 
        RAM_data_in: out std_logic_vector(7 downto 0);
        read_enable, write_enable : out std_logic; -- signals that enable read/write operation
        control : out std_logic -- '0' for initializing the sum
        
      ) ;
end part_d;
architecture part_d_arch of part_d is
    type State_type is ( idle, active, proc_p, proc_c, slc_s, increment ) ;
    signal y : State_type ;
    signal LdP, LdR, LdC,ShS,IniS,IP1,IP3,IR,IC: std_logic;
    signal RAM_A: std_logic_vector(1 downto 0);
    --all counters are mainted as integers and converted to appropriate dimensions vector while giving outputs
    signal reminder, p, c: integer;
begin
    --FSM transition process. Changes states as per conditions
    FSM_Transition : process( clock )
    begin
        if reset='0' then--initialize input to be given when system switched on for the first time
            y<=active;
        elsif rising_edge(clock) then
            case y  is
                when idle =>
                    if push_button = '0' then y <= active; else y<=idle ; end if; 
                when active =>
                    if push_button = '0' then y <= active; else y<=proc_p ; end if;
                when proc_p =>
                    if p<19039 then y<=proc_c; else y<=idle; end if;--119*160-1 for the last valid pixel in the image
                when proc_c =>--proc_c
                    if c>9 then y<=slc_s; else y<=proc_c; end if;--end of all coefficients sum of products
                when slc_s =>--to accomodate delay in reading and multiplication
                    y<=increment;
                when others=>--to accomodate delay to increment counters and write
                    y<=proc_p;
            end case ;
        end if ;        
    end process ; -- FSM_Transition

    --process to generate output corresponding to each state
    FSM_output : process( y )
    begin
        LdP<='0'; LdR<='0'; LdC<='0'; control<='0';ShS<='0';IniS<='0';read_enable<='0';write_enable<='0';
        case y  is
            when idle=>
                --no output needed
            when active =>
                if push_button = '1' then LdR<='1';LdP<='1'; end if;
            when proc_p =>
                if p<19039 then LdC<='1';  end if;--119*160-1 for the last valid pixel in the image
            when proc_c =>--process cth coefficient
                read_enable<='1';
                control<='1';
                IC<='1';
                if c<3 then--for top row of 3x3 matrix p-160+c-1th pixels
                    RAM_A<="00";
                    if c=0 then
                        control<='0';--control is kept 0 only for c=0 so as to initialise the sum
                    end if ;
                elsif c<6 then-- similarly p+i-4 for middle row 
                    RAM_A<="01";
                else--for lowest row p+160+i-7th
                    RAM_A<="10";
                end if; 
            when slc_s=>
                write_enable<='1';
                if to_integer(signed(MAC_data_out)) >0 then
                    ShS<='1';--corresponding to shift the sum by 7 bits and then write
                else
                    IniS<='1';-- assign 0 to sum and then write
                end if ; 
            when increment=>
                if reminder=158 then--corner case of second last column. reloaod r and increment p by 3 to make it to 2nd column
                    IP3<='1';
                    LdR<='1';
                else--normal case increment both r and p by 1
                    IP1<='1';
                    IR<='1';
                end if ;
        end case ;
    end process ; -- FSM_output


    --datapath for part_d entity
    datapath : process( clock )
    begin
        if rising_edge(clock) then
            if LdR='1' then
                reminder<=0;
            elsif IR='1' then
                reminder<=reminder+1;
            end if ;
            if LdC='1' then
                c<=0;
            elsif IC='1' then
                c<=c+1;
            end if ;
            if LdP='1' then
                p<=161;
            elsif IP1='1' then
                p<=p+1;
            elsif IP3='1' then
                p<=p+3;
            end if ;
            if RAM_A="00" then
                address_RAM<=std_logic_vector(to_unsigned(p-161+c,18));--top row. converted from integer to 18 bit vector for address of RAM
            elsif RAM_A="01" then
                address_RAM<=std_logic_vector(to_unsigned(p+c-4,18));--middle row.
            elsif RAM_A="10" then
                address_RAM<=std_logic_vector(to_unsigned(p+153+c,18));--last row.
            end if ;

            if IniS='1' then--corresponds to negative sum of products. assign 0
                RAM_data_in<="00000000";
            elsif ShS='1' then
                RAM_data_in<=MAC_data_out(14 downto 7);--shift by 7 bits. discarding initial 2 bits also as the result wont exceed 9 bits. As its positive values discard bit representing sign too
            end if ;
            if switch='1' then--decides which operation is to be done. smoothing or sharpening
                address_ROM<=std_logic_vector(to_unsigned(c+16,5));--converting to 5 bits vector
            else
                address_ROM<=std_logic_vector(to_unsigned(c,5));
            end if ;
        end if ;
    end process ; -- datapath
end part_d_arch ; -- part_d_arch