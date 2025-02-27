-------------------------------------------------------------------------------
-- Title      : DDR3 driver top
-- Project    : Trident
-------------------------------------------------------------------------------
-- File       : ddr_driver.vhd
-- Author     : <Shinderman Eugene  <evgene@hbtech.co.il>>
-- Company    :
-- Created    : 25/09/2005
-- Last update: 19/08/2024
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 25/09/2005  1.0      ilq00431  Created
-- 01/12/2016 patches for support DDR3 in sCT1 project
-- 22/12/2019 new version for Trident module
-------------------------------------------------------------------------------
-- - !debug: review global signals
--   m00_axi_aclk <= ui_clk; -- user clock from DDR3 IP
--   m00_axi_aresetn - reset from AXI interface
--   sys_rst_n - system reset
--   DDR3_AXI_IF.aresetn - !TODO: check if  m00_axi_aresetn is OK
--   ui_clk_sync_rst - active-High reset from DDR3 IP
--   DDR3_AXI_IF.sys_rst - !TODO: check if must be used
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

Library xpm;
use xpm.vcomponents.all;

use work.tbuf_pack.all;


entity ddr_driver is
  port(
    global_reset_n             	: in    std_logic; -- reset for AXI4 subsystem
    reset_sys_clk              	: in    std_logic; -- reset for system clock domain
    DDR3_SOFT_RESET_N           : in     std_logic; -- uses in Altera DDR3 IP  !TODO: 08/06/2023 check, if connect to DDR3_AXI_IF.sys_rst asynchronous
    CLK_50Mhz    : in  std_logic;  -- from/to registers, controls
                                        -- !TODO: 08/06/2023 for Taichi WR/RD data, registers all on sys_clk -> rename SYSTEM_CLK64_I,CLK_40M to CLK_50Mhz
    -- sys_clk_i         : in  std_logic;  -- 14/09/2022 DDR3 sys_clk
    -- clk_ref_i         : in  std_logic;  -- 14/09/2022 DDR3 clk_ref
    sys_clk_p           : in    std_logic; -- 19/09/2022 DDR3 sys_clk
    sys_clk_n           : in    std_logic; -- 19/09/2022 DDR3 sys_clk
    ui_clk_o          : out std_logic;  -- 14/09/2022 DDR3 ui_clk
    ui_clk_sync_rst_o : out std_logic;  -- active-High DDR3 UI reset

    IP50                : in std_logic; -- 22/10/2023
    -- Requests interface
    rq_cmds : in std_logic_vector (1 downto 0); -- 23/07/2023 [0] - RD, [1] - EV('0')/REGULAR('1')
    rq_rd_ptr : in std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0); -- absolute RD pointer

    -- RAW and EV data input
    DATA_SORTER_DATA_EN         : in std_logic;                       -- sorter data strobe
    DATA_SORT_DOUT              : in std_logic_vector (31 downto 0);  -- RAW data
    EVOLVING_DATA_EN            : in std_logic;
    -- EVOLVING_PRE_FRAME_START    : in std_logic;                       -- in Reading
    EVOLVING_DOUT               : in std_logic_vector (31 downto 0);  -- EV data

    params_ready       : in std_logic_vector(1 downto 0);  -- 22/10/2023 FQ & EV
    tmb_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
    tmb_header_rd : out std_logic;
    ev_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
    ev_header_rd : out std_logic;
    raw_wr_ptr_addr : in DDR3_ADDR_BUS_TYP;  -- !debug: 16/07/2023 was wr_ptr_num (WR reading index)
    ev_wr_slot_addr : in DDR3_ADDR_BUS_TYP;
    num_of_slices_no_merge : in std_logic_vector (6 downto 0); -- !debug: 08/02/2023 was [7..0]
    num_of_slices_after_merge : in std_logic_vector(6 downto 0); -- 03/10/2023 must be even

    -- DDR driver (buffers) registers inputs
    NO_ECC_CHK  				: in  std_logic; -- 06/11/2018
    FPGA_ID                     : in  std_logic_vector (3 downto 0);   --TBUF_R_L & FPGA_ID_I
    UNIQ_ID                     : in  std_logic_vector (15 downto 0);	-- unique ID  11/01/2018 Aron
    ASSEMBLY_VERSION : in  std_logic_vector(15 downto 0);
    INIT_DONE_A_O    : out std_logic;
    READ_DATA_FSM_IDLE          : buffer std_logic;
    diag_sel : in std_logic_vector(2 downto 0);                     -- 29/10/2023

    -- READ block <-> packet builder:
    DDR_DRIVER_RD               : in  std_logic;  -- from taichi_slice_builder.rx_fifo_rd: request next 16bit word from FIFO
    DDR_DRIVER_FIFO_EMPTY      	: out std_logic;  -- to taichi_slice_builder.rx_fifo_empty
    DDR_DRIVER_DOUT            	: out std_logic_vector (31 downto 0);  -- to taichi_slice_builder.rx_det: data from FIFO
    DDR_DRIVER_RD_READY         : out std_logic; -- !TODO: 11/07/2023 update driver to taichi_slice_builder.rd_reading_ready
    DDR_DRIVER_RD_VALID         : out std_logic; -- indicate DDR3 data valid
    DDR_DRIVER_HEADER_BUS      	: out std_logic_vector (32*HEADER_NUM_DWORDS - 1 downto 0);
    DDR_DRIVER_HEADER_READY     : out std_logic; -- 19/03/2017
    MEM_BUF_NUM_OF_SLICES       : out std_logic_vector(6 downto 0); -- 21/04/2024  (No of Slices in diagram)
    NEW_PACKET2TX               : out std_logic; -- 28/05/2024 (NewP in diagram)
    ECC_ERROR                  	: out std_logic;
    RTL_buffer_free_size        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 08/10/2023
    RTL_buffer_OverRun          : OUT STD_LOGIC;
    HD_buffer_free_size         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    HD_buffer_OverRun           : OUT STD_LOGIC;
    OverRun_RTL_reset_flag      : IN  STD_LOGIC;
    OverRun_HD_reset_flag       : IN  STD_LOGIC;
    ddr_driver_errors           : out std_logic_vector (31 DOWNTO 0); -- 06/06/2024
  --  Min_reading_gap_reg         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);  --add by Dalit 18/12/2023
  --  Min_reading_pointer_gap_reg : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);  --add by  Dalit 18/12/2023
  --  RTL_buffer_deep	            : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0); --add by  Dalit 19/12/2023
  --  HD_buffer_deep	            : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0); --add by  Dalit 19/12/2023

    -- DDR interface external pins
    ddr3_dq				: inout std_logic_vector (7 downto 0);
	ddr3_dqs_n			: inout std_logic_vector (0 to 0);
	ddr3_dqs_p			: inout std_logic_vector (0 to 0);
	ddr3_addr			: out	std_logic_vector (15 downto 0);
	ddr3_ba				: out	std_logic_vector (2 downto 0);
	ddr3_ras_n			: out	std_logic;
	ddr3_cas_n			: out	std_logic;
	ddr3_we_n			: out	std_logic;
	ddr3_reset_n		: out	std_logic;
	ddr3_ck_p			: out	std_logic_vector (0 to 0);
	ddr3_ck_n			: out	std_logic_vector (0 to 0);
	ddr3_cke			: out	std_logic_vector (0 to 0);
	ddr3_cs_n			: out	std_logic_vector (0 to 0);
	ddr3_dm				: out	std_logic_vector (0 to 0);
	ddr3_odt			: out	std_logic_vector (0 to 0);

    -- TB signals
    DDR_DRIVER_TESTPOINTS   	: out   std_logic_vector (31 downto 0)
  );

end ddr_driver;


