-------------------------------------------------------------------------------
-- Title      : AMS memory_buffer interface
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : memory_buffer_if.vhd
-- Author     : Shinderman Eugene  <evgene@hbtech.co.il>
-- Company    : Philips Medical
-- Created    : 30/10/2022
-- Last update: 03/08/2023
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: prepare AMS ASIC's data for memory buffer or for TMB -> CDM payload
-------------------------------------------------------------------------------
-- !TODO: 31/10/2022
--  - option: add sim_data
--  - add EV reading
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_misc.all;
library work;

USE work.phoebe.all;


entity memory_buffer_if is
  generic (
    WORD_WIDTH : natural := 16);        -- byte,  consider change to 16bit
  port (
    sys_clk            : in  std_logic;  -- system clock @50MHz
    rst_n              : in  std_logic;
    IP50               : in  std_logic;
    Num_of_Slices      : in std_logic_vector(6 downto 0); -- 02/07/2023
    fq_data_valid      : in  std_logic;  -- 30/10/2022
    fq_data_in         : in  std_logic_vector(31 downto 0); -- !debug: 26/07/2023  was 15
    tmb_header_valid   : in std_logic;
    tmb_header         : in std_logic_vector (15 downto 0); -- !debug: 19/01/2023 was 7
    mem_buf_reading_ready : out std_logic;                            -- to taichi_slice_builder.rd_reading_ready
    mem_buf_fifo_rdata : out std_logic_vector(WORD_WIDTH-1 downto 0); -- to taichi_slice_builder.rx_det
    mem_buf_fifo_empty : out std_logic;                               -- to taichi_slice_builder.rx_fifo_empty
    mem_buf_fifo_rd    : in std_logic                                 -- to taichi_slice_builder.rx_fifo_rd
    );
end entity memory_buffer_if;


architecture ar of memory_buffer_if is

 -- component header_fifo is
 --  port (
 --    clk : in STD_LOGIC;
 --    srst : in STD_LOGIC;
 --    din : in STD_LOGIC_VECTOR ( 15 downto 0 ); -- !debug: 19/01/2023 was 7
 --    wr_en : in STD_LOGIC;
 --    rd_en : in STD_LOGIC;
 --    dout : out STD_LOGIC_VECTOR ( 15 downto 0 );
 --    full : out STD_LOGIC;
 --    empty : out STD_LOGIC;
 --    data_count : out STD_LOGIC_VECTOR ( 6 downto 0 )
 --    );
 -- end component header_fifo;
 -- 03/08/2023
 component header_fifo_dout32 is
  port (
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 15 downto 0 ); -- !debug: 19/01/2023 was 7
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    rd_data_count : out STD_LOGIC_VECTOR ( 5 downto 0 )
    );
 end component header_fifo_dout32;

 
 -- !debug: 26/07/2023 fq_fifo2048x16 -> fq_fifo2048x32to16
 -- component fq_fifo2048x32to16 is
 --  port (
 --    clk : in STD_LOGIC;
 --    srst : in STD_LOGIC;
 --    din : in STD_LOGIC_VECTOR ( 31 downto 0 ); -- fq_fifo2048x16: 15
 --    wr_en : in STD_LOGIC;
 --    rd_en : in STD_LOGIC;
 --    dout : out STD_LOGIC_VECTOR ( 15 downto 0 );
 --    full : out STD_LOGIC;
 --    empty : out STD_LOGIC;
 --    rd_data_count : out STD_LOGIC_VECTOR ( 11 downto 0 ) -- fq_fifo2048x16: data_count
 --    );
 -- end component fq_fifo2048x32to16;
 -- 03/08/2023
 component fq_fifo2048x32 is
  port (
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    data_count : out STD_LOGIC_VECTOR ( 11 downto 0 )
    );
 end component fq_fifo2048x32;

 signal header_fifo_data_count : std_logic_vector ( 5 downto 0 ); -- !debug: 03/08/2023  was 6
 signal fq_fifo2048x16_data_count : std_logic_vector ( 11 downto 0 );
 signal header_ready, header_ready_r, fq_data_ready, reading_mux_start, reading_mux_start_r : boolean;
 signal calc_data_ready : unsigned(11 downto 0) := (others => '0');
 signal header_fifo_rd_en, fq_fifo2048x16_rd_en : std_logic;
 signal header_fifo_dout, fq_fifo2048x16_dout : std_logic_vector (WORD_WIDTH-1 downto 0);
 signal reading_words_cnt : natural range 0 to 4095;
 signal header_fifo_empty, fq_fifo2048x16_empty : std_logic;
 signal mux_sel, mux_sel_r0, mux_sel_r1 : std_logic;

 signal header_fifo_wr_cnt : natural range 0 to 255; -- for simulation only
 signal fq_fifo_wr_cnt : natural range 0 to 4095; -- for simulation only


 -- signal header_fifo_wr_en : std_logic;
 signal srst, fq_fifo2048x16_srst : std_logic; -- clear each IP
 signal fq_data_valid_r : std_logic;

 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of header_fifo_data_count, fq_fifo2048x16_data_count : signal is "true";
 attribute mark_debug                    : string;
 attribute mark_debug of header_fifo_data_count, fq_fifo2048x16_data_count : signal is "true";

