-------------------------------------------------------------------------------
-- Title      : Registers to AMS SPI decoder
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : tmb_reg2spictl.vhd
-- Author     : Shinderman Eugene  <evgene@hbtech.co.il>
-- Company    : Philips Medical
-- Created    : 03/04/2023
-- Last update: 11/12/2023
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: Migration from TMCOR v.6 registers mapped to MOSASIC -> TMB.
--              Provide AMS SPI controls from registers, interface between
--              AMS registers to TMB registers
-------------------------------------------------------------------------------
-- - HSID p.22 R/W	0xB0X06650	Asics Read/Write operations (default: 0x0)
--	 [30..16] - Data to be writer to Asic
--	 [14] - '0' - WR, '1' - RD
--	 [12] - '0' - Asic_0 in Tile, '1' - Asic_1 in Tile
--	 [11..0] - ADDR to access inside Asic for Read/Write operations
--	 !TODO: map to AMS_packet, AMS_Wr
-- - AMS_S2p_ready, mrreg_ready - any access to 0x65 register
--   AMS_Wr, updateregD - write to 0x65 register

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
library work;
use work.phoebe.all;


entity tmb_reg2spictl is
  generic(
    WORD_WIDTH2	: integer  := 15
    );
  port (
    rst_n          : in  std_logic;
    sys_clk        : in  std_logic;                           -- system clock @50MHz
    AMS_packet     : in  std_logic_vector(31 downto 0);       -- [15..0] - ASIC data, [31..16] - ASIC addr
    AMS_Wr         : in  std_logic;                           -- WR !debug: 23/04/2023 seems NU
    AMS_S2p_ready  : in std_logic;                            -- EXE
    wrreq          : out std_logic_vector(1 downto 0);        -- to Tiles_managment
    REGS_req       : out std_logic_vector (39 downto 0);      -- to Tiles_managment
    ms_spi_sel     : in  std_logic;
    Asics_Read_Sel_dec : in  std_logic_vector(8 downto 0); -- from reg. 0x66, [7] - master/slave, [6..0] - ASIC in tile
    READ_OUT_READY : in  std_logic_vector(2*NumOfTiles-1 downto 0); -- from Tiles_managment
    DATA2R         : in  std_logic_vector (2*NumOfTiles*WORD_WIDTH2-1 downto 0);  -- from Tiles_managment [14..0]
    AMS_DATA2R     : out std_logic_vector (15 downto 0)
    );
end entity tmb_reg2spictl;


architecture ar of tmb_reg2spictl is

  -- signals:
  signal AMS_packet_r1, AMS_packet_r2 : std_logic_vector(31 downto 0);
  signal AMS_S2p_ready_shr : std_logic_vector(3 downto 0)   := (others => '0');  -- AMS_Wr_shr
  signal Pebe_Reg_I                   : std_logic_vector (15 downto 0) := (others => '0');  -- [15] - WR, [14] - RD
  signal Pebe_Reg_D                   : std_logic_vector (15 downto 0) := (others => '0');
  signal IF_Command_Reg               : std_logic_vector (15 downto 0);
  signal A_sel_aCNT                   : std_logic_vector (15 downto 0);                     -- asic select and control
  signal Asic_sel                     : std_logic_vector (7 downto 0);                      -- asic select
  -- signal CNT_bits                  :   std_logic_vector (15 DOWNTO 8);               -- control lines
  signal Asics_Read_Sel_dec_r : std_logic_vector(8 downto 0); -- reg. 0x66
  signal DATA2R_r         : unsigned(2*NumOfTiles*WORD_WIDTH2-1 downto 0);

  signal test_wrreq : std_logic;
  signal test_seq_cnt : natural range 0 to 255;
  signal test_1ms_cnt, test_ms_timer : natural range 0 to 2**16;

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of test_wrreq, test_seq_cnt, test_1ms_cnt, test_ms_timer, Pebe_Reg_I, Pebe_Reg_D, Asics_Read_Sel_dec, DATA2R_r, AMS_DATA2R : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of test_wrreq, test_seq_cnt, test_1ms_cnt, test_ms_timer, Pebe_Reg_I, Pebe_Reg_D, Asics_Read_Sel_dec, DATA2R_r, AMS_DATA2R : signal is "true";

