library IEEE;

use IEEE.std_logic_1164.all;

entity Dummy is
    port (
        clk       : IN std_logic;
        rst       : IN std_logic;
        rx        : IN std_logic;
        rx_valid  : IN std_logic;
        rx_end    : OUT std_logic;
        tx        : OUT std_logic_vector(15 downto 0);
        tx_valid  : OUT std_logic
    );
end Dummy;

architecture rtl of Dummy is
	constant MAX : natural := 16;

	signal data  : std_logic_vector(15 downto 0) := (others => '0');
    signal prev_read : std_logic := '0';
begin
    clocking: process(clk)
	variable cnt       : natural range 0 to 15 := 0;
    begin
        if (rst = '0') then
            tx_valid <= '0';
            data <= (others => '0');

            prev_read <= '0';
            rx_end <= '0';

        elsif rising_edge(clk) then
            if rx_valid = '1' then
                if cnt = MAX then
                    cnt := 0;
                    tx_valid <= '1';
                else
                    if prev_read = '0' then
                        data(cnt) <= rx;
                        cnt := cnt + 1;
                        prev_read <= '1';
                        rx_end <= '1';
                    end if;
                end if;
            else
                prev_read <= '0';
                rx_end <= '0';
            end if;
        end if;
    end process;

    tx <= data;
end rtl;