architecture struct of ddr_driver is

  signal RAW_DATA_END_ADDR          : DDR3_ADDR_BUS_TYP;

  component data_sort_ddr3_wr
    port (
      RESET_I                : in  std_logic;
      ddr3_if_rst_n          : in  std_logic;
      CLK_50Mhz              : in  std_logic;
      ui_clk                 : in std_logic; -- DDR3 clock domain
      -- TOP_CLK_MEM_128M    : in std_logic; -- DDR3 clock domain
      -- clk20               : in std_logic;
      RAW_DATA_END_ADDR	          : in  DDR3_ADDR_BUS_TYP;

      INIT_DONE_ALL_O             : in  std_logic;
      IP50                : in std_logic; -- 22/10/2023

      DATA_SORT_DOUT              : in  std_logic_vector (31 downto 0);
      DATA_SORTER_DATA_EN         : in  std_logic;

      params_ready : in std_logic;  -- 20/09/2022
      tmb_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
      tmb_header_rd : out std_logic;
      raw_wr_ptr_addr : in DDR3_ADDR_BUS_TYP;  -- !debug: 16/07/2023 was wr_ptr_num (WR reading index)
      num_of_slices : in std_logic_vector (6 downto 0); -- !debug: 08/02/2023 was [7..0]

      RAW_FIFO_OVERFLOW           : out std_logic;  -- A,B or ECC FIFO in overflow state, wrfull='1'
      RAW_READING_ADDR_FIFO_ADDR  : out DDR3_ADDR_BUS_TYP;  -- same as internal counter
      RAW_READING_RAW_DATA_ADDR   : out DDR3_ADDR_BUS_TYP;  -- raw_data_addr, when PUSH2ADDR_FIFO
      RAW_FSM_ERROR               : out std_logic;  -- FSM timeout
      RAW_FIFO_NOTEMPTY           : out std_logic;
      RAW_POINTER_ERROR           : out std_logic;
      RAW_WR_ADDR_ERROR_O         : out std_logic;
      RAW_WR_BURST_INCOMPLETE     : out std_logic;
      RAW_BAD_PACKET_SIZE         : out std_logic;

      start_write        : out std_logic;
      burst_len          : out std_logic_vector(7 downto 0);
      fifo_axi_wdata     : out std_logic_vector(31 downto 0);
      fifo_wdata_valid   : out std_logic;
      waddr_offset       : out std_logic_vector(29 downto 0);
      fifo_rd_en         : in  std_logic;
      master_axi_state   : in  std_logic_vector(7 downto 0);  -- master_axi_state(1) - write in process (busy)
      axi_if_req         : out std_logic;                     -- 14/01/2020
      gnt_catch          : out std_logic;   -- 01/11/2023
      fifo_near_overflow : out std_logic;                     -- 04/07/2023

      RAW_WR_COUNTER              : out std_logic_vector(31 downto 0);
      DATA_SORT_2_DDR_TP          : out std_logic_vector (31 downto 0)
    );
  end component data_sort_ddr3_wr;


  component evolving_ddr3_wr
    port (
      RESET_I         : in std_logic;
      ddr3_if_rst_n   : in std_logic;
      CLK_50Mhz       : in std_logic;
      ui_clk          : in std_logic;
      -- Arbiter interface
      INIT_DONE_ALL_O : in std_logic;
      IP50                : in std_logic; -- 22/10/2023

      -- Data and strobe from evolving block
      EVOLVING_DOUT    : in std_logic_vector (31 downto 0);
      EVOLVING_DATA_EN : in std_logic;  -- data strobe from sorter
      -- EVOLVING_PRE_FRAME_START : in std_logic;       -- in Reading

      params_ready    : in  std_logic;  -- 20/09/2022
      tmb_header      : in  std_logic_vector (31 downto 0);  -- !debug: 20/09/2022
      tmb_header_rd   : out std_logic;
      ev_wr_slot_addr : in  DDR3_ADDR_BUS_TYP;  -- EV WR reading address
      num_of_slices   : in  std_logic_vector (6 downto 0);   -- !debug: 08/02/2023 was [7..0]

      EV_READING_EV_DATA_ADDR : out DDR3_ADDR_BUS_TYP;
      -- EV_READING_EV_SLOTNUM     : out EV_BUFFER_SLOTS_TYP; -- writen slots ptr
      EV_FSM_ERROR            : out std_logic;
      EV_FIFO_SPACE           : out std_logic_vector(8 downto 0);  -- available words in FIFO
      EV_FIFO_OVERFLOW        : out std_logic;
      EV_FIFO_NOTEMPTY        : out std_logic;
      EV_WR_COUNTER           : out std_logic_vector(31 downto 0);
      EV_ADDR_AREA_ERROR       : out std_logic;
      EV_WR_BURST_ERROR        : out std_logic;
      EV_WR_BAD_PACKET_SIZE    : out std_logic;

      -- AXI4 master interface:
      start_write      : out std_logic;
      burst_len        : out std_logic_vector(7 downto 0);
      fifo_axi_wdata   : out std_logic_vector(31 downto 0);
      fifo_wdata_valid : out std_logic;
      waddr_offset     : out std_logic_vector(29 downto 0);
      fifo_rd_en       : in  std_logic;
      master_axi_state : in  std_logic_vector(7 downto 0);  -- master_axi_state(1) - write in process (busy)
      axi_if_req       : out std_logic;                     -- 14/01/2020
      gnt_catch        : out std_logic;   -- 01/11/2023
      fifo_near_overflow  : out std_logic;   -- 04/07/2023 req. high priority from arbiter

      EVOLVING_DDR3_WR_TP : out std_logic_vector (31 downto 0)
      );
  end component evolving_ddr3_wr;


  component read_ddr3_rd
    port (
      RESET_I                     : in  std_logic;
      ddr3_if_rst_n               : in  std_logic;
      RESET_40                    : in  std_logic;
      CLK_50Mhz                   : in  std_logic;
      ui_clk                      : in  std_logic;
      RAW_DATA_END_ADDR		  : in  DDR3_ADDR_BUS_TYP;
      EVOLVING_REQ_PULSE          : in  std_logic;
      INIT_DONE_ALL_O             : in  std_logic;
      REGULAR_REQ_PULSE           : in  std_logic;  -- !check, new
      raw_rd_ptr_addr             : in DDR3_ADDR_BUS_TYP; -- absolute RD pointer
      ev_rd_slot_addr             : in DDR3_ADDR_BUS_TYP; -- absolute RD pointer
      READ_DATA_FSM_IDLE          : out std_logic;  -- read FSM in idle state
      NO_ECC_CHK                  : in  std_logic;

      axi_start_read		      : out std_logic;
	  axi_burst_len		          : out std_logic_vector(7 downto 0);
	  axi_raddr_offset	          : out std_logic_vector(29 downto 0);
	  axi_rdata	                  : in  std_logic_vector(31 downto 0);
	  axi_rdata_valid             : in  std_logic;
	  axi_master_state            : in  std_logic_vector(7 downto 0); -- axi_master_state(1) - write in process (busy)
      axi_if_req                  : out std_logic;                   -- 14/01/2020
      gnt_catch                   : out std_logic;   -- 01/11/2023

      READ_READING_ADDR_FIFO_ADDR : out DDR3_ADDR_BUS_TYP; -- same as internal counter
      READ_READING_RAW_DATA_ADDR  : out DDR3_ADDR_BUS_TYP; -- raw_data_addr, when not evolving_reading
      READ_READING_EV_DATA_ADDR   : out DDR3_ADDR_BUS_TYP; -- raw_data_addr, when evolving_reading
      READ_FSM_ERROR              : out std_logic;  -- FSM timeout
      -- READ_READING_EV_SLOTNUM     : out EV_BUFFER_SLOTS_TYP;
      READ_FIFO_NOTEMPTY          : out std_logic;  -- rdempty='0' and CENTRAL_INTERFACE_NEXT_REQ='1'
      READ_FIFO_OVERFLOW          : out std_logic;  -- A,B or ECC FIFO in overflow state, wrfull='1'
      READ_ECC_ERROR              : out std_logic;  -- ECC error
      ECC_ERROR_INTERNAL          : out boolean; -- output from ECC check
      ECC_DOUBLE_ERROR_INTERNAL   : out boolean; -- output from ECC check
      READ_ECC_ERROR_CHIPNUM      : out std_logic_vector(3 downto 0);
      READ_ECC_ERROR_ADDR         : out DDR3_ADDR_BUS_TYP;
      ECC_ERROR_INJECTION_CMD     : in  std_logic_vector(1 downto 0); -- 0,1,2 errors
      ECC_ERROR_MASK              : out std_logic_vector(6 downto 0);
      READ_FIFO_SPACE             : out std_logic_vector(10 downto 0);  -- available words in FIFO
      READ_POINTER_ERROR          : out std_logic;
      READ_BUFFER_ADDR_ERROR      : out std_logic;
      DDR_DRIVER_RD               : in  std_logic;
      DDR_DRIVER_DOUT             : out std_logic_vector (31 downto 0);
      DDR_DRIVER_FIFO_EMPTY       : out std_logic;
      DDR_DRIVER_RD_READY         : out std_logic; -- 15/01/2018
      DDR_DRIVER_RD_VALID         : out std_logic; -- indicate DDR3 data valid
      DDR_DRIVER_HEADER_BUS       : out std_logic_vector (32*HEADER_NUM_DWORDS - 1 downto 0);
      DDR_DRIVER_HEADER_READY     : out std_logic; -- 19/03/2017
      MEM_BUF_NUM_OF_SLICES       : out std_logic_vector(6 downto 0); -- 21/04/2024
      NEW_PACKET2TX               : out std_logic; -- 28/05/2024
      next_req_ready_M            : out std_logic; -- 16/07/2018
      RAW_RD_COUNTER              : out std_logic_vector(31 downto 0);
      EV_RD_COUNTER               : out std_logic_vector(31 downto 0);
      DDR_READ_TP                 : out std_logic_vector(15 downto 0)
    );
  end component read_ddr3_rd;

  signal EVOLVING_REQ_PULSE, REGULAR_REQ_PULSE : std_logic;
  signal raw_rd_ptr_addr, ev_rd_slot_addr : DDR3_ADDR_BUS_TYP; -- 13/07/2023

  signal DATA_SORT_2_DDR_TP         : std_logic_vector(31 downto 0);

  -- Buffer control and errors registers interface
  signal RAW_FIFO_OVERFLOW           : std_logic;  -- A,B or ECC FIFO in overflow state, wrfull='1'
  signal RAW_READING_ADDR_FIFO_ADDR  : DDR3_ADDR_BUS_TYP;  -- same as internal counter
  signal RAW_READING_RAW_DATA_ADDR   : DDR3_ADDR_BUS_TYP;  -- raw_data_addr, when PUSH2ADDR_FIFO
  signal RAW_FSM_ERROR               : std_logic;  -- FSM timeout
  signal RAW_FIFO_NOTEMPTY           : std_logic;
  signal RAW_POINTER_ERROR           : std_logic;
  signal RAW_WR_ADDR_ERROR_O         : std_logic;
  signal RAW_WR_BURST_INCOMPLETE     : std_logic;
  signal RAW_BAD_PACKET_SIZE         : std_logic;
  
  signal READ_FIFO_OVERFLOW          : std_logic;  -- A,B or ECC FIFO in overflow state, wrfull='1'
  signal READ_READING_ADDR_FIFO_ADDR : DDR3_ADDR_BUS_TYP;  -- same as internal counter
  signal READ_READING_RAW_DATA_ADDR  : DDR3_ADDR_BUS_TYP;  -- raw_data_addr, when
                                        -- ADDR_READ_WAIT and LOCAL_READ_DATA_VALID_A = '1'
  signal READ_FSM_ERROR              : std_logic;  -- FSM timeout
  signal READ_FIFO_NOTEMPTY          : std_logic;  -- rdempty='0' and CENTRAL_INTERFACE_NEXT_REQ='1'
  signal READ_ECC_ERROR              : std_logic;  -- ECC error
  signal READ_ECC_ERROR_CHIPNUM      : std_logic_vector(3 downto 0);
  signal READ_ECC_ERROR_ADDR         : DDR3_ADDR_BUS_TYP;

  signal READ_FIFO_SPACE             : std_logic_vector(10 downto 0);  -- available words in FIFO
  signal READ_POINTER_ERROR          : std_logic;
  signal READ_BUFFER_ADDR_ERROR      : std_logic;

  -- type   REQ_RRQ_STATE_TYP is (IDLE, INC_DEC_SAMPLED, REG_EV_SAMPLED, REG_EV_INC_DEC_PULSE);
  -- !TODO: 08/06/2023 update REQ_RRQ_STATE_TYP
  -- - receives from external interface:
  --   - DDR soft reset: set all related to DDR controls, FSM, RD/WR addresses to default
  --     this input can be alternative to soft reset register
  --   - write: WR (pointer incremented automatically)
  --   - read: RD + EV/REGULAR + pointer
  type REQ_RRQ_STATE_TYP is (IDLE_ST, WAIT2NEXT_RQ_ST, PTR2DEFAULT_ST, LOAD_CMD_ST, LOAD_PTR_ST, ERROR_ST, GO_ST);
  signal REQ_RRQ_STATE : REQ_RRQ_STATE_TYP;
  -- where:
  --  - not next_req_ready -> WAIT2NEXT_RQ_ST
  --  - DDR soft reset: rq_cmds[3] -> PTR2DEFAULT_ST - set WR/RD pointers to default address Q: what else to reset
  --  - WR, RD + EV/REGULAR rq_cmds[0], rq_cmds[1], rq_cmds[2] -> LOAD_CMD_ST
  --  - pointer -> LOAD_PTR_ST
  --  - sample cmd and pointer -> GO_ST
  --
  -- 08/06/2023 replaced dec_rrq_pulse, inc_rrq_pulse, evolving_req_pulse, regular_req_pulse
  --  - dec_rrq_pulse, inc_rrq_pulse -> rq_cmds[1]
  --  - evolving_req_pulse, regular_req_pulse -> rq_cmds[2]

  -- For EV block
  signal EVOLVING_DDR3_WR_TP :  std_logic_vector (31 downto 0);
  signal EV_READING_EV_DATA_ADDR : DDR3_ADDR_BUS_TYP;
  -- signal EV_READING_EV_SLOTNUM   : EV_BUFFER_SLOTS_TYP;           -- writen slots ptr
  -- signal READ_READING_EV_SLOTNUM : EV_BUFFER_SLOTS_TYP;
  signal READ_READING_EV_DATA_ADDR   : DDR3_ADDR_BUS_TYP;
  signal EV_FSM_ERROR            : std_logic;
  signal EV_FIFO_SPACE           : std_logic_vector(8 downto 0);  -- available words in FIFO
  signal EV_FIFO_OVERFLOW        : std_logic;
  signal EV_BUFFER_UNDERFLOW     : std_logic;
  signal EV_FIFO_NOTEMPTY        : std_logic;
  signal EV_ADDR_AREA_ERROR      : std_logic;
  signal EV_WR_BURST_ERROR		 : std_logic;
  signal EV_WR_BAD_PACKET_SIZE	 : std_logic;

  signal ECC_ERROR_INTERNAL          : boolean; -- output from ECC check
  signal ECC_DOUBLE_ERROR_INTERNAL   : boolean; -- output from ECC check
  signal ECC_ERROR_INJECTION_CMD     : std_logic_vector(1 downto 0); -- 0,1,2 errors
  signal ECC_ERROR_MASK              : std_logic_vector(6 downto 0);

  -- Test counters (check reading number)
  signal RAW_WR_COUNTER : std_logic_vector(31 downto 0);
  signal EV_WR_COUNTER  : std_logic_vector(31 downto 0);
  signal RAW_RD_COUNTER : std_logic_vector(31 downto 0);
  signal EV_RD_COUNTER  : std_logic_vector(31 downto 0);

  signal ddr3_if_rst_n           : std_logic; -- 01/12/2016

  signal next_req_ready_M        : std_logic; -- 16/07/2018

  -- 22/12/2019 Trident code
    component axi4_master_vhdl_0 is
    port (
      -- User ports
      -- !debug: 16/12/2019
      start_write		    : in std_logic; -- 15/12/2019 reading ready for write to DDR3 buffer pulse
      start_read		    : in std_logic; -- 15/12/2019 reading request from DDR3 buffer pulse
      write_burst_len   : in std_logic_vector(7 downto 0);
      read_burst_len    : in std_logic_vector(7 downto 0);
      fifo_axi_wdata	  : in std_logic_vector(31 downto 0);
      fifo_wdata_valid	: in std_logic;
      waddr_offset	    : in std_logic_vector(29 downto 0);
      raddr_offset	    : in std_logic_vector(29 downto 0);
      fifo_rd_en        : out std_logic;
      master_axi_state  : out std_logic_vector(7 downto 0);         -- 14/01/2020 ,grantRD,grantFQ,grantEV,,RD,WR,IDLE
      axi_if_req	   : in std_logic_vector(2 downto 0);          -- 14/01/2020 EV,FQ,RD
      gnt_catch            : in std_logic_vector(2 downto 0);   -- 01/11/2023

      m00_axi_awid         : out std_logic_vector(3 downto 0);      -- axi4_master_vhdl_0 3 -> 4
      m00_axi_awaddr       : out std_logic_vector(29 downto 0);     -- axi4_master_vhdl_0 32 -> 30
      m00_axi_awlen        : out std_logic_vector(7 downto 0);
      m00_axi_awsize       : out std_logic_vector(2 downto 0);
      m00_axi_awburst      : out std_logic_vector(1 downto 0);
      m00_axi_awlock       : out std_logic;
      m00_axi_awcache      : out std_logic_vector(3 downto 0);
      m00_axi_awprot       : out std_logic_vector(2 downto 0);
      m00_axi_awqos        : out std_logic_vector(3 downto 0);
      m00_axi_awuser       : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_awvalid      : out std_logic;
      m00_axi_awready      : in  std_logic;
      m00_axi_wdata        : out std_logic_vector(31 downto 0);
      m00_axi_wstrb        : out std_logic_vector(3 downto 0);
      m00_axi_wlast        : out std_logic;
      m00_axi_wuser        : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_wvalid       : out std_logic;
      m00_axi_wready       : in  std_logic;
      m00_axi_bid          : in  std_logic_vector(3 downto 0);      -- axi4_master_vhdl_0 3 -> 4
      m00_axi_bresp        : in  std_logic_vector(1 downto 0);
      m00_axi_buser        : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_bvalid       : in  std_logic;
      m00_axi_bready       : out std_logic;
      m00_axi_arid         : out std_logic_vector(3 downto 0);      -- axi4_master_vhdl_0 3 -> 4
      m00_axi_araddr       : out std_logic_vector(29 downto 0);     -- -- axi4_master_vhdl_0 32 -> 30
      m00_axi_arlen        : out std_logic_vector(7 downto 0);
      m00_axi_arsize       : out std_logic_vector(2 downto 0);
      m00_axi_arburst      : out std_logic_vector(1 downto 0);
      m00_axi_arlock       : out std_logic;
      m00_axi_arcache      : out std_logic_vector(3 downto 0);
      m00_axi_arprot       : out std_logic_vector(2 downto 0);
      m00_axi_arqos        : out std_logic_vector(3 downto 0);
      m00_axi_aruser       : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_arvalid      : out std_logic;
      m00_axi_arready      : in  std_logic;
      m00_axi_rid          : in  std_logic_vector(3 downto 0);      -- axi4_master_vhdl_0 3 -> 4
      m00_axi_rdata        : in  std_logic_vector(31 downto 0);
      m00_axi_rresp        : in  std_logic_vector(1 downto 0);
      m00_axi_rlast        : in  std_logic;
      m00_axi_ruser        : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_rvalid       : in  std_logic;
      m00_axi_rready       : out std_logic;
      m00_axi_aclk         : in  std_logic;
      m00_axi_aresetn      : in  std_logic;
      m00_axi_init_axi_txn : in  std_logic;
      m00_axi_txn_done     : out std_logic;
      m00_axi_error        : out std_logic);
  end component axi4_master_vhdl_0;

  -- component ports
  signal m00_axi_awid         : std_logic_vector(3 downto 0);
  signal m00_axi_awaddr       : std_logic_vector(29 downto 0);
  signal m00_axi_awlen        : std_logic_vector(7 downto 0);
  signal m00_axi_awsize       : std_logic_vector(2 downto 0);
  signal m00_axi_awburst      : std_logic_vector(1 downto 0);
  signal m00_axi_awlock       : std_logic;
  signal m00_axi_awcache      : std_logic_vector(3 downto 0);
  signal m00_axi_awprot       : std_logic_vector(2 downto 0);
  signal m00_axi_awqos        : std_logic_vector(3 downto 0);
  -- signal m00_axi_awuser       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_awvalid      : std_logic;
  signal m00_axi_awready      : std_logic;
  signal m00_axi_wdata        : std_logic_vector(31 downto 0);
  signal m00_axi_wstrb        : std_logic_vector(3 downto 0);
  signal m00_axi_wlast        : std_logic;
  -- signal m00_axi_wuser        : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_wvalid       : std_logic;
  signal m00_axi_wready       : std_logic;
  signal m00_axi_bid          : std_logic_vector(3 downto 0) := "0000";
  signal m00_axi_bresp        : std_logic_vector(1 downto 0) := "00";
  -- signal m00_axi_buser        : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  signal m00_axi_bvalid       : std_logic;
  signal m00_axi_bready       : std_logic;
  signal m00_axi_arid         : std_logic_vector(3 downto 0) := "0000";
  signal m00_axi_araddr       : std_logic_vector(29 downto 0);
  signal m00_axi_arlen        : std_logic_vector(7 downto 0);
  signal m00_axi_arsize       : std_logic_vector(2 downto 0);
  signal m00_axi_arburst      : std_logic_vector(1 downto 0);
  signal m00_axi_arlock       : std_logic;
  signal m00_axi_arcache      : std_logic_vector(3 downto 0);
  signal m00_axi_arprot       : std_logic_vector(2 downto 0);
  signal m00_axi_arqos        : std_logic_vector(3 downto 0);
  -- signal m00_axi_aruser       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_arvalid      : std_logic;
  signal m00_axi_arready      : std_logic;
  signal m00_axi_rid          : std_logic_vector(3 downto 0) := "0000";
  signal m00_axi_rdata        : std_logic_vector(31 downto 0);
  signal m00_axi_rresp        : std_logic_vector(1 downto 0);
  signal m00_axi_rlast        : std_logic;
  -- signal m00_axi_ruser        : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_rvalid       : std_logic;
  signal m00_axi_rready       : std_logic;
  signal m00_axi_init_axi_txn : std_logic := '0';
  signal m00_axi_txn_done     : std_logic;
  signal m00_axi_error        : std_logic;


  component DDR3_AXI_IF is
    port (
      ddr3_dq             : inout std_logic_vector (7 downto 0);
      ddr3_dqs_n          : inout std_logic_vector (0 to 0);
      ddr3_dqs_p          : inout std_logic_vector (0 to 0);
      ddr3_addr           : out   std_logic_vector (15 downto 0);
      ddr3_ba             : out   std_logic_vector (2 downto 0);
      ddr3_ras_n          : out   std_logic;
      ddr3_cas_n          : out   std_logic;
      ddr3_we_n           : out   std_logic;
      ddr3_reset_n        : out   std_logic;
      ddr3_ck_p           : out   std_logic_vector (0 to 0);
      ddr3_ck_n           : out   std_logic_vector (0 to 0);
      ddr3_cke            : out   std_logic_vector (0 to 0);
      ddr3_cs_n           : out   std_logic_vector (0 to 0);
      ddr3_dm             : out   std_logic_vector (0 to 0);
      ddr3_odt            : out   std_logic_vector (0 to 0);
      -- sys_clk_i           : in    std_logic;
      -- clk_ref_i           : in    std_logic;
      sys_clk_p           : in    std_logic;                       -- 19/09/2022
      sys_clk_n           : in    std_logic;                       -- 19/09/2022
      ui_clk              : out   std_logic;
      ui_clk_sync_rst     : out   std_logic;
      mmcm_locked         : out   std_logic;
      aresetn             : in    std_logic;
      app_sr_req          : in    std_logic;
      app_ref_req         : in    std_logic;
      app_zq_req          : in    std_logic;
      app_sr_active       : out   std_logic;
      app_ref_ack         : out   std_logic;
      app_zq_ack          : out   std_logic;
      s_axi_awid          : in    std_logic_vector (3 downto 0);
      s_axi_awaddr        : in    std_logic_vector (28 downto 0);  -- 19/09/2022 was [29..0]
      s_axi_awlen         : in    std_logic_vector (7 downto 0);
      s_axi_awsize        : in    std_logic_vector (2 downto 0);
      s_axi_awburst       : in    std_logic_vector (1 downto 0);
      s_axi_awlock        : in    std_logic_vector (0 to 0);
      s_axi_awcache       : in    std_logic_vector (3 downto 0);
      s_axi_awprot        : in    std_logic_vector (2 downto 0);
      s_axi_awqos         : in    std_logic_vector (3 downto 0);
      s_axi_awvalid       : in    std_logic;
      s_axi_awready       : out   std_logic;
      s_axi_wdata         : in    std_logic_vector (31 downto 0);
      s_axi_wstrb         : in    std_logic_vector (3 downto 0);
      s_axi_wlast         : in    std_logic;
      s_axi_wvalid        : in    std_logic;
      s_axi_wready        : out   std_logic;
      s_axi_bready        : in    std_logic;
      s_axi_bid           : out   std_logic_vector (3 downto 0);
      s_axi_bresp         : out   std_logic_vector (1 downto 0);
      s_axi_bvalid        : out   std_logic;
      s_axi_arid          : in    std_logic_vector (3 downto 0);
      s_axi_araddr        : in    std_logic_vector (28 downto 0);  -- 19/09/2022 was [29..0]
      s_axi_arlen         : in    std_logic_vector (7 downto 0);
      s_axi_arsize        : in    std_logic_vector (2 downto 0);
      s_axi_arburst       : in    std_logic_vector (1 downto 0);
      s_axi_arlock        : in    std_logic_vector (0 to 0);
      s_axi_arcache       : in    std_logic_vector (3 downto 0);
      s_axi_arprot        : in    std_logic_vector (2 downto 0);
      s_axi_arqos         : in    std_logic_vector (3 downto 0);
      s_axi_arvalid       : in    std_logic;
      s_axi_arready       : out   std_logic;
      s_axi_rready        : in    std_logic;
      s_axi_rid           : out   std_logic_vector (3 downto 0);
      s_axi_rdata         : out   std_logic_vector (31 downto 0);
      s_axi_rresp         : out   std_logic_vector (1 downto 0);
      s_axi_rlast         : out   std_logic;
      s_axi_rvalid        : out   std_logic;
      init_calib_complete : out   std_logic;
      device_temp         : out   std_logic_vector (11 downto 0);
      sys_rst             : in    std_logic);
  end component DDR3_AXI_IF;

  signal ui_clk          : std_logic;
  signal ui_clk_sync_rst : std_logic;
  signal mmcm_locked     : std_logic;

  signal init_calib_complete             : std_logic;

  signal start_write, raw_start_write, ev_start_write : std_logic;
  signal start_read, read_start_read	  : std_logic := '0';
  signal write_burst_len, raw_write_burst_len, ev_write_burst_len : std_logic_vector(7 downto 0);
  signal read_burst_len, read_read_burst_len	  : std_logic_vector(7 downto 0) := (others => '0');
  signal fifo_axi_wdata, raw_fifo_axi_wdata, ev_fifo_axi_wdata : std_logic_vector(31 downto 0);
  signal fifo_wdata_valid, raw_fifo_wdata_valid, ev_fifo_wdata_valid : std_logic;
  -- signal axi_rdata	      : std_logic_vector(31 downto 0);
  signal axi_rdata_valid  : std_logic;
  signal waddr_offset, raw_waddr_offset, ev_waddr_offset : std_logic_vector(29 downto 0);
  signal raddr_offset, read_raddr_offset  : std_logic_vector(29 downto 0) := (others => '0');
  signal fifo_rd_en, raw_fifo_rd_en, ev_fifo_rd_en : std_logic;
  signal master_axi_state : std_logic_vector(7 downto 0);
  signal axi_if_req, axi_if_req_masked, test_axi_if_req, req_vector_mask, gnt_catch : std_logic_vector(2 downto 0) := "000"; -- 14/01/2020 EV,FQ,RD

  -- signal fq_ev_sel : boolean;

  -- 09/02/2023 DDR3 test

  component dcfifo_512x32 is
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector (31 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector (31 downto 0);
      full          : out std_logic;
      overflow      : out std_logic;
      empty         : out std_logic;
      valid         : out std_logic;
      underflow     : out std_logic;
      rd_data_count : out std_logic_vector (8 downto 0);
      wr_data_count : out std_logic_vector (8 downto 0));
  end component dcfifo_512x32;

  signal test_tile_wdata, test_fifo_axi_wdata : std_logic_vector(31 downto 0);
  signal test_data_en : std_logic;

  signal test_fifo_wr_en, test_fifo_rd_en, test_fifo_full, test_fifo_overflow, test_fifo_empty, test_fifo_wdata_valid, test_fifo_underflow : std_logic;
  -- signal test_fifo_write_cnt : natural range 0 to 511;
  signal test_fifo_wr_data_count, test_fifo_rd_data_count : std_logic_vector (8 downto 0);
  signal test_start_write, test_start_read : std_logic := '0';
  constant test_write_burst_len, test_read_burst_len : std_logic_vector(7 downto 0) := X"20"; -- !debug: 09/02/2023 constant 32 words burst
  signal test_writes_done, test_reads_done, test_writes_done_pre, test_reads_done_pre : std_logic;
  signal test_waddr_offset, test_raddr_offset : std_logic_vector(29 downto 0);

  signal expected_rdata, test_rdata_r	: std_logic_vector(31 downto 0) := (others => '0');
  signal valid_ready_sampled : boolean := FALSE; -- 08/01/2020
  signal read_mismatch	: std_logic;

  signal rq_cmds_r : std_logic_vector (1 downto 0);

  signal raw_fifo_near_overflow, ev_fifo_near_overflow : std_logic;

  component xpm_cdc_single
    generic (
      -- Common module generics
      DEST_SYNC_FF   : integer := 4;
      INIT_SYNC_FF   : integer := 0;
      SIM_ASSERT_CHK : integer := 0;
      SRC_INPUT_REG  : integer := 1
      );
    port (
      src_clk  : in  std_logic;
      src_in   : in  std_logic;
      dest_clk : in  std_logic;
      dest_out : out std_logic
      );
  end component;

  component xpm_hand_simple is
    generic (SLOW2FAST : boolean;
             WIDTH     : integer);
    port (rst_n    : in  std_logic;
          slow_clk : in  std_logic;
          fast_clk : in  std_logic;
          src_in   : in  std_logic_vector(WIDTH-1 downto 0);
          dest_out : out std_logic_vector(WIDTH-1 downto 0));
  end component xpm_hand_simple;

  signal rq_rd_ptr_addr_dest : std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0);
  signal rq_cmds_dest : std_logic_vector (1 downto 0);
  signal global_reset_ui_clk : std_logic;

    component Buffer_Calculator_RTL is
      port (CLK                                          : IN  STD_LOGIC;
            RESET                                        : IN  STD_LOGIC;
            RTL_write_addr                               : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            RTL_read_addr                                : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        --    Min_reading_gap                              : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); --eadit by Dalit 18/12/2023
            OverRun_RTL_reset_flag                       : IN  STD_LOGIC;
            RTL_buffer_start_pointer                     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            RTL_buffer_end_pointer                       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            IP 			                                 : IN   STD_LOGIC; --add by  Dalit 13/12/2023
            RTL_buffer_free_size                         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            RTL_buffer_free_size_change                  : OUT   STD_LOGIC;  --add by  Dalit 6/12/2023
            RTL_buffer_OverRun                           : OUT STD_LOGIC
        --    RTL_buffer_deep	                             : OUT    STD_LOGIC_VECTOR(31 DOWNTO 0)	--add by  Dalit 19/12/2023
            );
    end component Buffer_Calculator_RTL;

  component Buffer_Calculator_HD is
    generic (MAX_buffer_size : integer);
    port (CLK                     : IN  STD_LOGIC;
          RESET                   : IN  STD_LOGIC;
          HD_write_addr           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          HD_read_addr            : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          HD_write_pointer        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          HD_read_pointer         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          HD_buffer_start_pointer : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          HD_buffer_end_pointer   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          OverRun_HD_reset_flag   : IN  STD_LOGIC;
          IP 			          : IN   STD_LOGIC;  --add by  Dalit 13/12/2023
      --    Min_reading_pointer_gap_reg : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);  --add by  Dalit 18/12/2023
          HD_buffer_free_size     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          HD_buffer_free_size_change : OUT   STD_LOGIC;  --add by  Dalit 6/12/2023
          HD_buffer_OverRun       : OUT STD_LOGIC
     --     HD_buffer_deep	      : OUT    STD_LOGIC_VECTOR(31 DOWNTO 0)	--add by  Dalit 19/12/2023
          );
  end component Buffer_Calculator_HD;

  signal RTL_buffer_free_size_ui_clk        : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 08/10/2023
  signal RTL_buffer_OverRun_ui_clk          : STD_LOGIC;
  signal HD_buffer_free_size_ui_clk         : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal HD_buffer_OverRun_ui_clk           : STD_LOGIC;

  signal OverRun_RTL_reset_flag_ui_clk      : STD_LOGIC;
  signal OverRun_HD_reset_flag_ui_clk       : STD_LOGIC;


  signal sel4axi : unsigned(1 downto 0);
  signal trig_in_sys_clk, trig_in_ui_clk : std_logic;

  type wr_data_states is (idle, header_counter_s, wait_for_send, send, wait_for_header_end); --add by Dalit 6/12/23
  signal HD_wr_data_fsm                       : wr_data_states; --add by Dalit 6/12/23
  signal HD_src_send_sig                      : std_logic; --add by Dalit 6/12/23
  signal HD_src_rcv_sig                       : std_logic; --add by Dalit 6/12/23
  signal HD_message_sync_sig                  : std_logic; --add by Dalit 6/12/23

  signal RTL_wr_data_fsm                       : wr_data_states; --add by Dalit 6/12/23
  signal RTL_src_send_sig                      : std_logic; --add by Dalit 6/12/23
  signal RTL_src_rcv_sig                       : std_logic; --add by Dalit 6/12/23
  signal RTL_message_sync_sig                  : std_logic; --add by Dalit 6/12/23
  signal IP_ui_clk                             : std_logic; --add by Dalit 13/12/23

  signal rq_cmds_r0 : std_logic_vector (1 downto 0); -- 23/07/2023 [0] - RD, [1] - EV('0')/REGULAR('1')

  signal rd_rq_buff_n0, rd_rq_buff_n1 : std_logic_vector(39 downto 0); -- [39] - rq_valid, [33] - HD, [32] - EV, [DDR3_ADDR_WIDTH-1..0] - address
  signal rd_rq_buff_error : std_logic;
  signal rq_cmds_buffered : std_logic_vector (1 downto 0); -- [0] - RD, [1] - EV('0')/REGULAR('1')
  signal rq_rd_ptr_buffered : std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0); -- absolute RD pointer
  signal slow2fast_wait_cnt : natural range 0 to 7;
  signal slow2fast_wait_completed, slow2fast_wait_completed_sys_clk : std_logic; -- 02/06/2024
  signal wait2next_rq_ui_clk, wait2next_rq_sys_clk : std_logic;
  signal rq_queue_error : std_logic;
  signal keep_request_cnt : natural range 0 to 7; -- !debug: 02/06/2024 7 -> 31
  signal OverRun_RTL_reset_flag_ff : std_logic_vector (4 downto 0):="00000"; -- dalit+Eugene 22/7/2024
  signal OverRun_RTL_reset_flag_wide : std_logic:='0'; -- dalit+Eugene 22/7/2024

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of EV_READING_EV_DATA_ADDR, READ_READING_EV_DATA_ADDR, RAW_READING_RAW_DATA_ADDR, READ_READING_RAW_DATA_ADDR,
    RAW_READING_ADDR_FIFO_ADDR, READ_READING_ADDR_FIFO_ADDR : signal is "true";
  attribute DONT_TOUCH of EV_FSM_ERROR, EV_FIFO_OVERFLOW, EV_FIFO_NOTEMPTY, RAW_FSM_ERROR, RAW_FIFO_NOTEMPTY, RAW_FIFO_OVERFLOW, sel4axi, start_write, fifo_wdata_valid : signal is "true";
  attribute DONT_TOUCH of trig_in_ui_clk, m00_axi_error : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of EV_READING_EV_DATA_ADDR, READ_READING_EV_DATA_ADDR, RAW_READING_RAW_DATA_ADDR, READ_READING_RAW_DATA_ADDR,
    RAW_READING_ADDR_FIFO_ADDR, READ_READING_ADDR_FIFO_ADDR : signal is "true";
  attribute mark_debug of EV_FSM_ERROR, EV_FIFO_OVERFLOW, EV_FIFO_NOTEMPTY, RAW_FSM_ERROR, RAW_FIFO_NOTEMPTY, RAW_FIFO_OVERFLOW, sel4axi, start_write, fifo_wdata_valid : signal is "true";
  attribute mark_debug of trig_in_ui_clk, m00_axi_error : signal is "true";