begin  -- architecture ar


  reg2ctl_pr: process (sys_clk, rst_n) is
  begin  -- process reg2ctl_pr
    if (rst_n = '0') then                        -- asynchronous reset (active low)
    elsif (sys_clk'EVENT and sys_clk = '1') then  -- rising clock edge

      -- 0x65 -> AMS_packet -> Pebe_Reg_I, Pebe_Reg_D
      AMS_packet_r1 <= AMS_packet;        -- [15..0] - ASIC data, [31..16] - ASIC addr
      AMS_packet_r2 <= AMS_packet_r1;
      -- AMS_Wr_shr <= AMS_Wr_shr(2 downto 0) & AMS_Wr;
      AMS_S2p_ready_shr <= AMS_S2p_ready_shr(2 downto 0) & AMS_S2p_ready;

      if (AMS_S2p_ready_shr(2) = '0' and AMS_S2p_ready_shr(1) = '1') then
        Pebe_Reg_I <= AMS_packet_r2(15 downto 0);
        Pebe_Reg_D <= AMS_packet_r2(31 downto 16);
      end if;

      wrreq(0) <= '0'; -- NU, const '0'
      -- if (AMS_Wr_shr(3) = '0' and AMS_Wr_shr(2) = '1' and Pebe_Reg_I(15) = '1') then
      if (AMS_S2p_ready_shr(3) = '0' and AMS_S2p_ready_shr(2) = '1') then
        wrreq(1)		<=	'1' ;
      else
        wrreq(1)		<=	'0' ;
      end if;

      A_sel_aCNT <= X"0000"; -- !TODO: 03/04/2023 was	asic_register_bank(asic_sel_addr) ;  for Taichi TBD
      Asic_sel		<=	A_sel_aCNT( 7 downto 0) ;
      -- CNT_bits		<=	A_sel_aCNT(15 downto 8) ;
      -- CNT_lines(15 downto 8)		<=	CNT_bits(15 downto 8) ;

      -- Note:
      --   RWn_int            <= SPI_BUS_CTRL(38); -- 0 write 1 read
      --   EXE_int            <= SPI_BUS_CTRL(39);
      REGS_req	<=	'1' & Pebe_Reg_I(14) & "00" & Asic_sel (3 downto 0) & '0' & Pebe_Reg_D (14 downto 0) & "00" & Pebe_Reg_I (13 downto 0);


    end if;
  end process reg2ctl_pr;


  rdata2regs_pr: process (sys_clk, rst_n) is
  begin  -- process rdata2regs_pr
    if (rst_n = '0') then                        -- asynchronous reset (active low)
      Asics_Read_Sel_dec_r <= (others => '0');
    elsif (sys_clk'EVENT and sys_clk = '1') then  -- rising clock edge

      Asics_Read_Sel_dec_r <= Asics_Read_Sel_dec;

      -- -- upd
      -- if (ms_spi_sel = '1') then        -- updates register data only from master Asic
      --     DATA2R_r(2*NumOfTiles*WORD_WIDTH2-1 downto NumOfTiles*WORD_WIDTH2) <= unsigned(DATA2R(2*NumOfTiles*WORD_WIDTH2-1 downto NumOfTiles*WORD_WIDTH2));
      --     DATA2R_r(NumOfTiles*WORD_WIDTH2-1 downto 0) <= unsigned(DATA2R(NumOfTiles*WORD_WIDTH2-1 downto 0));
      -- else                              -- updates register data only from slave Asic
      --     DATA2R_r(NumOfTiles*WORD_WIDTH2-1 downto 0) <= unsigned(DATA2R(NumOfTiles*WORD_WIDTH2-1 downto 0));
      -- end if;

      upd_l : for i in 0 to NumOfTiles-1 loop

        -- -- upd
        -- if (ms_spi_sel = '1') then      -- updates register data only from master Asic
        --   if (READ_OUT_READY(i) = '1') then
        --     DATA2R_r(i*WORD_WIDTH2+WORD_WIDTH2-1 downto i*WORD_WIDTH2) <= unsigned(DATA2R(i*WORD_WIDTH2+WORD_WIDTH2-1 downto i*WORD_WIDTH2));
        --   end if;
        -- else                            -- updates register data only from slave Asic
        --   if (READ_OUT_READY(4+i) = '1') then
        --     DATA2R_r((4+i)*WORD_WIDTH2+WORD_WIDTH2-1 downto (4+i)*WORD_WIDTH2) <= unsigned(DATA2R((4+i)*WORD_WIDTH2+WORD_WIDTH2-1 downto (4+i)*WORD_WIDTH2));
        --   end if;
        -- end if;
        -- upd (note: register data as slave & master)
	if (ms_spi_sel = '1') then	-- updates register data only from master Asic
	  if (READ_OUT_READY(i) = '1') then
	    DATA2R_r(i*WORD_WIDTH2+WORD_WIDTH2-1 downto i*WORD_WIDTH2) <= unsigned(DATA2R(i*WORD_WIDTH2+WORD_WIDTH2-1 downto i*WORD_WIDTH2));
	  end if;
	else				-- updates register data only from slave Asic
	  if (READ_OUT_READY(4+i) = '1') then
	    DATA2R_r((4+i)*WORD_WIDTH2+WORD_WIDTH2-1 downto (4+i)*WORD_WIDTH2) <= unsigned(DATA2R((4+i)*WORD_WIDTH2+WORD_WIDTH2-1 downto (4+i)*WORD_WIDTH2));
	  end if;
	end if;

        -- sel2reg
        if (Asics_Read_Sel_dec_r(8) = '1') then      -- updates register data from master Asic
          if (Asics_Read_Sel_dec_r(i) = '1') then -- note: decoded bit mapping not as in reg.0x66
            AMS_DATA2R <= std_logic_vector(resize(DATA2R_r(i*WORD_WIDTH2+WORD_WIDTH2-1 downto i*WORD_WIDTH2),16));
          end if;
        else                                    -- updates register data from slave Asic
          if (Asics_Read_Sel_dec_r(i) = '1') then -- note: decoded bit mapping not as in reg.0x66
            AMS_DATA2R <= std_logic_vector(resize(DATA2R_r((4+i)*WORD_WIDTH2+WORD_WIDTH2-1 downto (4+i)*WORD_WIDTH2),16));
          end if;
        end if;

      end loop upd_l;  -- i


    end if;
  end process rdata2regs_pr;


  test_pr: process (sys_clk, rst_n) is
  begin  -- process test_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      test_wrreq <=	'0' ;
      test_seq_cnt <= 0;
      test_1ms_cnt <= 0;
      test_ms_timer <= 0;
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      if (AMS_S2p_ready_shr(3) = '0' and AMS_S2p_ready_shr(2) = '1') then
        test_wrreq <= '1' ;
        test_seq_cnt <= test_seq_cnt + 1; -- write sequence num
      else
        test_wrreq <= '0' ;
      end if;

      if (test_1ms_cnt = 0) then
        test_1ms_cnt <= 50000;
        test_ms_timer <= test_ms_timer + 1; -- timer * 1ms
      else
        test_1ms_cnt <= test_1ms_cnt - 1; -- 1ms delay
      end if;

    end if;
  end process test_pr;


end architecture ar;
