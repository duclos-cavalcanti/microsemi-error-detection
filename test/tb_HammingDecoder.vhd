library IEEE;
use IEEE.std_logic_1164.all;

-- vunit
library vunit_lib;
use vunit_lib.run_pkg.all;
use vunit_lib.check_pkg.all;

entity tb_HammingDecoder is
    generic (runner_cfg : string);
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
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("test_0") then
                report "Test 0!";
                rst_in <= '1';
                wait for period;

                rst_in <= '0';
                ready <= '1';
                input <= "0000000000000000111111";
                wait for period;
                check(err='0', "Err flag is being thrown unnecessarily!");

                test_runner_cleanup(runner);
            elsif run("test_1") then
                report "Test 1!";
                rst_in <= '1';
                wait for period;

                rst_in <= '0';
                ready <= '1';
                input <= "0000000000000000101111";
                wait for period;
                check(err='1', "Err is not being detected!");

                test_runner_cleanup(runner);
            end if;
        end loop;
    end process;
end tb;
