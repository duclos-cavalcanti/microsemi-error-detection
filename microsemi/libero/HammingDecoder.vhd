library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HammingDecoder is
    port (
        CLK         : IN STD_LOGIC;
        RST         : IN STD_LOGIC;
        VALID_IN    : IN STD_LOGIC;
        ENC_DATA    : IN  STD_LOGIC_VECTOR(16 downto 1);
        DEC_DATA    : OUT STD_LOGIC_VECTOR(16 downto 1);
        ERR         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        VALID_OUT   : OUT STD_LOGIC
    );
end HammingDecoder;

architecture behavioral of HammingDecoder is
    CONSTANT WAIT_PERIOD : INTEGER := 100;
    SIGNAL PARITY_VEC   : STD_LOGIC_VECTOR(4 DOWNTO 0);

    SIGNAL V : STD_LOGIC := '0';
    SIGNAL DEC : std_logic_vector(16 downto 1) := (others => '0');
    SIGNAL ERR_CODE : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ERR_CODE_INT : INTEGER := 0;

    SIGNAL CNT : INTEGER := 0;
begin
    CLK_PROCESS: PROCESS(RST, CLK) IS
    BEGIN
        IF RST = '0' THEN
            CNT <= 0;
             V  <= '0';
        ELSIF RISING_EDGE(CLK) THEN
             IF VALID_IN = '1' THEN
                 IF CNT < WAIT_PERIOD THEN
                     CNT <= CNT + 1;
                 ELSE
                     CNT <= 0;
                     V <= '1';
                 END IF;
             END IF;
        END IF;
    END PROCESS;

    PARITY_VEC(0) <= ENC_DATA(1) XOR ENC_DATA(3)   XOR
                     ENC_DATA(5) XOR ENC_DATA(7)   XOR
                     ENC_DATA(9) XOR ENC_DATA(11)  XOR
                     ENC_DATA(13) XOR ENC_DATA(15);

    PARITY_VEC(1) <= ENC_DATA(2) XOR ENC_DATA(3)   XOR
                     ENC_DATA(6) XOR ENC_DATA(7)   XOR
                     ENC_DATA(10) XOR ENC_DATA(11) XOR
                     ENC_DATA(14) XOR ENC_DATA(15);

    PARITY_VEC(2) <= ENC_DATA(4) XOR ENC_DATA(5) XOR ENC_DATA(6) XOR ENC_DATA(7)    XOR
                     ENC_DATA(12) XOR ENC_DATA(13) XOR ENC_DATA(14) XOR ENC_DATA(15);

    PARITY_VEC(3) <= ENC_DATA(8) XOR ENC_DATA(9) XOR ENC_DATA(10) XOR ENC_DATA(11)  XOR
                     ENC_DATA(12) XOR ENC_DATA(13) XOR ENC_DATA(14) XOR ENC_DATA(15);

    PARITY_VEC(4) <= ENC_DATA(1) XOR ENC_DATA(2) XOR ENC_DATA(3) XOR ENC_DATA(4)    XOR
                     ENC_DATA(5) XOR ENC_DATA(6) XOR ENC_DATA(7) XOR ENC_DATA(8)    XOR
                     ENC_DATA(9) XOR ENC_DATA(10) XOR ENC_DATA(11) XOR ENC_DATA(12) XOR
                     ENC_DATA(13) XOR ENC_DATA(14) XOR ENC_DATA(15) XOR ENC_DATA(16);

    ERR_CODE_INT <=	TO_INTEGER(UNSIGNED(PARITY_VEC(3 downto 0)));

    ERR_CODE <= "00" WHEN ERR_CODE_INT  = 0 AND PARITY_VEC(4) = '0' ELSE
                "01" WHEN ERR_CODE_INT /= 0 AND PARITY_VEC(4) = '1' ELSE
                "10" WHEN ERR_CODE_INT /= 0 AND PARITY_VEC(4) = '0' ELSE
                "11";

    DEC <=      "00" WHEN ERR_CODE_INT  = 0 AND PARITY_VEC(4) = '0' ELSE
                "01" WHEN ERR_CODE_INT /= 0 AND PARITY_VEC(4) = '1' ELSE
                "10" WHEN ERR_CODE_INT /= 0 AND PARITY_VEC(4) = '0' ELSE
                "11";

    DEC <=      ENC_DATA(16 DOWNTO 16) & NOT ENC_DATA(15) & ENC_DATA(14 DOWNTO 1) WHEN ERR_CODE = "01" AND ERR_CODE_INT = 15  ELSE
                ENC_DATA(16 DOWNTO 15) & NOT ENC_DATA(14) & ENC_DATA(13 DOWNTO 1) WHEN ERR_CODE = "01" AND ERR_CODE_INT = 14  ELSE
                ENC_DATA(16 DOWNTO 14) & NOT ENC_DATA(13) & ENC_DATA(12 DOWNTO 1) WHEN ERR_CODE = "01" AND ERR_CODE_INT = 13  ELSE
                ENC_DATA(16 DOWNTO 13) & NOT ENC_DATA(12) & ENC_DATA(11 DOWNTO 1) WHEN ERR_CODE = "01" AND ERR_CODE_INT = 12  ELSE
                ENC_DATA(16 DOWNTO 12) & NOT ENC_DATA(11) & ENC_DATA(10 DOWNTO 1) WHEN ERR_CODE = "01" AND ERR_CODE_INT = 11  ELSE
                ENC_DATA(16 DOWNTO 11) & NOT ENC_DATA(10) & ENC_DATA(9 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 10  ELSE
                ENC_DATA(16 DOWNTO 10) & NOT ENC_DATA(9)  & ENC_DATA(8 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 9   ELSE
                ENC_DATA(16 DOWNTO 9)  & NOT ENC_DATA(8)  & ENC_DATA(7 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 8   ELSE
                ENC_DATA(16 DOWNTO 8)  & NOT ENC_DATA(7)  & ENC_DATA(6 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 7   ELSE
                ENC_DATA(16 DOWNTO 7)  & NOT ENC_DATA(6)  & ENC_DATA(5 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 6   ELSE
                ENC_DATA(16 DOWNTO 6)  & NOT ENC_DATA(5)  & ENC_DATA(4 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 5   ELSE
                ENC_DATA(16 DOWNTO 5)  & NOT ENC_DATA(4)  & ENC_DATA(3 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 4   ELSE
                ENC_DATA(16 DOWNTO 4)  & NOT ENC_DATA(3)  & ENC_DATA(2 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 3   ELSE
                ENC_DATA(16 DOWNTO 3)  & NOT ENC_DATA(2)  & ENC_DATA(2 DOWNTO 1)  WHEN ERR_CODE = "01" AND ERR_CODE_INT = 2   ELSE
                ENC_DATA(16 DOWNTO 2)  & NOT ENC_DATA(1)                          WHEN ERR_CODE = "01" AND ERR_CODE_INT = 1   ELSE
                (NOT ENC_DATA(16))     & ENC_DATA(15 DOWNTO 1)                    WHEN ERR_CODE = "11" ELSE
                ENC_DATA;


    -- outputs
    VALID_OUT   <= V;
    ERR         <= ERR_CODE;
    DEC_DATA    <= DEC;
end behavioral;
