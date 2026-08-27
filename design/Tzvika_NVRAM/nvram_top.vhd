
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
entity nvram_top is
    generic(
        G_IIC_CLKS_NUM : integer := 500; -- 100K with 50MHz clk
        G_TOUT : std_logic_vector(20 - 1 downto 0):= x"6D090" -- 10msec with 50MHz clk
    );
    port(
        CLK                 : in std_logic;
        RESET               : in std_logic;
        ------------------------------------
        REG1_ADDR          : in std_logic_vector(32 - 1 downto 0);
        REG2_WRITEDATA_OP  : in std_logic_vector(32 - 1 downto 0);
        REG3_READDATA      : out std_logic_vector(32 - 1 downto 0);
        REG4_STATUS        : out std_logic_vector(32 - 1 downto 0);
        ------------------------------------
        NVRAM_SDA           : inout std_logic;
        NVRAM_SCL           : inout std_logic;
        NVRAM_WP            : out std_logic
        ------------------------------------
--        NVRAM_BUSY          : out std_logic;
--        NVRAM_WR_FIFO_FULL  : out std_logic;
--        NVRAM_WR_FIFO_EMPTY : out std_logic;
--        NVRAM_WR_DONE       : out std_logic;
--        NVRAM_RD_DONE       : out std_logic


    );
