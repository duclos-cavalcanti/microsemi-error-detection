LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY EC_SLAVE IS
    PORT (
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

        LEDS        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END EC_SLAVE;

ARCHITECTURE RTL OF EC_SLAVE IS
    CONSTANT DATA_WIDTH : INTEGER := 32;
    CONSTANT ADDRESS_OFFSET_WIDTH : INTEGER := 8;

    TYPE MEMORYMAPPEDREGISTER_T IS ARRAY (0 TO (ADDRESS_OFFSET_WIDTH ** 2) - 1) OF STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL MEMORY_MAPPED_REGISTERS : MEMORYMAPPEDREGISTER_T;

    TYPE LEDS_T IS ARRAY(4 DOWNTO 0) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
    CONSTANT LEDS_ARR :  LEDS_T := ("0000", "0111", "1011", "1101", "1110");
    CONSTANT LEDS_OFF :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    SIGNAL LEDS_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0) := LEDS_ARR(0);

    TYPE STATE IS (S0,S1,S2,S3,S4);
    SIGNAL CURRENT_STATE, NEXT_STATE: STATE;

    TYPE ERR_T IS ARRAY(12 DOWNTO 1) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ERR_ARR : ERR_T := (others => "00");

    TYPE LOAD_T IS ARRAY(12 DOWNTO 1) OF STD_LOGIC_VECTOR(16 DOWNTO 1);
    SIGNAL ENC_DATA  : LOAD_T := (others => X"0000");
    SIGNAL DEC_DATA  : LOAD_T := (others => X"0000");

    SIGNAL VALIDS_IN  : STD_LOGIC_VECTOR(12 downto 1) := (others => '0');
    SIGNAL VALIDS_OUT : STD_LOGIC_VECTOR(12 downto 1) := (others => '0');

    COMPONENT HammingDecoder is
        port (
            CLK         : IN STD_LOGIC;
            RST         : IN STD_LOGIC;
            VALID_IN    : IN STD_LOGIC;
            ENC_DATA    : IN  STD_LOGIC_VECTOR(16 downto 1);
            DEC_DATA    : OUT STD_LOGIC_VECTOR(16 downto 1);
            ERR         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            VALID_OUT   : OUT STD_LOGIC
        );
    end COMPONENT;

BEGIN
    -- Hamming Decoder generated
	g:FOR i IN 1 TO 12 GENERATE
		i_HD: HammingDecoder port map (
            CLK         => PCLK,
            RST         => PRESETN,
            VALID_IN    => VALIDS_IN(i),
            ENC_DATA    => MEMORY_MAPPED_REGISTERS(i*4)(15 downto 0),
            DEC_DATA    => DEC_DATA(i),
            ERR         => ERR_ARR(i),
            VALID_OUT   => VALIDS_OUT(i)
        );
	end generate;

    LEDS <= LEDS_OUT;

    BUS_PROCESS : PROCESS (PCLK, PRESETN) IS
        VARIABLE PRDATA_V  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        VARIABLE PREADY_V  : STD_LOGIC;
        VARIABLE PSLVERR_V : STD_LOGIC;

        VARIABLE PINDEX_V  : INTEGER;
    BEGIN
        IF PRESETN = '0' THEN
            MEMORY_MAPPED_REGISTERS <= (OTHERS => (OTHERS => '0'));
            PRDATA_V := (OTHERS => '0');
            PREADY_V := '0';
            PSLVERR_V := '0';
        ELSE
            IF RISING_EDGE(PCLK) THEN
                PRDATA_V := (OTHERS => '0');
                PREADY_V := '0';
                PSLVERR_V := '0';
                -- SLAVE SELECTED
                IF PSEL = '1' THEN
                    -- ALLOWED TO REACT
                    IF PENABLE = '1' THEN
                        PREADY_V := '1';
                        IF PWRITE = '1' THEN -- WRITE
                            MEMORY_MAPPED_REGISTERS(TO_INTEGER(UNSIGNED(PADDR(ADDRESS_OFFSET_WIDTH - 1 DOWNTO 0)))) <= PWDATA;
                        ELSE                  -- READ
                            PINDEX_V := TO_INTEGER(UNSIGNED(PADDR(ADDRESS_OFFSET_WIDTH - 1 DOWNTO 0)));
                            IF CURRENT_STATE = S0 THEN
                                PRDATA_V := MEMORY_MAPPED_REGISTERS(PINDEX_V);

                            ELSIF CURRENT_STATE = S1 THEN
                                PRDATA_V := MEMORY_MAPPED_REGISTERS(PINDEX_V);

                            ELSIF CURRENT_STATE = S2 THEN
                                IF PINDEX_V = 0 AND VALIDS_OUT = X"FFF" THEN
                                    PRDATA_V := X"00000003";
                                    MEMORY_MAPPED_REGISTERS(0) <= X"00000003";
                                END IF;

                            ELSIF CURRENT_STATE = S3 THEN
                                PRDATA_V := DEC_DATA(PINDEX_V) & X"0000";
                                MEMORY_MAPPED_REGISTERS(PINDEX_V) <= DEC_DATA(PINDEX_V) & X"0000";

                            ELSE
                                PRDATA_V := MEMORY_MAPPED_REGISTERS(PINDEX_V);
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        PRDATA <= PRDATA_V;
        PREADY <= PREADY_V;
        PSLVERR <= PSLVERR_V;
    END PROCESS;

    SLAVE_FSM_TRANSITION: PROCESS (PCLK, PRESETN) IS
    BEGIN
        IF (PRESETN = '0') THEN
            CURRENT_STATE <= S0;
        ELSIF RISING_EDGE(PCLK) THEN
            CURRENT_STATE <= NEXT_STATE;
        END IF;
    END PROCESS;

    SLAVE_FSM_STATE_DEF: PROCESS (CURRENT_STATE) IS
    BEGIN
        -- DEFINITION OF STATES AND OUTPUTS
        CASE CURRENT_STATE IS --MOORE FSM: OUTPUT DEPENDS ONLY ON CURRENT STATES
            --IDLE--
            WHEN S0 =>
                IF MEMORY_MAPPED_REGISTERS(0) = X"00000001" THEN
                    NEXT_STATE <= S1;
                ELSE
                    NEXT_STATE <= S0;
                END IF;
                LEDS_OUT <= LEDS_ARR(0);
            -- MSS WRITING DATA --
            WHEN S1 =>
                IF MEMORY_MAPPED_REGISTERS(0) = X"00000002" THEN
                    NEXT_STATE <= S2;
                ELSE
                    NEXT_STATE <= S1;
                END IF;
                LEDS_OUT <= LEDS_ARR(1);
            -- MSS FINISHED WRITING, FABRIC STARTS DECODING --
            WHEN S2 =>
                IF MEMORY_MAPPED_REGISTERS(0) = X"00000003" THEN
                    NEXT_STATE <= S3;
                    VALIDS_IN <= X"FFF";
                ELSE
                    NEXT_STATE <= S2;
                END IF;
                LEDS_OUT <= LEDS_ARR(2);
            -- DECODED DATA READY, MSS READING --
            WHEN S3 =>
                IF MEMORY_MAPPED_REGISTERS(0) = X"00000004" THEN
                    NEXT_STATE <= S4;
                ELSE
                    NEXT_STATE <= S3;
                END IF;
                LEDS_OUT <= LEDS_ARR(3);
            WHEN S4 =>
                LEDS_OUT <= LEDS_ARR(4);
        END CASE;
    END PROCESS;
END RTL;