begin

  -- Instance port mappings.
  data_sort_ddr3_wr_1 : data_sort_ddr3_wr
    port map (
      RESET_I                     => reset_sys_clk,
      ddr3_if_rst_n               => ddr3_if_rst_n,
      CLK_50Mhz                   => CLK_50Mhz,
      ui_clk                      => ui_clk,
      RAW_DATA_END_ADDR           => RAW_DATA_END_ADDR,

      INIT_DONE_ALL_O             => init_calib_complete,
      IP50                        => IP50,       -- 22/10/2023

      DATA_SORT_DOUT              => DATA_SORT_DOUT,
      DATA_SORTER_DATA_EN         => DATA_SORTER_DATA_EN,
      params_ready                => params_ready(1), -- scan header, registers, controls ready for WR to DDR3
      tmb_header                  => tmb_header, -- scan header
      tmb_header_rd               => tmb_header_rd,
      raw_wr_ptr_addr             => raw_wr_ptr_addr,
      num_of_slices               => num_of_slices_no_merge,
      RAW_FIFO_OVERFLOW           => RAW_FIFO_OVERFLOW,
      RAW_READING_ADDR_FIFO_ADDR  => RAW_READING_ADDR_FIFO_ADDR,
      RAW_READING_RAW_DATA_ADDR   => RAW_READING_RAW_DATA_ADDR,
      RAW_FSM_ERROR               => RAW_FSM_ERROR,
      RAW_FIFO_NOTEMPTY           => RAW_FIFO_NOTEMPTY,
      RAW_POINTER_ERROR           => RAW_POINTER_ERROR, -- 09/06/2024
      RAW_WR_ADDR_ERROR_O         => RAW_WR_ADDR_ERROR_O,
      RAW_WR_BURST_INCOMPLETE     => RAW_WR_BURST_INCOMPLETE,
      RAW_BAD_PACKET_SIZE         => RAW_BAD_PACKET_SIZE,
      start_write                 => raw_start_write,
      burst_len                   => raw_write_burst_len,
      fifo_axi_wdata              => raw_fifo_axi_wdata,
      fifo_wdata_valid            => raw_fifo_wdata_valid,
      waddr_offset                => raw_waddr_offset,
      fifo_rd_en                  => raw_fifo_rd_en,
      master_axi_state            => master_axi_state,
      axi_if_req                  => axi_if_req(1),
      gnt_catch                   => gnt_catch(1), -- 01/11/2023
      fifo_near_overflow          => raw_fifo_near_overflow,
      RAW_WR_COUNTER              => RAW_WR_COUNTER, -- NU
      DATA_SORT_2_DDR_TP          => DATA_SORT_2_DDR_TP
    );


  evolving_ddr3_wr_1 : evolving_ddr3_wr
    port map (
      RESET_I        => reset_sys_clk,
      ddr3_if_rst_n  => ddr3_if_rst_n,
      CLK_50Mhz      => CLK_50Mhz,
      ui_clk         => ui_clk,
      INIT_DONE_ALL_O => init_calib_complete,
      IP50             => IP50,       -- 22/10/2023
      EVOLVING_DOUT    => EVOLVING_DOUT,
      EVOLVING_DATA_EN => EVOLVING_DATA_EN,
      params_ready    => params_ready(0),
      tmb_header      => ev_header,
      tmb_header_rd   => ev_header_rd,
      ev_wr_slot_addr => ev_wr_slot_addr,
      num_of_slices   => num_of_slices_after_merge,
      EV_READING_EV_DATA_ADDR => EV_READING_EV_DATA_ADDR,
      -- EV_READING_EV_SLOTNUM => EV_READING_EV_SLOTNUM,
      EV_FSM_ERROR            => EV_FSM_ERROR,
      EV_FIFO_SPACE           => EV_FIFO_SPACE,
      EV_FIFO_OVERFLOW        => EV_FIFO_OVERFLOW,
      EV_FIFO_NOTEMPTY        => EV_FIFO_NOTEMPTY,
      EV_WR_COUNTER           => EV_WR_COUNTER,
      EV_ADDR_AREA_ERROR      => EV_ADDR_AREA_ERROR, -- 09/06/2024
      EV_WR_BURST_ERROR       => EV_WR_BURST_ERROR,
      EV_WR_BAD_PACKET_SIZE   => EV_WR_BAD_PACKET_SIZE,
      start_write             => ev_start_write,
      burst_len               => ev_write_burst_len,
      fifo_axi_wdata          => ev_fifo_axi_wdata,
      fifo_wdata_valid        => ev_fifo_wdata_valid,
      waddr_offset            => ev_waddr_offset,
      fifo_rd_en              => ev_fifo_rd_en,
      master_axi_state        => master_axi_state,
      axi_if_req              => axi_if_req(2),
      gnt_catch               => gnt_catch(2), -- 01/11/2023
      fifo_near_overflow      => ev_fifo_near_overflow,
      EVOLVING_DDR3_WR_TP     => EVOLVING_DDR3_WR_TP
      );


  fq_ev_sel_pr: process (ui_clk, ddr3_if_rst_n) is
  begin  -- process fq_ev_sel_pr
    if (ddr3_if_rst_n = '0') then       -- asynchronous reset (active low)
      -- fq_ev_sel <= FALSE;
      req_vector_mask <= (others => '0');
      sel4axi <= "00";
    elsif (ui_clk'event and ui_clk = '1') then  -- rising clock edge

      -- -- if (master_axi_state(0) = '1') then -- switch when idle
      -- --   if (axi_if_req(2) = '1') then -- EV write priority
      -- --     fq_ev_sel <= TRUE;             -- EV
      -- --   elsif (axi_if_req(1) = '1') then
      -- --     fq_ev_sel <= FALSE;            -- FQ
      -- --   end if;
      -- -- end if;
      -- if (master_axi_state(4) = '1') then   -- EV write priority
      --   fq_ev_sel <= TRUE;             -- EV
      -- else
      --   fq_ev_sel <= FALSE;            -- FQ
      -- end if;

      assert not(master_axi_state(1) = '0' and fifo_wdata_valid = '1') report "Write FQ or EV data when AXI not in write" severity ERROR;
      assert not(master_axi_state(0) = '0' and start_write = '1') report "Write FQ or EV data when AXI not idle" severity ERROR;

      req_vector_mask(0) <= not (raw_fifo_near_overflow or ev_fifo_near_overflow); -- mask RD
      -- req_vector_mask(2 downto 1) <= "11";
      req_vector_mask(1) <= '1';
      req_vector_mask(2) <= not raw_fifo_near_overflow; -- 21/08/2023

      sel4axi <= UNIQ_ID(0) & master_axi_state(4);

    end if;
  end process fq_ev_sel_pr;

  axi_if_req_masked <= axi_if_req and req_vector_mask; -- 04/07/2023 mask RD request, if DDR3 WR FIFO near overflow

  -- MUX selector
  -- -- !debug: 09/02/2023 UNIQ_ID(0) for DDR3 test
  -- -- !TODO: 28/09/2023 replace UNIQ_ID with vio_0.ddr3_test_reg
  -- start_write <= test_start_write when (UNIQ_ID(0) = '1') else raw_start_write when (master_axi_state(4) = '0') else ev_start_write;
  -- write_burst_len <= test_write_burst_len when (UNIQ_ID(0) = '1') else raw_write_burst_len when (master_axi_state(4) = '0') else ev_write_burst_len;
  -- fifo_axi_wdata <= test_fifo_axi_wdata when (UNIQ_ID(0) = '1') else raw_fifo_axi_wdata when (master_axi_state(4) = '0') else ev_fifo_axi_wdata;
  -- fifo_wdata_valid <= test_fifo_wdata_valid when (UNIQ_ID(0) = '1') else raw_fifo_wdata_valid when (master_axi_state(4) = '0') else ev_fifo_wdata_valid;
  -- waddr_offset <= test_waddr_offset when (UNIQ_ID(0) = '1') else raw_waddr_offset when (master_axi_state(4) = '0') else ev_waddr_offset;
  -- raw_fifo_rd_en <= '0' when (UNIQ_ID(0) = '1') else fifo_rd_en when (master_axi_state(4) = '0') else '0';
  -- ev_fifo_rd_en <= '0' when (UNIQ_ID(0) = '1') else fifo_rd_en when (master_axi_state(4) = '1') else '0';
  -- start_read <= test_start_read when (UNIQ_ID(0) = '1') else read_start_read;
  -- read_burst_len <= test_read_burst_len when (UNIQ_ID(0) = '1') else read_read_burst_len;
  -- raddr_offset <= test_raddr_offset when (UNIQ_ID(0) = '1') else read_raddr_offset;
  -- test_fifo_rd_en <= fifo_rd_en when (master_axi_state(4) = '0') else '0';
  sel4axi_pr: process (all) is
  begin  -- process sel4axi_pr

    -- [1] - test block, [0] - '0' FQ, '1' EV
    case sel4axi is
      when "10" =>                      -- test interface
        start_write <= test_start_write;
        write_burst_len <= test_write_burst_len;
        fifo_axi_wdata <= test_fifo_axi_wdata;
        fifo_wdata_valid <= test_fifo_wdata_valid;
        waddr_offset <= test_waddr_offset;
        raw_fifo_rd_en <= '0';
        ev_fifo_rd_en <= '0';
        start_read <= test_start_read;
        read_burst_len <= test_read_burst_len;
        raddr_offset <= test_raddr_offset;
        test_fifo_rd_en <= fifo_rd_en;
      when "00" =>                      -- FQ interface
        start_write <= raw_start_write;
        write_burst_len <= raw_write_burst_len;
        fifo_axi_wdata <= raw_fifo_axi_wdata;
        fifo_wdata_valid <= raw_fifo_wdata_valid;
        waddr_offset <= raw_waddr_offset;
        raw_fifo_rd_en <= fifo_rd_en;
        ev_fifo_rd_en <= '0';
        start_read <= read_start_read;
        read_burst_len <= read_read_burst_len;
        raddr_offset <= read_raddr_offset;
        test_fifo_rd_en <= '0';
      when "01" =>                      -- EV interface
        start_write <= ev_start_write;
        write_burst_len <= ev_write_burst_len;
        fifo_axi_wdata <= ev_fifo_axi_wdata;
        fifo_wdata_valid <= ev_fifo_wdata_valid;
        waddr_offset <= ev_waddr_offset;
        raw_fifo_rd_en <= '0';
        ev_fifo_rd_en <= fifo_rd_en;
        start_read <= read_start_read;
        read_burst_len <= read_read_burst_len;
        raddr_offset <= read_raddr_offset;
        test_fifo_rd_en <= '0';
      when others => -- error
        start_write <= '0';
        write_burst_len <= (others => '0');
        fifo_axi_wdata <= (others => '0');
        fifo_wdata_valid <= '0';
        waddr_offset <= (others => '0');
        raw_fifo_rd_en <= '0';
        ev_fifo_rd_en <= '0';
        start_read <= '0';
        read_burst_len <= (others => '0');
        raddr_offset <= (others => '0');
        test_fifo_rd_en <= '0';
    end case;

  end process sel4axi_pr;


  read_ddr3_rd_1 : read_ddr3_rd
    port map (
      RESET_I                     => reset_sys_clk,
      ddr3_if_rst_n               => ddr3_if_rst_n,
      RESET_40                    => reset_sys_clk,
      CLK_50Mhz                   => CLK_50Mhz,
      ui_clk                      => ui_clk,
      INIT_DONE_ALL_O             => init_calib_complete,
      RAW_DATA_END_ADDR           => RAW_DATA_END_ADDR, -- 4Gb/8Gb chip select
      EVOLVING_REQ_PULSE          => EVOLVING_REQ_PULSE,
      REGULAR_REQ_PULSE           => REGULAR_REQ_PULSE,
      raw_rd_ptr_addr             => raw_rd_ptr_addr,
      ev_rd_slot_addr             => ev_rd_slot_addr,
      READ_DATA_FSM_IDLE          => READ_DATA_FSM_IDLE,
      NO_ECC_CHK                  => NO_ECC_CHK,
      axi_start_read              => read_start_read,
      axi_burst_len               => read_read_burst_len,
      axi_raddr_offset            => read_raddr_offset,
      axi_rdata                   => m00_axi_rdata,
      axi_rdata_valid             => axi_rdata_valid,
      axi_master_state            => master_axi_state,
      axi_if_req                  => axi_if_req(0),
      gnt_catch                   => gnt_catch(0), -- 01/11/2023
      READ_FIFO_OVERFLOW          => READ_FIFO_OVERFLOW,
      READ_READING_ADDR_FIFO_ADDR => READ_READING_ADDR_FIFO_ADDR,
      READ_READING_RAW_DATA_ADDR  => READ_READING_RAW_DATA_ADDR,
      READ_READING_EV_DATA_ADDR   => READ_READING_EV_DATA_ADDR,
      READ_FSM_ERROR              => READ_FSM_ERROR,
      -- READ_READING_EV_SLOTNUM     => READ_READING_EV_SLOTNUM,
      READ_FIFO_NOTEMPTY          => READ_FIFO_NOTEMPTY,
      READ_ECC_ERROR              => READ_ECC_ERROR,
      ECC_ERROR_INTERNAL          => ECC_ERROR_INTERNAL,
      ECC_DOUBLE_ERROR_INTERNAL   => ECC_DOUBLE_ERROR_INTERNAL,
      READ_ECC_ERROR_CHIPNUM      => READ_ECC_ERROR_CHIPNUM,
      READ_ECC_ERROR_ADDR         => READ_ECC_ERROR_ADDR,
      ECC_ERROR_INJECTION_CMD     => ECC_ERROR_INJECTION_CMD,
      ECC_ERROR_MASK              => ECC_ERROR_MASK,
      READ_FIFO_SPACE             => READ_FIFO_SPACE,
      READ_POINTER_ERROR          => READ_POINTER_ERROR, -- 09/06/2024
      READ_BUFFER_ADDR_ERROR      => READ_BUFFER_ADDR_ERROR,
      DDR_DRIVER_RD               => DDR_DRIVER_RD,
      DDR_DRIVER_DOUT             => DDR_DRIVER_DOUT,
      DDR_DRIVER_FIFO_EMPTY       => DDR_DRIVER_FIFO_EMPTY,
      DDR_DRIVER_RD_READY         => DDR_DRIVER_RD_READY,
      DDR_DRIVER_RD_VALID         => DDR_DRIVER_RD_VALID, -- 29/05/2024
      DDR_DRIVER_HEADER_BUS       => DDR_DRIVER_HEADER_BUS,
      DDR_DRIVER_HEADER_READY     => DDR_DRIVER_HEADER_READY,
      MEM_BUF_NUM_OF_SLICES       => MEM_BUF_NUM_OF_SLICES, -- 21/04/2024
      NEW_PACKET2TX               => NEW_PACKET2TX,         -- 28/05/2024
      next_req_ready_M            => next_req_ready_M,
      RAW_RD_COUNTER              => RAW_RD_COUNTER,
      EV_RD_COUNTER               => EV_RD_COUNTER,
      DDR_READ_TP                 => open
    );


  axi_rdata_valid <= m00_axi_rvalid and m00_axi_rready;


  sync_sys_clk_pr: process (CLK_50Mhz, reset_sys_clk) is
   -- variable merge_factor_v : std_logic_vector(4 downto 0) := 5UX"2"; -- merging 1:2
  begin  -- process sync_sys_clk_pr
    if reset_sys_clk = '0' then               -- asynchronous reset (active low)
      rq_cmds_r0 <= (others => '0');
    elsif CLK_50Mhz'event and CLK_50Mhz = '1' then  -- rising clock edge
      rq_cmds_r0 <= rq_cmds;
    end if;
  end process sync_sys_clk_pr;

  -- purpose: save requests to DDR3 controller, queue of requests
  req_buffer_pr: process (CLK_50Mhz) is
  begin  -- process req_buffer_pr
    if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge
      if (reset_sys_clk = '0') then     -- synchronous reset (active low)
        rd_rq_buff_n0 <= (others => '0'); -- [39] - rq_valid, [33] - HD, [32] - EV, [DDR3_ADDR_WIDTH-1..0] - address
        rd_rq_buff_n1 <= (others => '0');
        rd_rq_buff_error <= '0';
        rq_cmds_buffered <= (others => '0');
        rq_rd_ptr_buffered <= (others => '0');
        rq_queue_error <= '0';
        keep_request_cnt <= 0;
        -- slow2fast_wait_completed_sys_clk <= '0';
      else

        -- WR to requests buffer
        if (rq_cmds /= "00" and rq_cmds_r0 = "00") then      -- new request
          if (rd_rq_buff_n0(39) = '0') then
            rd_rq_buff_n0(39)                         <= '1';  -- sample request
            rd_rq_buff_n0(33 downto 32)               <= rq_cmds;
            rd_rq_buff_n0(DDR3_ADDR_WIDTH-1 downto 0) <= rq_rd_ptr;
          else
            rq_queue_error <= '1';      -- error: more then 2 requests in queue
          end if;
        elsif (rd_rq_buff_n0(39) = '1' and (DDR_DRIVER_FIFO_EMPTY = '1' and READ_DATA_FSM_IDLE = '1')) then  -- forward request
          rd_rq_buff_n0(39)                         <= '0';  -- clear request
          rd_rq_buff_n1(39)                         <= '1';  -- accept request
          rd_rq_buff_n1(33 downto 32)               <= rd_rq_buff_n0(33 downto 32); -- shift n0 -> n1
          rd_rq_buff_n1(DDR3_ADDR_WIDTH-1 downto 0) <= rd_rq_buff_n0(DDR3_ADDR_WIDTH-1 downto 0); -- shift n0 -> n1
        end if;

        -- RD from requests buffer
        if (wait2next_rq_sys_clk = '1' and rd_rq_buff_n1(39) = '1') then  -- REQ_RRQ_STATE FSM idle and request in queue (ReqExistInQ in diagram)
          rq_cmds_buffered   <= rd_rq_buff_n1(33 downto 32);        -- sample command
          rq_rd_ptr_buffered <= rd_rq_buff_n1(DDR3_ADDR_WIDTH-1 downto 0); -- sample address
          rd_rq_buff_n1(39)  <= '0';    -- clear request
          keep_request_cnt <= 7;  -- !debug: 02/06/2024 7 -> 31
        else
          if (keep_request_cnt /= 0) then
            keep_request_cnt <= keep_request_cnt - 1;
          end if;
          -- if (keep_request_cnt = 0 and slow2fast_wait_cnt = 0) then    -- requires keep pulse 1st: for XPM, 2nd: for REQ_RRQ_STATE FSM
          -- slow2fast_wait_completed_sys_clk <= slow2fast_wait_completed;
          if (keep_request_cnt = 0 and slow2fast_wait_completed_sys_clk = '1') then    -- !debug: 02/06/2024 requires keep pulse 1st: for XPM, 2nd: for REQ_RRQ_STATE FSM
            rq_cmds_buffered   <= (others => '0');
            rq_rd_ptr_buffered <= (others => '0');
          end if;
        end if;


      end if;
    end if;
  end process req_buffer_pr;


 xpm_cdc_single_inst7 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => slow2fast_wait_completed_sys_clk, -- 1-bit output: src_in synchronized to the destination clock domain. This output 19/08/2024
-- is registered.
      dest_clk => CLK_50Mhz,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => slow2fast_wait_completed   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  
  -- purpose: Sampling requests to DDR3 controller
  req_rrq_fsm_pr : process (ui_clk, ddr3_if_rst_n) is
  begin  -- process req_rrq_fsm_pr
    if ddr3_if_rst_n = '0' then               -- asynchronous reset (active low)
      REQ_RRQ_STATE <= IDLE_ST;
      regular_req_pulse <=  '0';
      evolving_req_pulse <= '0';
      rq_cmds_r <= (others => '0');
      raw_rd_ptr_addr <= (others => '0');
      ev_rd_slot_addr <= (others => '0');
      slow2fast_wait_cnt <= 0;
      slow2fast_wait_completed <= '0';
      wait2next_rq_ui_clk <= '0';
    elsif ui_clk'EVENT and ui_clk = '1' then  -- rising clock edge

      regular_req_pulse <=  '0';
      evolving_req_pulse <= '0';

      case REQ_RRQ_STATE is

        when IDLE_ST =>
          REQ_RRQ_STATE <= WAIT2NEXT_RQ_ST;
          wait2next_rq_ui_clk <= '1';
          slow2fast_wait_cnt <= 7;

        when WAIT2NEXT_RQ_ST =>
          if (FALSE) then               -- !TODO: 27/07/2023 add error case, like timeout
            REQ_RRQ_STATE <= ERROR_ST;
          elsif (slow2fast_wait_cnt = 0) then
            if (FALSE) then       -- !TODO: 27/07/2023 add case, like soft reset
              REQ_RRQ_STATE <= PTR2DEFAULT_ST;
            elsif (rq_cmds_dest /= "00") then -- new: "01" - EV, "10" - HD (FQ)
              REQ_RRQ_STATE <= LOAD_CMD_ST;
              wait2next_rq_ui_clk <= '0';
              slow2fast_wait_cnt <= 7;
            end if;
          elsif (slow2fast_wait_cnt /= 0) then
            slow2fast_wait_cnt <= slow2fast_wait_cnt - 1;
          end if;
          rq_cmds_r <= rq_cmds_dest;         -- latch

        when PTR2DEFAULT_ST =>
          REQ_RRQ_STATE <= IDLE_ST;

        when LOAD_CMD_ST =>
          if (slow2fast_wait_cnt = 0) then
            REQ_RRQ_STATE <= LOAD_PTR_ST;
            slow2fast_wait_cnt <= 7;
          elsif (slow2fast_wait_cnt /= 0) then
            slow2fast_wait_cnt <= slow2fast_wait_cnt - 1;
          end if;

        when LOAD_PTR_ST =>
          if (slow2fast_wait_cnt = 0) then
            REQ_RRQ_STATE <= GO_ST;
            if (rq_cmds_r = "10") then  -- 02/10/2023 HD
              regular_req_pulse <=  '1';
              raw_rd_ptr_addr <= DDR3_ADDR_BUS_TYP(rq_rd_ptr_addr_dest); -- !TODO: 27/09/2023 src @sys_clk -> use xpm_cdc
              evolving_req_pulse <= '0';
            elsif (rq_cmds_r = "01") then  -- 02/10/2023 EV
              regular_req_pulse <=  '0';
              evolving_req_pulse <= '1';
              ev_rd_slot_addr <= DDR3_ADDR_BUS_TYP(rq_rd_ptr_addr_dest); -- !TODO: 27/09/2023 src @sys_clk -> use xpm_cdc
            else
              regular_req_pulse <=  '0';
              evolving_req_pulse <= '0';
            end if;
          elsif (slow2fast_wait_cnt /= 0) then
            slow2fast_wait_cnt <= slow2fast_wait_cnt - 1;
          end if;

        when ERROR_ST =>
          REQ_RRQ_STATE <= IDLE_ST;

        when GO_ST =>
          REQ_RRQ_STATE <= WAIT2NEXT_RQ_ST;
          regular_req_pulse <=  '0';
          evolving_req_pulse <= '0';
          wait2next_rq_ui_clk <= '1';
          slow2fast_wait_cnt <= 7;

      end case;


      if (slow2fast_wait_cnt < 2) then  -- 19/08/2024 2 clk pulse for sync
        slow2fast_wait_completed <= '1';
      else
        slow2fast_wait_completed <= '0';
      end if;

    end if;
  end process req_rrq_fsm_pr;

  xpm_hand_simple_1: xpm_hand_simple
    generic map (
      SLOW2FAST => TRUE,
      WIDTH     => DDR3_ADDR_WIDTH)
    port map (
      rst_n    => reset_sys_clk,
      slow_clk => CLK_50Mhz,
      fast_clk => ui_clk,
      src_in   => rq_rd_ptr_buffered, -- !debug: 21/04/2024 was   rq_rd_ptr,
      dest_out => rq_rd_ptr_addr_dest
    );

  -- xpm_hand_simple_2: xpm_hand_simple
  --   generic map (
  --     SLOW2FAST => TRUE,
  --     WIDTH     => 2)
  --   port map (
  --     rst_n    => reset_sys_clk,
  --     slow_clk => CLK_50Mhz,
  --     fast_clk => ui_clk,
  --     src_in   => rq_cmds_r0,
  --     dest_out => rq_cmds_dest
  --   );
  xpm_cdc_array_single_2 : xpm_cdc_array_single
    generic map (
      DEST_SYNC_FF   => 2,               -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,               -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,               -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1,               -- DECIMAL; 0=do not register input, 1=register input
      WIDTH          => 2                -- DECIMAL; range: 1-1024
      )
    port map (
      dest_out => rq_cmds_dest,   -- WIDTH-bit output: src_in synchronized to the destination clock domain. This
-- output is registered.
      dest_clk => ui_clk,                -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,             -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => rq_cmds_buffered -- !debug: 21/04/2024 was rq_cmds_r0                -- WIDTH-bit input: Input single-bit array to be synchronized to destination clock
      );


  ECC_ERROR <= READ_ECC_ERROR;

  RAW_DATA_END_ADDR <= 	FOUR_G_END_ADDR when ( ASSEMBLY_VERSION(1 downto 0) = "01" ) else
                        EIGHT_G_END_ADDR;

  INIT_DONE_A_O <= init_calib_complete;
  assert not(init_calib_complete = '1' and start_write = '1' and master_axi_state(2) = '1') report "AXI write and read in same time!!!" severity ERROR;

  DDR_DRIVER_TESTPOINTS <= (0 => READ_FSM_ERROR, 1 => RAW_FSM_ERROR, others => '0');

  ui_clk_o <= ui_clk;
  ui_clk_sync_rst_o <= ui_clk_sync_rst;
  ddr3_if_rst_n <= not ui_clk_sync_rst;

  -- 22/12/2019 Trident code
  -- AXI master block
  axi4_master_vhdl_inst : axi4_master_vhdl_0
    port map (
      -- !debug: 16/12/2019
      start_write     => start_write,
      start_read      => start_read,
      write_burst_len => write_burst_len,
      read_burst_len  => read_burst_len,
      fifo_axi_wdata  => fifo_axi_wdata,
      fifo_wdata_valid => fifo_wdata_valid,
      waddr_offset    => waddr_offset,
      raddr_offset    => raddr_offset,
      fifo_rd_en      => fifo_rd_en,
      master_axi_state => master_axi_state,
      axi_if_req       => axi_if_req_masked, -- !debug: 09/02/2023 for DDR3 test: test_axi_if_req
      gnt_catch        => gnt_catch,         -- 01/11/2023
      m00_axi_awid         => m00_axi_awid,
      m00_axi_awaddr       => m00_axi_awaddr,
      m00_axi_awlen        => m00_axi_awlen,
      m00_axi_awsize       => m00_axi_awsize,
      m00_axi_awburst      => m00_axi_awburst,
      m00_axi_awlock       => m00_axi_awlock,
      m00_axi_awcache      => m00_axi_awcache,
      m00_axi_awprot       => m00_axi_awprot,
      m00_axi_awqos        => m00_axi_awqos,
      m00_axi_awuser       => open,
      m00_axi_awvalid      => m00_axi_awvalid,
      m00_axi_awready      => m00_axi_awready,
      m00_axi_wdata        => m00_axi_wdata,
      m00_axi_wstrb        => m00_axi_wstrb,
      m00_axi_wlast        => m00_axi_wlast,
      m00_axi_wuser        => open,
      m00_axi_wvalid       => m00_axi_wvalid,
      m00_axi_wready       => m00_axi_wready,
      m00_axi_bid          => m00_axi_bid,
      m00_axi_bresp        => m00_axi_bresp,
      m00_axi_buser(0)     => '0',
      m00_axi_bvalid       => m00_axi_bvalid,
      m00_axi_bready       => m00_axi_bready,
      m00_axi_arid         => m00_axi_arid,
      m00_axi_araddr       => m00_axi_araddr,
      m00_axi_arlen        => m00_axi_arlen,
      m00_axi_arsize       => m00_axi_arsize,
      m00_axi_arburst      => m00_axi_arburst,
      m00_axi_arlock       => m00_axi_arlock,
      m00_axi_arcache      => m00_axi_arcache,
      m00_axi_arprot       => m00_axi_arprot,
      m00_axi_arqos        => m00_axi_arqos,
      m00_axi_aruser       => open,
      m00_axi_arvalid      => m00_axi_arvalid,
      m00_axi_arready      => m00_axi_arready,
      m00_axi_rid          => m00_axi_rid,
      m00_axi_rdata        => m00_axi_rdata,
      m00_axi_rresp        => m00_axi_rresp,
      m00_axi_rlast        => m00_axi_rlast,
      m00_axi_ruser(0)     => '0',
      m00_axi_rvalid       => m00_axi_rvalid,
      m00_axi_rready       => m00_axi_rready,
      m00_axi_aclk         => ui_clk, -- !debug: 23/12/2019
      m00_axi_aresetn      => ddr3_if_rst_n, -- !debug: 23/12/2019  global_reset_n
      m00_axi_init_axi_txn => m00_axi_init_axi_txn,
      m00_axi_txn_done     => m00_axi_txn_done,
      m00_axi_error        => m00_axi_error
    );


  -- DDR3 IP
  ddr3_axi_if_inst : DDR3_AXI_IF
    port map (
      ddr3_dq             => ddr3_dq,
      ddr3_dqs_n          => ddr3_dqs_n,
      ddr3_dqs_p          => ddr3_dqs_p,
      ddr3_addr           => ddr3_addr,
      ddr3_ba             => ddr3_ba,
      ddr3_ras_n          => ddr3_ras_n,
      ddr3_cas_n          => ddr3_cas_n,
      ddr3_we_n           => ddr3_we_n,
      ddr3_reset_n        => ddr3_reset_n,
      ddr3_ck_p           => ddr3_ck_p,
      ddr3_ck_n           => ddr3_ck_n,
      ddr3_cke            => ddr3_cke,
      ddr3_cs_n           => ddr3_cs_n,
      ddr3_dm             => ddr3_dm,
      ddr3_odt            => ddr3_odt,
      -- sys_clk_i           => sys_clk_i,
      -- clk_ref_i           => clk_ref_i,
      sys_clk_p           => sys_clk_p, -- 19/09/2022
      sys_clk_n           => sys_clk_n, -- 19/09/2022
      ui_clk              => ui_clk,
      ui_clk_sync_rst     => ui_clk_sync_rst, -- active '1'
      mmcm_locked         => mmcm_locked,
      aresetn             => global_reset_ui_clk,
      app_sr_req          => '0',
      app_ref_req         => '0',
      app_zq_req          => '0',
      app_sr_active       => open,
      app_ref_ack         => open,
      app_zq_ack          => open,
      s_axi_awid          => m00_axi_awid,
      s_axi_awaddr        => m00_axi_awaddr(28 downto 0), -- 19/09/2022
      s_axi_awlen         => m00_axi_awlen,
      s_axi_awsize        => m00_axi_awsize,
      s_axi_awburst       => m00_axi_awburst,
      s_axi_awlock        => (0 => m00_axi_awlock),
      s_axi_awcache       => m00_axi_awcache,
      s_axi_awprot        => m00_axi_awprot,
      s_axi_awqos         => m00_axi_awqos,
      s_axi_awvalid       => m00_axi_awvalid,
      s_axi_awready       => m00_axi_awready,
      s_axi_wdata         => m00_axi_wdata,
      s_axi_wstrb         => m00_axi_wstrb,
      s_axi_wlast         => m00_axi_wlast,
      s_axi_wvalid        => m00_axi_wvalid,
      s_axi_wready        => m00_axi_wready,
      s_axi_bready        => m00_axi_bready,
      s_axi_bid           => m00_axi_bid,
      s_axi_bresp         => m00_axi_bresp,
      s_axi_bvalid        => m00_axi_bvalid,
      s_axi_arid          => m00_axi_arid,
      s_axi_araddr        => m00_axi_araddr(28 downto 0), -- 19/09/2022
      s_axi_arlen         => m00_axi_arlen,
      s_axi_arsize        => m00_axi_arsize,
      s_axi_arburst       => m00_axi_arburst,
      s_axi_arlock        => (0 => m00_axi_arlock),
      s_axi_arcache       => m00_axi_arcache,
      s_axi_arprot        => m00_axi_arprot,
      s_axi_arqos         => m00_axi_arqos,
      s_axi_arvalid       => m00_axi_arvalid,
      s_axi_arready       => m00_axi_arready,
      s_axi_rready        => m00_axi_rready,
      s_axi_rid           => m00_axi_rid,
      s_axi_rdata         => m00_axi_rdata,
      s_axi_rresp         => m00_axi_rresp,
      s_axi_rlast         => m00_axi_rlast,
      s_axi_rvalid        => m00_axi_rvalid,
      init_calib_complete => init_calib_complete,
      device_temp         => open,
      sys_rst             => '1'        -- System reset - Default polarity of sys_rst pin is Active Low
    );


  -- 09/02/2023 DDR3 test

 -- FQ/EV data FIFO
  dcfifo_512x32_1: dcfifo_512x32
    port map (
      rst           => ui_clk_sync_rst,
      wr_clk        => CLK_50Mhz,
      rd_clk        => ui_clk,
      din           => test_tile_wdata,
      wr_en         => test_fifo_wr_en,
      rd_en         => test_fifo_rd_en,      -- start_write drive 1st fifo_rd_en (like read-ahead), then uses wnext for read next data
      dout          => test_fifo_axi_wdata,  -- data to DDR3
      full          => test_fifo_full,
      overflow      => test_fifo_overflow,
      empty         => test_fifo_empty,
      valid         => test_fifo_wdata_valid,  -- data strobe to DDR3
      underflow     => test_fifo_underflow,
      rd_data_count => test_fifo_rd_data_count,
      wr_data_count => test_fifo_wr_data_count
  );


  test_data_en <= UNIQ_ID(1);         -- !debug: 09/02/2023 only for DDR3 test
  -- FPGA_ID[3..0]: 0x1 - walk0, 0x2 - walk1, 0x3 - All ones, 0x4 - All zeros, 0x5 - 0x5A5A_A5A5

  -- Write Data Generator
  data_gen_pr : process(CLK_50Mhz)
  begin
    if (rising_edge (CLK_50Mhz)) then
      if (reset_sys_clk = '0' or DDR3_SOFT_RESET_N = '0') then
        test_tile_wdata <= std_logic_vector (to_unsigned(0, 32));
        test_fifo_wr_en <= '0';
        -- test_fifo_write_cnt <= 0;
      else
        if (test_data_en = '1') then
          if (unsigned(test_fifo_wr_data_count) < X"1C0") then
            -- test_tile_wdata <= std_logic_vector(unsigned(test_tile_wdata) + 1);
            -- test_fifo_write_cnt <= (test_fifo_write_cnt + 1) mod 32;
            if (FPGA_ID = X"1" or FPGA_ID = X"2") then
              test_tile_wdata <= test_tile_wdata(30 downto 0) & test_tile_wdata(31);
            end if;
            test_fifo_wr_en <= '1';
          else
            test_fifo_wr_en <= '0';
          end if;
        else                            -- stop / init
          test_fifo_wr_en <= '0';
          if (FPGA_ID = X"1") then
            test_tile_wdata <= X"FFFF_FFFE"; -- Walking zeros
          elsif (FPGA_ID = X"2") then
            test_tile_wdata <= X"00000001"; -- Walking ones
          elsif (FPGA_ID = X"3") then
            test_tile_wdata <= X"FFFFFFFF"; -- All ones
          elsif (FPGA_ID = X"4") then
            test_tile_wdata <= X"00000000"; -- All zeros
          else
            test_tile_wdata <= X"5A5A_A5A5"; -- default
          end if;
        end if;
      end if;
    end if;
  end process data_gen_pr;

  -- !TODO: 09/02/2023 mux test_fifo_axi_wdata, test_fifo_wdata_valid to AXI4 master fifo_axi_wdata, fifo_wdata_valid
  -- !TODO: 09/02/2023 drive AXI4 master:
  --   - for write: test_start_write, test_write_burst_len, test_waddr_offset
  --   - for read: test_start_read, test_read_burst_len, test_raddr_offset, test_fifo_rd_en

  misc_ui_clock_pr: process (ui_clk) is
    variable valid_ready_sampled_v : boolean := FALSE;
  begin  -- process misc_ui_clock_pr
    if (ui_clk'event and ui_clk = '1') then  -- rising clock edge

      -- DDR3 WR/RD start
      if (init_calib_complete = '1') then
        if (master_axi_state(0) = '1' and
            (master_axi_state(1) = '0' and master_axi_state(2) = '0') and
            unsigned(test_fifo_rd_data_count) > X"040" and
            (test_writes_done_pre = '0' and test_writes_done = '0')) then     -- idle
          test_start_write <= '1';
          else                          -- end
          -- elsif (master_axi_state(1) = '1') then  -- write to DDR3
          test_start_write <= '0';
        end if;
        if (master_axi_state(0) = '1') then     -- idle
          test_start_read <= test_writes_done;
        elsif (master_axi_state(2) = '1') then  -- read from DDR3
          test_start_read <= '0';
        end if;

        -- test_axi_if_req  ..,FQ,RD
        if (unsigned(test_fifo_rd_data_count) > X"040") then -- exist data for write
          test_axi_if_req(1) <= '1'; --  write request
        else
          test_axi_if_req(1) <= '0';
        end if;
        if (test_writes_done = '1') then -- write burst complete
          test_axi_if_req(0) <= '1'; --  read request
        elsif (master_axi_state(2) = '1') then  -- read from DDR3
          test_axi_if_req(0) <= '0';
        end if;

      end if;

      -- DDR3 WR/RD burst done detection
      if (master_axi_state(1) = '1') then -- write to DDR3
        test_writes_done_pre <= '1';
        test_writes_done <= '0';
      elsif (master_axi_state(0) = '1') then -- returns to idle
        test_writes_done_pre <= '0';
        test_writes_done <= test_writes_done_pre;
      end if;

      if (master_axi_state(2) = '1') then -- read to DDR3
        test_reads_done_pre <= '1';
        test_reads_done <= '0';
      elsif (master_axi_state(0) = '1') then -- returns to idle
        test_reads_done_pre <= '0';
        test_reads_done <= test_reads_done_pre;
      end if;

      -- address calc
      if (ddr3_if_rst_n = '0' or unsigned(test_waddr_offset) > unsigned(RAW_DATA_END_ADDR)) then
        test_waddr_offset <= (others => '0');
      elsif (m00_axi_awready = '1' and m00_axi_awvalid = '1') then -- start write to DDR3
        test_waddr_offset <= std_logic_vector(unsigned(test_waddr_offset) + (unsigned(test_write_burst_len) * 4));
      end if;

      if (ddr3_if_rst_n = '0' or unsigned(test_raddr_offset) > unsigned(RAW_DATA_END_ADDR)) then
        test_raddr_offset <=  (others => '0');
      elsif (m00_axi_arready = '1' and m00_axi_arvalid = '1') then
        test_raddr_offset <= std_logic_vector(unsigned(test_raddr_offset) + (unsigned(test_read_burst_len) * 4));
      end if;

      -- Generate expected read data to check against actual read data
      valid_ready_sampled_v := (m00_axi_rvalid = '1' and m00_axi_rready = '1');
      valid_ready_sampled <= (m00_axi_rvalid = '1' and m00_axi_rready = '1'); -- read data receive
      if (test_data_en = '1') then
        if (FPGA_ID = X"1" or FPGA_ID = X"2") then
          if (valid_ready_sampled_v) then
            expected_rdata <= expected_rdata(30 downto 0) & expected_rdata(31);
          end if;
        end if;
      else                            -- stop / init
        if (FPGA_ID = X"1") then
          expected_rdata <= X"FFFF_FFFE"; -- Walking zeros
        elsif (FPGA_ID = X"2") then
          expected_rdata <= X"00000001"; -- Walking ones
        elsif (FPGA_ID = X"3") then
          expected_rdata <= X"FFFFFFFF"; -- All ones
        elsif (FPGA_ID = X"4") then
          expected_rdata <= X"00000000"; -- All zeros
        else
          expected_rdata <= X"5A5A_A5A5"; -- default
        end if;
      end if;

      -- Check received read data against data generator
      if (ddr3_if_rst_n = '0' or test_start_read = '1') then
        read_mismatch <= '0';
      else
        if (m00_axi_rvalid = '1') then  -- read data valid
          test_rdata_r <= m00_axi_rdata;
        end if;
        if (valid_ready_sampled and (test_rdata_r /= expected_rdata)) then
          read_mismatch <= '1';
        else
          read_mismatch <= '0';
        end if;
      end if;

      global_reset_ui_clk <= global_reset_n;

      -- sync to/from ui_clk
  --    RTL_buffer_free_size <= RTL_buffer_free_size_ui_clk;
  --    RTL_buffer_OverRun <= RTL_buffer_OverRun_ui_clk;
  --    HD_buffer_free_size <= HD_buffer_free_size_ui_clk;
  --    HD_buffer_OverRun <= HD_buffer_OverRun_ui_clk;
  --    OverRun_RTL_reset_flag_ui_clk <= OverRun_RTL_reset_flag;
  --    OverRun_HD_reset_flag_ui_clk <= OverRun_HD_reset_flag;

      assert not(master_axi_state(4) = '1' and raw_start_write = '1') report "FQ tries write to AXI when grant assigned to EV" severity ERROR;
      assert not(master_axi_state(5) = '1' and ev_start_write = '1') report "EV tries write to AXI when grant assigned to FQ" severity ERROR;

    end if;
  end process misc_ui_clock_pr;


  Buffer_Calculator_RTL_1 : Buffer_Calculator_RTL
    port map (
      CLK                                          => ui_clk,
      RESET                                        => "not"(global_reset_ui_clk),
      RTL_write_addr                               => std_logic_vector(resize(EV_READING_EV_DATA_ADDR,32)),
      RTL_read_addr                                => std_logic_vector(resize(READ_READING_EV_DATA_ADDR,32)),
   --   Min_reading_gap                              => Min_reading_gap_reg,                       --std_logic_vector(to_unsigned(EV_NUM_OF_SLOTS,32)),
      OverRun_RTL_reset_flag                       => OverRun_RTL_reset_flag_ui_clk,
      RTL_buffer_start_pointer                     => std_logic_vector(resize(EV_DATA_BASE_ADDR,32)),
      RTL_buffer_end_pointer                       => std_logic_vector(resize(EV_DATA_END_ADDR,32)),
      IP 			                               => IP_ui_clk,    --add by  Dalit 13/12/2023
      RTL_buffer_free_size                         => RTL_buffer_free_size_ui_clk,
      RTL_buffer_free_size_change                  => RTL_message_sync_sig,              --add by  Dalit 6/12/2023
      RTL_buffer_OverRun                           => RTL_buffer_OverRun_ui_clk
  --    RTL_buffer_deep	                           => RTL_buffer_deep --add by  Dalit 19/12/2023
      );

  Buffer_Calculator_HD_1 : Buffer_Calculator_HD
    generic map (MAX_buffer_size => 104) -- NU
    port map (
      CLK                     => ui_clk,
      RESET                   => "not"(global_reset_ui_clk),
      HD_write_addr           => std_logic_vector(resize(RAW_READING_RAW_DATA_ADDR,32)),
      HD_read_addr            => std_logic_vector(resize(READ_READING_RAW_DATA_ADDR,32)),
      HD_write_pointer        => std_logic_vector(resize(RAW_READING_ADDR_FIFO_ADDR,32)),
      HD_read_pointer         => std_logic_vector(resize(READ_READING_ADDR_FIFO_ADDR,32)),
      HD_buffer_start_pointer => std_logic_vector(resize(RAW_DATA_BASE_ADDR,32)),
      HD_buffer_end_pointer   => std_logic_vector(resize(FOUR_G_END_ADDR,32)),
      OverRun_HD_reset_flag   => OverRun_HD_reset_flag_ui_clk,
      IP 			          => IP_ui_clk,    --add by  Dalit 13/12/2023
--      Min_reading_pointer_gap_reg => Min_reading_pointer_gap_reg, --add by  Dalit 18/12/2023
      HD_buffer_free_size     => HD_buffer_free_size_ui_clk,
      HD_buffer_free_size_change => HD_message_sync_sig,              --add by  Dalit 6/12/2023
      HD_buffer_OverRun       => HD_buffer_OverRun_ui_clk
  --    HD_buffer_deep	      => HD_buffer_deep --add by  Dalit 19/12/2023
      );
-- add by Dalit 6/12/23--------------------------------------------------------------------------------------------------------
xpm_cdc_addr_reg_inst1 : xpm_cdc_handshake
generic map (
   DEST_EXT_HSK => 0,   -- DECIMAL; 0=internal handshake, 1=external handshake
   DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
   INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   SRC_SYNC_FF => 4,    -- DECIMAL; range: 2-10
   WIDTH => 32          -- DECIMAL; range: 1-1024
)
port map (
   dest_out => RTL_buffer_free_size,          -- WIDTH-bit output: Input bus (src_in) synchronized to destination clock domain.
                                             -- This output is registered.

   dest_req => OPEN,                         -- 1-bit output: Assertion of this signal indicates that new dest_out data has been
                                             -- received and is ready to be used or captured by the destination logic. When
                                             -- DEST_EXT_HSK = 1, this signal will deassert once the source handshake
                                             -- acknowledges that the destination clock domain has received the transferred
                                             -- data. When DEST_EXT_HSK = 0, this signal asserts for one clock period when
                                             -- dest_out bus is valid. This output is registered.

   src_rcv => RTL_src_rcv_sig,                  -- 1-bit output: Acknowledgement from destination logic that src_in has been
                                            -- received. This signal will be deasserted once destination handshake has fully
                                            -- completed, thus completing a full data transfer. This output is registered.

   dest_ack => '0',                         -- 1-bit input: optional; required when DEST_EXT_HSK = 1
   dest_clk => CLK_50Mhz,                      -- 1-bit input: Destination clock.
   src_clk => ui_clk,                          -- 1-bit input: Source clock.
   src_in => RTL_buffer_free_size_ui_clk,               -- WIDTH-bit input: Input bus that will be synchronized to the destination clock
                                            -- domain.

   src_send => RTL_src_send_sig                 -- 1-bit input: Assertion of this signal allows the src_in bus to be synchronized
                                            -- to the destination clock domain. This signal should only be asserted when
                                            -- src_rcv is deasserted, indicating that the previous data transfer is complete.
                                            -- This signal should only be deasserted once src_rcv is asserted, acknowledging
                                            -- that the src_in has been received by the destination logic.

);


process(ui_clk)
begin
    if rising_edge(ui_clk) then
        if (global_reset_ui_clk = '0') then
            RTL_src_send_sig <= '0';
            RTL_wr_data_fsm <= idle;
        else
            case RTL_wr_data_fsm is
                when idle =>
                    if (RTL_message_sync_sig = '1') then
                        RTL_wr_data_fsm <= wait_for_send;
                    else
                        RTL_wr_data_fsm <= idle;
                    end if;
                    RTL_src_send_sig <= '0';
                 when wait_for_send =>
                    if (RTL_src_rcv_sig = '1') then
                         RTL_wr_data_fsm <= wait_for_send;
                         RTL_src_send_sig <= '0';
                    else
                         RTL_wr_data_fsm <= send;
                         RTL_src_send_sig <= '1';
                    end if;
                 when send =>
                     if (RTL_src_rcv_sig = '0') then
                         RTL_wr_data_fsm <= send;
                         RTL_src_send_sig <= '1';
                    else
                         RTL_wr_data_fsm <= idle;
                         RTL_src_send_sig <= '0';
                    end if;
                 when others =>
                    RTL_wr_data_fsm <= idle;
                    RTL_src_send_sig <= '0';
            end case;
       end if;
    end if;
end process;


 xpm_cdc_single_inst1 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 4,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => RTL_buffer_OverRun,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => RTL_buffer_OverRun_ui_clk   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

 xpm_cdc_addr_reg_inst2 : xpm_cdc_handshake
generic map (
   DEST_EXT_HSK => 0,   -- DECIMAL; 0=internal handshake, 1=external handshake
   DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
   INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   SRC_SYNC_FF => 4,    -- DECIMAL; range: 2-10
   WIDTH => 32          -- DECIMAL; range: 1-1024
)
port map (
   dest_out => HD_buffer_free_size,          -- WIDTH-bit output: Input bus (src_in) synchronized to destination clock domain.
                                             -- This output is registered.

   dest_req => OPEN,                         -- 1-bit output: Assertion of this signal indicates that new dest_out data has been
                                             -- received and is ready to be used or captured by the destination logic. When
                                             -- DEST_EXT_HSK = 1, this signal will deassert once the source handshake
                                             -- acknowledges that the destination clock domain has received the transferred
                                             -- data. When DEST_EXT_HSK = 0, this signal asserts for one clock period when
                                             -- dest_out bus is valid. This output is registered.

   src_rcv => HD_src_rcv_sig,                  -- 1-bit output: Acknowledgement from destination logic that src_in has been
                                            -- received. This signal will be deasserted once destination handshake has fully
                                            -- completed, thus completing a full data transfer. This output is registered.

   dest_ack => '0',                         -- 1-bit input: optional; required when DEST_EXT_HSK = 1
   dest_clk => CLK_50Mhz,                      -- 1-bit input: Destination clock.
   src_clk => ui_clk,                          -- 1-bit input: Source clock.
   src_in => HD_buffer_free_size_ui_clk,               -- WIDTH-bit input: Input bus that will be synchronized to the destination clock
                                            -- domain.

   src_send => HD_src_send_sig                 -- 1-bit input: Assertion of this signal allows the src_in bus to be synchronized
                                            -- to the destination clock domain. This signal should only be asserted when
                                            -- src_rcv is deasserted, indicating that the previous data transfer is complete.
                                            -- This signal should only be deasserted once src_rcv is asserted, acknowledging
                                            -- that the src_in has been received by the destination logic.

);


process(ui_clk)
begin
    if rising_edge(ui_clk) then
        if (global_reset_ui_clk = '0') then
            HD_src_send_sig <= '0';
            HD_wr_data_fsm <= idle;
        else
            case HD_wr_data_fsm is
                when idle =>
                    if (HD_message_sync_sig = '1') then
                        HD_wr_data_fsm <= wait_for_send;
                    else
                        HD_wr_data_fsm <= idle;
                    end if;
                    HD_src_send_sig <= '0';
                 when wait_for_send =>
                    if (HD_src_rcv_sig = '1') then
                         HD_wr_data_fsm <= wait_for_send;
                         HD_src_send_sig <= '0';
                    else
                         HD_wr_data_fsm <= send;
                         HD_src_send_sig <= '1';
                    end if;
                 when send =>
                     if (HD_src_rcv_sig = '0') then
                         HD_wr_data_fsm <= send;
                         HD_src_send_sig <= '1';
                    else
                         HD_wr_data_fsm <= idle;
                         HD_src_send_sig <= '0';
                    end if;
                 when others =>
                    HD_wr_data_fsm <= idle;
                    HD_src_send_sig <= '0';
            end case;
       end if;
    end if;
end process;

    xpm_cdc_single_inst2 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 4,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => HD_buffer_OverRun,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => HD_buffer_OverRun_ui_clk   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );



     xpm_cdc_single_inst3 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 4,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => OverRun_RTL_reset_flag_ui_clk,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => ui_clk,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => OverRun_RTL_reset_flag_wide   -- 1-bit input: Input signal to be synchronized to dest_clk domain. -- dalit+Eugene 22/7/2024
      );