end entity;
architecture nvram_top_arch of nvram_top is

    --------------------------------------------
    -- components:
    component I2C_TMOR IS
   GENERIC (
		G_IIC_CLKS_NUM : integer := 500 -- 100K with 50MHz clk
   );
   PORT( 
      E             : IN     std_logic_vector (1 DOWNTO 0); -- chip select represent slave hw number
      address       : IN     std_logic_vector (16 DOWNTO 0);
      clk           : IN     std_logic;
      data2write    : IN     std_logic_vector (15 DOWNTO 0);
      ena           : IN     std_logic;
      ena_wp        : IN     std_logic; -- represent write protect enable
      reset         : IN     std_logic;
      rw            : IN     std_logic;
      wp            : OUT    std_logic; -- write protect
      sda           : INOUT  std_logic; -- for multi master connection when data is '1' output will be 'z' and need to constrain pin with pull-up
      scl           : inout std_logic;
	  read_ready    : OUT    std_logic; -- when rising read data ready
	  rd_done       : out  std_logic;
	  wr_done       : out  std_logic;
	  WP_DONE       : out std_logic; -- added by Tzvika Sweetkin 10/08/2023
      data2read_out : OUT    std_logic_vector (15 DOWNTO 0)
   );
   end component;
    --------------------------------------------
    component nvram_fetch_sm is
        generic(
            G_TOUT : std_logic_vector(20 - 1 downto 0):= x"3D090" -- 5msec with 50MHz clk
        );
        port(
            CLK                 : in std_logic;
            RESET               : in std_logic;
            ------------------------------------
             REGS_DATA          : in std_logic_vector(32 - 1 downto 0);
             REGS_ADDR          : in std_logic_vector(32 - 1 downto 0);
            ------------------------------------
             NVRAM_DATA          : out std_logic_vector(16 - 1 downto 0);
             NVRAM_ADDR          : out std_logic_vector(17 - 1 downto 0);
             NVRAM_RD_WRn        : out std_logic;
             NVRAM_ENABLE        : out std_logic;
            ------------------------------------
    
            IIC_WR_DONE         : in std_logic;
            IIC_RD_DONE         : in std_logic;
            ------------------------------------
            FIFO_FULL       : in std_logic;
            FIFO_EMPTY      : in std_logic;
            FIFO_RD_EN      : out std_logic;
            FIFO_RD_DATA    : in std_logic_vector(64 -1 downto 0);
            FIFO_WR_EN      : out std_logic;
            FIFO_WR_DATA      : out std_logic_vector(64 -1 downto 0);
            FIFO_DATA_COUNT   :in std_logic_vector(7 downto 0);
            ------------------------------------
            REG_STATUS      : out std_logic_vector(32 -1 downto 0)
    --        NVRAM_BUSY          : out std_logic;
    --        NVRAM_WR_FIFO_FULL  : out std_logic;
    --        NVRAM_WR_FIFO_EMPTY : out std_logic;
    --        NVRAM_WR_DONE       : out std_logic;
    --        NVRAM_RD_DONE       : out std_logic
    
    
        );
    end component;
    --------------------------------------------
    component fifo_nvram_instruction_64 IS
      PORT (
        clk : IN STD_LOGIC;
        srst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC;
        data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END component;

    --------------------------------------------
    --------------------------------------------
    -- types:
    --------------------------------------------
    -- signals:
    --------------------------------------------
    signal iic_address_sig      : std_logic_vector(16 downto 0):= (others => '0');
    signal iic_write_data_sig   : std_logic_vector(15 downto 0):= (others => '0');
    signal iic_enable_sig       : std_logic:= '0';
    signal iic_rd_wrn_sig       : std_logic:= '0';
    signal iic_read_ready_sig   : std_logic:= '0';
    signal iic_wr_done_sig      : std_logic:= '0';
    signal iic_rd_done_sig      : std_logic:= '0';
    
    --------------------------------------------
    signal fifo_full_sig        : std_logic:= '0';
    signal fifo_empty_sig       : std_logic:= '0';
    signal fifo_rd_en_sig       : std_logic:= '0';
    signal fifo_rd_data_sig     : std_logic_vector(63 downto 0):= (others => '0');
    signal fifo_wr_en_sig       : std_logic:= '0';
    signal fifo_wr_data_sig     : std_logic_vector(63 downto 0):= (others => '0');
    signal fifo_data_count_sig  : std_logic_vector(7 downto 0);
    --------------------------------------------
    --------------------------------------------
    --------------------------------------------
begin
    --------------------------------------------
    iic_inst:component I2C_TMOR 
    GENERIC map(
         G_IIC_CLKS_NUM => G_IIC_CLKS_NUM -- 100K with 50MHz clk
    )
    PORT map( 
       E                => "00"           , -- chip select represent slave hw number
       address          => iic_address_sig      ,
       clk              => CLK                  ,
       data2write       => iic_write_data_sig   ,
       ena              => iic_enable_sig       ,
       ena_wp           => '1'                  , -- enable write protect for flash
       reset            => RESET                ,
       rw               => iic_rd_wrn_sig       ,
       wp               => NVRAM_WP             , -- write protect
       sda              => NVRAM_SDA            , -- for multi master connection when data is '1' output will be 'z' and need to constrain pin with pull-up
       scl              => NVRAM_SCL            ,
       read_ready       => iic_read_ready_sig   , -- when rising read data ready
       rd_done          => iic_rd_done_sig,
       wr_done          => open,
       WP_DONE          => iic_wr_done_sig,
       data2read_out    => REG3_READDATA(15 downto 0)    
    );

    --------------------------------------------
    nvram_fetch_sm_inst:component nvram_fetch_sm 
        generic map (
            G_TOUT =>  G_TOUT -- 5msec with 50MHz clk
        )
        port map(
            CLK                 => CLK                  ,
            RESET               => RESET                ,
            ------------------------------------
            REGS_DATA     => REG2_WRITEDATA_OP   ,
            REGS_ADDR          => REG1_ADDR   ,
            ------------------------------------
            NVRAM_DATA          => iic_write_data_sig,
            NVRAM_ADDR          => iic_address_sig,
            NVRAM_RD_WRn        => iic_rd_wrn_sig,
            NVRAM_ENABLE        => iic_enable_sig,
            ------------------------------------
    
            IIC_WR_DONE         => iic_wr_done_sig      ,
            IIC_RD_DONE         => iic_rd_done_sig      ,
            ------------------------------------
            FIFO_FULL           => fifo_full_sig        ,
            FIFO_EMPTY          => fifo_empty_sig       ,
            FIFO_RD_EN          => fifo_rd_en_sig       ,
            FIFO_RD_DATA        => fifo_rd_data_sig     ,
            FIFO_WR_EN          => fifo_wr_en_sig       ,
            FIFO_WR_DATA        => fifo_wr_data_sig     ,
            FIFO_DATA_COUNT     => fifo_data_count_sig ,
            ------------------------------------
            REG_STATUS          => REG4_STATUS           
    
    
    
        );


     inst_nvram_fifo:component fifo_nvram_instruction_64 
      PORT map (
        clk => CLK,
        srst => RESET,
        din   => fifo_wr_data_sig,
        wr_en => fifo_wr_en_sig,
        rd_en => fifo_rd_en_sig,
        dout  => fifo_rd_data_sig,
        full  => fifo_full_sig,
        empty => fifo_empty_sig,
        data_count => fifo_data_count_sig
      );
    --------------------------------------------

end architecture;
