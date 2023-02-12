library IEEE;
use IEEE.std_logic_1164.all;

entity tb_HammingDecoder is
end tb_HammingDecoder;

architecture tb of tb_HammingDecoder is
    constant period : time := 20 ns;

    signal clk_in      : std_logic := '0';
    signal rst_in      : std_logic := '0';
    signal input    : std_logic_vector(21 downto 0) := (others => '0');
    signal ready    : std_logic := '0';
    signal output   : std_logic_vector(15 downto 0) := (others => '0');
    signal err      : std_logic := '0';

    component HammingDecoder is
        port (
            clk : IN std_logic;
            rst : IN std_logic;
            input_ready : IN std_logic;
            input       : IN std_logic_vector(21 downto 0);
            dec         : OUT std_logic_vector(15 downto 0);
            err         : OUT std_logic
        );
    end component;
begin
    UUT: HammingDecoder port map (
        clk => clk_in,
        rst => rst_in,
        input_ready => ready,
        input => input,
        dec => output,
        err => err
    );

    clk_process :process
    begin
        clk_in <= '1';
        wait for period/2;
        clk_in <= '0';
        wait for period/2;
    end process;

    main : process
    begin
    rst_in <= '1';
    wait for period;

    rst_in <= '0';
    ready <= '1';
    input <= "0000000000000000111111";
    wait for 2*period;
    -- assert err='0' report "Err flag is being thrown unnecessarily!";

    rst_in <= '1';
    wait for period;

    rst_in <= '0';
    ready <= '1';
    input <= "0000000000000000101111";
    wait for period;
    -- assert err='1' report "Err flag is not being detected!";

    wait;
    end process;
end tb;
