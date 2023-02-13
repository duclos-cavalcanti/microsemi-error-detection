library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Debouncer is
    generic (
        counter_size : integer := 25
    );
    port (
        clk         : IN std_logic;
        rst         : IN std_logic;
    	input       : IN  std_logic;
        debounced   : OUT std_logic
    );
end Debouncer;

architecture rtl of Debouncer is
   -- signal, component etc. declarations
    signal counter          : std_logic_vector (counter_size-1 downto 0) := (others => '0'); -- counter for debouncing
    signal counter_start    : std_logic;

    signal current_signal   : std_logic := '0';
    signal prev_signal      : std_logic := '0';
    signal output_signal    : std_logic := '0';

    signal click_registered : std_logic := '0';
    begin

    clocking:process(clk,rst)
    begin
    if (rst = '0') then
        output_signal <= '0';

    elsif(rising_edge(clk)) then
        current_signal <= input;
        prev_signal <= current_signal;

        --when button is pressed counter_en is '1'
        if (counter_start = '1') then
            counter <= (others =>'0');
            click_registered <= '1';
            output_signal <= '0';

        -- count as long as button is pressed
        elsif (counter(counter_size - 1) = '0') then
            counter <= counter + 1 ;
            output_signal <= '0';

        -- counter reached required value, click_registered is HIGH
        elsif (counter(counter_size - 1) = '1') AND (click_registered ='1') then
            counter <= (others => '0');
            click_registered <= '0';
            output_signal <= prev_signal;

        --to avoid multiple button pushes
        else
            counter <= (others =>'0');
            click_registered <= '0';
            output_signal <= '0';
        end if;
    end if;
    end process;

    -- differing prev and cur state, resets logic
    counter_start <= prev_signal xor current_signal;
    debounced <= output_signal;
end rtl;
