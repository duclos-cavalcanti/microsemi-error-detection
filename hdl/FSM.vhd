library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FSM is
    port (
        clk         : IN std_logic;
        rst         : IN std_logic;
        SW1         : IN std_logic;
        SW2         : IN std_logic;
        DATA_VALID  : IN std_logic;
        LEDS        : OUT std_logic_vector(3 downto 0)
    );
end FSM;

architecture behavorial of FSM is
    type LEDS_TYPE is array(3 downto 0) of std_logic_vector(3 downto 0);
    type state is (S0,S1,S2,S3);
    signal current_state, next_state: state;

    signal LEDS_ARR :  LEDS_TYPE := ("0111", "1011", "1101", "1110");
    signal LEDS_SIG : std_logic_vector(3 downto 0) := (others => '0');
begin

    --process: switching between states
    state_transition: process(clk, rst)
    begin
        if (rst = '0') then   -- asynchronous reset
            current_state <= S0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- process: define states anda set output for each states
    states_definition: process (SW1, SW2, current_state)
    begin
        -- Definition of states and outputs
        case current_state is --Moore FSM: output depends only on current states
            when S0 =>
                if (DATA_VALID='1') then
                    next_state<=S1;
                else
                    next_state <= current_state;
                end if;
                LEDS_SIG <= LEDS_ARR(0);
            when S1 =>
                if (SW1='1') then
                    next_state<=S2;
                else
                    next_state <= current_state;
                end if;
               LEDS_SIG <= LEDS_ARR(1);
            when S2 =>
                if (SW1='1') then
                    --
                else
                    next_state <= current_state;
                end if;
                LEDS_SIG <= LEDS_ARR(2);
            when S3 =>
                if (SW1='1') then
                    --
                else
                    next_state <= current_state;
                end if;
                LEDS_SIG <= LEDS_ARR(3);
        end case;
    end process;

    LEDS <= LEDS_SIG;
end behavorial;