begin  -- architecture ar


  -- header from RX @400MHz -> fifo.din = RX_series7.RX_det_o[7..0], fifo.wr_en = RX_series7.data_valid
  -- header_fifo -> header_fifo_dout32
  header_fifo_1 : header_fifo_dout32
    port map (
      clk   => sys_clk,
      srst   => srst,
      din   => tmb_header,              -- TMB Header
      wr_en => tmb_header_valid,        -- option: header_fifo_wr_en
      rd_en => header_fifo_rd_en,
      dout  => header_fifo_dout,                    -- !TODO: connect to MUX
      full  => open,
      empty => header_fifo_empty,
      rd_data_count => header_fifo_data_count
      );


  -- !debug: 26/07/2023 fq_fifo2048x16 -> fq_fifo2048x32to16 -> fq_fifo2048x32
  fq_fifo2048x16_1 : fq_fifo2048x32
    port map (
      clk   => sys_clk,
      srst   => fq_fifo2048x16_srst,    -- !debug: 02/07/2023
      din   => fq_data_in,
      wr_en => fq_data_valid,
      rd_en => fq_fifo2048x16_rd_en,
      dout  => fq_fifo2048x16_dout, -- !TODO: connect to MUX
      full  => open,
      empty => fq_fifo2048x16_empty,
      data_count => fq_fifo2048x16_data_count
      );


  reading_mux_pr: process (sys_clk, rst_n) is
  begin  -- process reading_mux_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      header_ready <= FALSE;
      header_ready_r <= FALSE;
      fq_data_ready <= FALSE;
      reading_mux_start <= FALSE;
      reading_mux_start_r <= FALSE;
      reading_words_cnt <= 0;
      mux_sel <= '0';
      mux_sel_r0 <= '0';
      mux_sel_r1 <= '0';
      header_fifo_rd_en <= '0';
      fq_fifo2048x16_rd_en <= '0';
      srst <= '1';
      header_fifo_wr_cnt <= 0;
      fq_fifo_wr_cnt <= 0;
      calc_data_ready <= (10 => '1', others => '0');
      fq_fifo2048x16_srst <= '0';
      fq_data_valid_r <= '0';
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      srst <= IP50;
      if (not fq_data_ready) then       -- !debug: 02/07/2023 clear FIFO only in case, if wrong reading size
        fq_fifo2048x16_srst <= IP50;
      else
        fq_fifo2048x16_srst <= '0';
      end if;


      header_ready <= (header_fifo_data_count = 6UX"20"); -- 0x20*4=128 bytes scan header  !debug: 03/08/2023  was  7UX"40"
      header_ready_r <= header_ready;

      if (fq_data_valid_r = '0' and fq_data_valid = '1') then -- !debug: 24/07/2023 wait, because Num_of_Slices from scan header, header valid for _previous_ reading
        calc_data_ready <= unsigned(Num_of_Slices) & "00000"; -- ex: for 64 slices = 2048
      end if;
      fq_data_ready <= (unsigned(fq_fifo2048x16_data_count) = resize(calc_data_ready,fq_fifo2048x16_data_count'length)); -- read 2x faster, then write
                                                                                                                         -- !debug: 26/07/2023 for data delay by IP: write data, then wait for header

      -- reading_mux_start <= header_ready and fq_fifo2048x16_data_count = X"010" ; -- !debug: 02/11/2022 was header_ready and fq_data_ready, now immediately, when some data written to fq_fifo2048x16
      -- reading_mux_start <= header_ready and not header_ready_r and fq_data_ready; -- !debug: 02/07/2023
      reading_mux_start <= header_ready and fq_fifo2048x16_data_count /= X"000"; -- !debug: 03/08/2023
      if (reading_mux_start and not reading_mux_start_r) then
        -- note: apply, if uses fq_data_ready
        -- assert (unsigned(fq_fifo2048x16_data_count) = resize(calc_data_ready,fq_fifo2048x16_data_count'length)) report "Wrong data count in FIFO" severity ERROR;
      end if;

      reading_mux_start_r <= reading_mux_start;
      if ((not reading_mux_start_r and reading_mux_start) or srst = '1') then
        reading_words_cnt <= 0;
      elsif (header_fifo_empty = '0' or fq_fifo2048x16_empty = '0') then
        if ((mem_buf_fifo_rd = '1') and reading_words_cnt < 4095) then -- !debug: 31/10/2022 check overflow
          reading_words_cnt <= reading_words_cnt + 1;
        end if;
      end if;

      if (reading_words_cnt < 31) then  -- !debug: 03/08/2023  was 63
        mux_sel <= '0';
      else
        mux_sel <= '1';
      end if;
      mux_sel_r0 <= mux_sel;                -- read latency = 1
      mux_sel_r1 <= mux_sel_r0;

      header_fifo_rd_en <= not mux_sel and mem_buf_fifo_rd;
      fq_fifo2048x16_rd_en <= mux_sel and mem_buf_fifo_rd;

      assert "not"((header_fifo_empty = '1' and header_fifo_rd_en = '1') or
                   (fq_fifo2048x16_empty = '1' and fq_fifo2048x16_rd_en = '1'))
        report "Try read from empty FIFO" severity ERROR;

      if (mux_sel_r0 = '0') then
        mem_buf_fifo_rdata <= header_fifo_dout;
      else
        mem_buf_fifo_rdata <= fq_fifo2048x16_dout;
      end if;

      if (srst = '1') then
        header_fifo_wr_cnt <= 0;
      elsif (tmb_header_valid = '1') then
        header_fifo_wr_cnt <= header_fifo_wr_cnt + 1;
      end if;

      if (srst = '1') then
        fq_fifo_wr_cnt <= 0;
      elsif (fq_data_valid = '1') then
        fq_fifo_wr_cnt <= fq_fifo_wr_cnt + 1;
      end if;

      fq_data_valid_r <= fq_data_valid;

    end if;
  end process reading_mux_pr;


  mem_buf_reading_ready <= '1' when (reading_mux_start_r) else '0';
  mem_buf_fifo_empty <= header_fifo_empty and fq_fifo2048x16_empty;

end architecture ar;
