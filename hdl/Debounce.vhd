library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Debouncer is
generic (
    counter_size : integer := 26
);
port (
	En_in : IN  std_logic; --bouncing
    clk : IN std_logic;
    rst : IN std_logic;
    En_out : OUT std_logic  --debounced
);
end Debouncer;

architecture rtl of Debouncer is

   -- signal, component etc. declarations
    signal counter_out: std_logic_vector (counter_size-1 downto 0) := (others => '0'); -- counter for debouncing
    signal value_now : std_logic := '0';
    signal value_old : std_logic := '0';
    signal counter_set : std_logic;
    signal result : std_logic := '0';
    signal one_click : std_logic := '0';
    begin

    clocking:process(clk,rst)
    begin
    if (rst = '0') then -- asynchronous reset
        result <= '0';

    elsif(rising_edge(clk)) then
        value_now <= En_in;
        value_old <= value_now;

        --when button is pressed counter_set is '1'
        if (counter_set ='1') then
            counter_out <= (others =>'0');
            result <='0';
            one_click<= '1';

        --as long as the button does not change counter_out will increase
        elsif (counter_out(counter_size-1) = '0') then
            counter_out <= counter_out+1;
            result <= '0';

        --as soon as counter_out reaches required value and one_click flag is high
        elsif (counter_out(counter_size-1) = '1') AND (one_click ='1') then
            result <=value_old;
            counter_out <= (others =>'0');
            one_click <='0';

        --to avoid multiple button pushes; one_click hinders this behaviour
        else
            result <= '0';
            one_click<='0';
            counter_out <= (others =>'0');
        end if;
    end if;
    end process;

    counter_set <= value_now xor value_old; --output is 1 when input differs
    En_out <=result;
end rtl;
