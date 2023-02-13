library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ErrorDetectionCorrectionSlave IS
    PORT (
        -- APB I/Os
        PCLK        : IN STD_LOGIC;
        PRESETN     : IN STD_LOGIC;
        PSEL        : IN STD_LOGIC;
        PENABLE     : IN STD_LOGIC;
        PWRITE      : IN STD_LOGIC;
        PADDR       : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
        PWDATA      : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
        PRDATA      : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
        PREADY      : OUT STD_LOGIC;
        PSLVERR     : OUT STD_LOGIC;
        -- Specific use-case I/Os
        DECODED     : OUT STD_LOGIC;
        LEDS        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
end ErrorDetectionCorrectionSlave;

architecture rtl OF ErrorDetectionCorrectionSlave IS
    constant data_width : integer := 32;
    constant address_offset_width : integer := 8;

    type memory_mapped_register_t is array (0 TO (address_offset_width ** 2) - 1) of std_logic_vector(data_width - 1 downto 0);

    type leds_t is array(4 downto 0) of std_logic_vector(3 downto 0);
    constant LEDS_ARR : leds_t := ("0000", "0111", "1011", "1101", "1110");

    type state IS (IDLE, MASTER_WRITE, SLAVE_DECODE, MASTER_READ, SLAVE_END);

    signal MEMORY_MAPPED_REGISTERS : memory_mapped_register_t;
    signal leds_signal : std_logic_vector(3 downto 0);
    signal current_state, next_state: state;
    signal decode_en : std_logic := '0';
    signal decode_end : std_logic := '0';
begin
    DECODED <= decode_end;
    LEDS <= leds_signal;

    bus_process : process (PCLK, PRESETN) is
        variable PRDATA_V  : std_logic_vector(data_width - 1 DOWNTO 0);
        variable PREADY_V  : std_logic;
        variable PSLVERR_V : std_logic;
        variable PINDEX_V  : integer;
    begin
        if PRESETN = '0' then
            MEMORY_MAPPED_REGISTERS <= (others => (others => '0'));
            PRDATA_V := (others => '0');
            PREADY_V := '0';
            PSLVERR_V := '0';
            PINDEX_V  := '0';

        elsif rising_edge(PCLK) then
            PRDATA_V  := (others => '0');
            PREADY_V  := '0';
            PSLVERR_V := '0';
            PINDEX_V  := '0';
            -- SLAVE SELECTED
            if PSEL = '1' then
                -- ALLOWED TO REACT
                if PENABLE = '1' then
                    PREADY_V := '1';
                    PINDEX_V := TO_INTEGER(UNSIGNED(PADDR(address_offset_width - 1 downto 2)));
                    -- WRITE
                    if PWRITE = '1' then
                        MEMORY_MAPPED_REGISTERS(PINDEX_V) <= PWDATA;
                    -- READ
                    else
                        PRDATA_V := MEMORY_MAPPED_REGISTERS(PINDEX_V);
                    end if;
                end if;
            end if;
        end if;
        PRDATA <= PRDATA_V;
        PREADY <= PREADY_V;
        PSLVERR <= PSLVERR_V;
    end process;

    slave_fsm_transition: process(PCLK, PRESETN) is
    begin
        if (PRESETN = '0') then
            current_state <= IDLE;
        elsif rising_edge(PCLK) then
            current_state <= next_state;
        end if;
    end process;

    slave_fsm_state_def: process (current_state) is
    begin
        next_state <= current_state;
        decode_en <= '0';
        case current_state is
            when IDLE =>
                if MEMORY_MAPPED_REGISTERS(0) = X"00000001" then
                    next_state <= MASTER_WRITE;
                end if;
                leds_signal <= LEDS_ARR(0);

            when MASTER_WRITE =>
                if MEMORY_MAPPED_REGISTERS(0) = X"00000002" then
                    next_state <= SLAVE_DECODE;
                end if;
                leds_signal <= LEDS_ARR(1);

            when SLAVE_DECODE =>
                if MEMORY_MAPPED_REGISTERS(0) = X"00000003" then
                    next_state <= MASTER_READ;
                end if;
                decode_en = '1';
                LEDS_OUT <= LEDS_ARR(2);

            when MASTER_READ =>
                if MEMORY_MAPPED_REGISTERS(0) = X"00000004" then
                    next_state <= SLAVE_END;
                end if;
                LEDS_OUT <= LEDS_ARR(3);

            when SLAVE_END =>
                LEDS_OUT <= LEDS_ARR(4);
        end case;
    end process;

    decode_process : process (PCLK, PRESETN) is
        variable encoded_vector : std_logic_vector(15 downto 0) := (others => '0');
        variable decoded_vector : std_logic_vector(15 downto 0) := (others => '0');
        variable parity_vector : std_logic_vector(4 downto 0) := (others => '0');
        variable err_vector : std_logic_vector(1 downto 0) := (others => '0');
        variable err_pos : integer := 0;
        variable decode_end : std_logic := '0';
    begin
        if PRESETN = '0' then
            encoded_vector := (others => '0');
            decoded_vector := (others => '0');
            parity_vector := (others => '0');
            err_vector := (others => '0');
            err_pos := 0;

            decode_end := '0';
        elsif rising_edge(PCLK) then
            if decode_en = '1' then
                encoded_vector := MEMORY_MAPPED_REGISTERS(i*4)(15 downto 0)
                parity_vec(0) <= enc_data(1) xor enc_data(3) xor enc_data(5) xor enc_data(7) xor enc_data(9) xor enc_data(11)  xor enc_data(13) xor enc_data(15);
                parity_vec(1) <= enc_data(2) xor enc_data(3) xor enc_data(6) xor enc_data(7) xor enc_data(10) xor enc_data(11) xor enc_data(14) xor enc_data(15);
                parity_vec(2) <= enc_data(4) xor enc_data(5) xor enc_data(6) xor enc_data(7) xor enc_data(12) xor enc_data(13) xor enc_data(14) xor enc_data(15);
                parity_vec(3) <= enc_data(8) xor enc_data(9) xor enc_data(10) xor enc_data(11) xor enc_data(12) xor enc_data(13) xor enc_data(14) xor enc_data(15);
                parity_vec(4) <= enc_data(1) xor enc_data(2) xor enc_data(3) xor enc_data(4) xor enc_data(5) xor enc_data(6) xor enc_data(7) xor enc_data(8) xor enc_data(9) xor enc_data(10) xor enc_data(11) xor enc_data(12) xor enc_data(13) xor enc_data(14) xor enc_data(15) xor enc_data(16);

                err_pos := to_integer(unsigned(parity_vec(3 downto 0)));
                err_vector := "00" when err_pos  = 0 and parity_vector(4) = '0' else
                              "01" when err_pos /= 0 and parity_vector(4) = '1' else
                              "10" when err_pos /= 0 and parity_vector(4) = '0' else
                              "11";
                -- for loop in vhdl and flip err_pos bit
                decoded_vector := encoded_vector;
                for

                decode_end := '1';
            else
                decode_end := '0';
            end if;
        end if;
        decode_end <= decode_end_v;
    end process;
end rtl;
