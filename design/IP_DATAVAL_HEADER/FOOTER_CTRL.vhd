
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FOOTER_CTRL is
GENERIC (
         DIN_DATA_BIT_VAL : INTEGER :=8;
         ADDR_BIT_VAL : INTEGER :=4;    -- ES
         DATA_BIT_VAL : INTEGER :=16;
         NumFooterBytes : INTEGER :=11
       );
Port (

    CLK                 : IN STD_LOGIC;
    RST                 : IN STD_LOGIC;
    -- IP_Packet_valid     : IN STD_LOGIC;
    DATA_VALID          : IN STD_LOGIC;
    GOOD_PACKET_RECEIVED : IN STD_LOGIC;
    DIN                 :IN STD_LOGIC_VECTOR(DIN_DATA_BIT_VAL-1 DOWNTO 0);
    rlt_address_from_sync    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    hd_ptr_address_from_sync : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    slice_merging_factor : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 11/10/2023
    fs_merging_factor : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    fs_sequence_counter : out std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
    fq_stream_enable : OUT STD_LOGIC
    );
end FOOTER_CTRL;


architecture FOOTER_CTRL of FOOTER_CTRL is

--SIGNAL S_WAIT4HDR   : STD_LOGIC;
  signal S_IP_ACCEPTED      : std_logic;
  signal S_DATA_ACCEPTED    : std_logic;

  signal S_ADDRA            : std_logic_vector(4 downto 0);
  signal S_DIN              : std_logic_vector(DIN_DATA_BIT_VAL-1 downto 0);
  -- constant C_MAX_S_ADDR_VAL : std_logic_vector(4 downto 0) := 5UX"B"; -- ES: 11bytes SYNC footer
  constant C_MAX_S_ADDR_VAL : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(NumFooterBytes,5)); -- SYNC footer size

  -- 18/09/2023
  signal F_ADDRA, F_ADDRA_R    : STD_LOGIC_VECTOR(ADDR_BIT_VAL-1 DOWNTO 0);
  signal F_DOUT, F_DOUT_R      : STD_LOGIC_VECTOR(DATA_BIT_VAL-1 DOWNTO 0);
  signal F_WEA                 : STD_LOGIC_VECTOR(0 DOWNTO 0);

  -- 20/03/2023
  signal header_timeout_cnt : natural range 0 to 25000     := 25000;
  signal header_timeout_err : std_logic                    := '0';
  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of header_timeout_cnt, header_timeout_err, GOOD_PACKET_RECEIVED, DATA_VALID, F_DOUT, F_ADDRA_R : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of header_timeout_cnt, header_timeout_err, GOOD_PACKET_RECEIVED, DATA_VALID, F_DOUT, F_ADDRA_R : signal is "true";

BEGIN


ENA_PRO: PROCESS (CLK, RST)
BEGIN
IF RST='1' THEN
    -- ENA <='0';
    F_WEA<=(OTHERS=>'0');
    S_IP_ACCEPTED<='0';
    S_DATA_ACCEPTED <='0';
    F_DOUT<=(OTHERS=>'0');
    F_DOUT_R<=(OTHERS=>'0');
    F_ADDRA<=(OTHERS=>'0');
    F_ADDRA_R<=(OTHERS=>'0');
    S_ADDRA<=(OTHERS=>'0');
    S_DIN<=(OTHERS=>'0');
    rlt_address_from_sync<=(OTHERS=>'0');
    hd_ptr_address_from_sync<=(OTHERS=>'0');
    slice_merging_factor<=(OTHERS=>'0');
    fs_merging_factor<=(OTHERS=>'0');
    fq_stream_enable <= '0';
    fs_sequence_counter<=(OTHERS=>'0');