-- dalit+ eugene 22/7/2024
process(CLK_50Mhz)
begin
    if rising_edge(CLK_50Mhz) then
      OverRun_RTL_reset_flag_ff<=OverRun_RTL_reset_flag_ff (3 downto 0) & OverRun_RTL_reset_flag;
      if OverRun_RTL_reset_flag_ff/= "00000" then 
         OverRun_RTL_reset_flag_wide <= '1';
       else
         OverRun_RTL_reset_flag_wide <= '0';
       end if;      
    end if;
end process;
--------------------------------------------


     xpm_cdc_single_inst4 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 4,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => OverRun_HD_reset_flag_ui_clk,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => ui_clk,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => OverRun_HD_reset_flag   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

     xpm_cdc_single_inst5 : xpm_cdc_single  --add by Dalit 13/12/2023
    generic map (
      DEST_SYNC_FF   => 4,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => IP_ui_clk,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => ui_clk,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => IP50   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

  xpm_cdc_single_inst6 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => wait2next_rq_sys_clk, -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => wait2next_rq_ui_clk   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );


  xpm_cdc_single_inst : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => trig_in_ui_clk,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => ui_clk,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => trig_in_sys_clk   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  trig_in_sys_clk <= RAW_FIFO_OVERFLOW when (diag_sel = "000") else
                     RAW_FSM_ERROR when (diag_sel = "001") else
                     RAW_FIFO_NOTEMPTY when (diag_sel = "010") else
                     EV_FIFO_OVERFLOW when (diag_sel = "011") else
                     EV_FSM_ERROR when (diag_sel = "100") else
                     EV_FIFO_NOTEMPTY;  --  !debug: 29/10/2023 only for LA

  ddr_driver_errors <= X"000" & "00" &
                       READ_BUFFER_ADDR_ERROR & READ_POINTER_ERROR & READ_FIFO_OVERFLOW & READ_FIFO_NOTEMPTY & READ_FSM_ERROR &
                       EV_WR_BAD_PACKET_SIZE & EV_WR_BURST_ERROR & EV_ADDR_AREA_ERROR & EV_FIFO_OVERFLOW & EV_FIFO_NOTEMPTY & EV_FSM_ERROR &
                       RAW_BAD_PACKET_SIZE & RAW_WR_BURST_INCOMPLETE & RAW_WR_ADDR_ERROR_O & RAW_POINTER_ERROR & RAW_FIFO_OVERFLOW & RAW_FIFO_NOTEMPTY & RAW_FSM_ERROR; -- 06/06/2024

end struct;