ELSIF CLK'EVENT AND CLK='1' THEN

  IF GOOD_PACKET_RECEIVED = '0' AND DATA_VALID = '1' THEN  -- ES: footer data valid
    S_DATA_ACCEPTED <= '1';
    F_WEA <= (OTHERS => '1');
    IF S_ADDRA(0) = '0' then
           IF S_ADDRA < C_MAX_S_ADDR_VAL THEN
                F_ADDRA <= S_ADDRA(ADDR_BIT_VAL DOWNTO 1);
                S_ADDRA <= std_logic_vector (unsigned (S_ADDRA) + 1);
                S_DIN <= DIN;  -- ES: LSB data
            ELSIF S_ADDRA = C_MAX_S_ADDR_VAL THEN
                F_ADDRA <= S_ADDRA(ADDR_BIT_VAL DOWNTO 1);
                S_DIN <= DIN;
                S_ADDRA <= (OTHERS => '0');
            END IF;

        ELSIF S_ADDRA(0) = '1' then
            IF S_ADDRA < C_MAX_S_ADDR_VAL THEN
                S_ADDRA <= std_logic_vector (unsigned (S_ADDRA) + 1);
                F_DOUT <= DIN&S_DIN;  -- ES: MSB & LSB data
            ELSIF S_ADDRA = C_MAX_S_ADDR_VAL THEN
                F_DOUT <= DIN&S_DIN;
                S_ADDRA <= (OTHERS => '0');
            END IF;
        END IF;
    ELSIF GOOD_PACKET_RECEIVED = '1' AND S_DATA_ACCEPTED = '1' THEN
        F_WEA <= (OTHERS => '0');
        S_DATA_ACCEPTED <= '0';
        S_ADDRA <= (OTHERS => '0');     -- !debug: 13/10/2023
    END IF;

    F_ADDRA_R <= F_ADDRA;
    F_DOUT_R <= F_DOUT;
    -- if (F_ADDRA_R = X"0") then
    --   rlt_address_from_sync(15 downto 0) <= F_DOUT; -- Bytes1 0..3: RLT Slot Address bits[31..0]
    -- elsif (F_ADDRA_R = X"1") then
    --   rlt_address_from_sync(31 downto 16) <= F_DOUT;
    -- elsif (F_ADDRA_R = X"2") then
    --   hd_ptr_address_from_sync(15 downto 0) <= F_DOUT; -- Bytes1 4..7: HD Pointer Address bits[31..0]
    -- elsif (F_ADDRA_R = X"3") then
    --   hd_ptr_address_from_sync(31 downto 16) <= F_DOUT;
    -- end if;

    -- !debug: 12/10/2023
    -- v1 (original): F_ADDRA_R, F_DOUT
    -- v2: F_ADDRA, F_DOUT_R
    -- v3: F_ADDRA, F_DOUT
    case F_ADDRA_R is
      -- note: bytes in footer word are swapped
      when X"0" => rlt_address_from_sync(15 downto 0) <= F_DOUT; -- Bytes 0..3: RLT Slot Address bits[31..0]
      when X"1" => rlt_address_from_sync(31 downto 16) <= F_DOUT;
      when X"2" => hd_ptr_address_from_sync(15 downto 0) <= F_DOUT; -- Bytes 4..7: HD Pointer Address bits[31..0]
      when X"3" => hd_ptr_address_from_sync(31 downto 16) <= F_DOUT;  -- Byte 8: Merging Factor
      when X"4" => fs_merging_factor <= F_DOUT(1 downto 0);  -- Byte 9: Focal spot merging factor
                   slice_merging_factor <= F_DOUT(9 downto 8);
      when X"5" => fq_stream_enable <= F_DOUT(8);             -- Byte 10: bit(0) - FQ Stream Enable when ‘1’
                   fs_sequence_counter <= F_DOUT(2 downto 0);      -- Byte 11: FS sequence counter

      when others => null;
    end case;

END IF;

END PROCESS;


misc_test_pr: process (clk) is
begin  -- process misc_test_pr
  if (clk'event and clk = '1') then  -- rising clock edge

    if (GOOD_PACKET_RECEIVED ='1' and S_IP_ACCEPTED ='1') then
      header_timeout_cnt <= 25000;
    elsif (header_timeout_cnt /= 0) then
      header_timeout_cnt <= header_timeout_cnt - 1;
    end if;
    if (header_timeout_cnt = 0) then
      header_timeout_err <= '1';
    else
      header_timeout_err <= '0';
    end if;

  end if;
end process misc_test_pr;


end FOOTER_CTRL;
