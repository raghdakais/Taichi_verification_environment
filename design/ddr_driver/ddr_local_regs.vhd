-------------------------------------------------------------------------------
-- Title      : DDR driver local registers
-- Project    : DDR2 part of peripheral FPGA (Ovation project)
-------------------------------------------------------------------------------
-- File       : ddr_local_regs.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    :
-- Created    : 18/01/2006
-- Last update: 01/09/2022
-- Platform   :
-- Standard   : VHDL'93, Math Packages
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2006
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 18/01/2006  1.0      ilq00431  Created
-------------------------------------------------------------------------------
-- Note: Set USE_LA, if need
-- TODO: change 0x0B6, 0x0B7 from absolute address to relative to EV_DATA_BASE_ADDR
-- change 0x0BA , 0x0BB from absolute address to relative to EV_DATA_BASE_ADDR
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.tbuf_pack.all;
use work.TMC_pack.all;


entity ddr_local_regs is
  generic (
    CURRENT_DATE_PARAM : unsigned(23 downto 0) := X"180101"); -- date is incremental number YY/MM/DD
  port(
    RESET_I             : in std_logic;
    RESET_128           : in std_logic;
    SYSTEM_CLK64_I      : in std_logic; -- 64MHz system clock
    TOP_CLK_MEM_128M    : in std_logic; -- memory controller clock (152MHz for sCT1)
    RAW_DATA_END_ADDR   : in  DDR3_ADDR_BUS_TYP; -- const value
    Bi_Dir_Direction    : out std_logic;

    -- DDR driver (buffers) registers inputs @64MHz
    FPGA_ID              : in    std_logic_vector (3 downto 0);   -- 19/12/2017 was TBUF_R_L & FPGA_ID_I, now const value "0110"
    PORTS_CLK_EN         : in    std_logic;
    PORTS_CLK_LAUNCH_EN  : in	   std_logic;
    PORT_ALE_I           : in    std_logic;
    PORT_READ_I          : in    std_logic;
    PORT_WRITE_I         : in    std_logic;
    PORT_A_D_B_IN        : in    std_logic_vector (15 downto 0);  -- shared bus
    PORT_A_D_B_OUT       : out   std_logic_vector (15 downto 0);  -- shared bus
    DDR_DRIVER_INTR_L    : out   std_logic;  -- out , if any of int. bits active
    DDR_DRIVER_ACK       : out   std_logic;  -- out, after cmd. rd/wr
	DDR_DRIVER_STOP_SCAN_O : out std_logic;	 -- out, SC shall immediate stop IP !debug: 19/12/2017 was @152MHz, !TODO: connect as in iCT (uses for interrups)
	EV_STOP_SCAN_O		   : out std_logic;	 -- out, SC shall immediate stop IP !debug: 19/12/2017 was @152MHz, !TODO: connect as in iCT (uses for interrups)
	PTR_STOP_SCAN_O		   : out std_logic;	 -- out, sc shall immediate stop IP !debug: 19/12/2017 was @152MHz, !TODO: connect as in iCT (uses for interrups)

    -- Buffer control and errors registers interface  @64MHz
    INIT_DONE_ALL_O    : in std_logic; -- NU @152MHz
    RAW_FIFO_OVERFLOW  : in std_logic;  -- A,B or ECC FIFO in overflow state, wrfull='1'
    RAW_FSM_ERROR      : in std_logic;  -- FSM timeout
    RAW_FIFO_NOTEMPTY  : in std_logic;  -- rdempty='0' and DATA_SORTER_PRE_FRAME_START='1'
    EV_FIFO_OVERFLOW   : in std_logic;
	EV_FSM_ERROR	   : in std_logic;
	EV_FIFO_NOTEMPTY   : in std_logic;
    READ_FIFO_OVERFLOW : in std_logic;  -- A,B or ECC FIFO in overflow state, wrfull='1'
    READ_FSM_ERROR     : in std_logic;  -- FSM timeout
    READ_FIFO_NOTEMPTY : in std_logic;  -- rdempty='0' and CENTRAL_INTERFACE_NEXT_REQ='1'
    READ_FIFO_SPACE    : in std_logic_vector(10 downto 0);  -- available words in FIFO
    EV_FIFO_SPACE      : in std_logic_vector(8 downto 0);
    -- REFRESH_TIMEOUT    : in std_logic;  -- error: refresh was disabled long time
    RAW_BUFFER_OVERFLOW         : out std_logic; -- @152MHz
    PTR_BUFFER_OVERFLOW, PTR_BUFFER_UNDERFLOW : out std_logic; -- @152MHz
    EV_BUFFER_OVERFLOW          : out std_logic; -- meaning is slots overflow,  @152MHz
    EV_BUFFER_UNDERFLOW         : out std_logic; -- @152MHz
	CENTRAL_INTERFACE_SETUP_VALID : in std_logic; -- 19/12/2017 constant '1', because no central_interface in module

    -- @152MHz
    RAW_READING_ADDR_FIFO_ADDR  : in DDR3_ADDR_BUS_TYP;  -- reading ptr, from RAW WRITE block
    RAW_READING_RAW_DATA_ADDR   : in DDR3_ADDR_BUS_TYP;  -- raw_data_addr, from RAW WRITE block
    EV_READING_EV_DATA_ADDR     : in DDR3_ADDR_BUS_TYP;
    READ_READING_ADDR_FIFO_ADDR : in DDR3_ADDR_BUS_TYP;  -- reading ptr, from READ block
    READ_READING_RAW_DATA_ADDR  : in DDR3_ADDR_BUS_TYP;  -- raw_data_addr, from READ block
    READ_READING_EV_DATA_ADDR   : in DDR3_ADDR_BUS_TYP;

    -- @152MHz
    EV_READING_EV_SLOTNUM : in EV_BUFFER_SLOTS_TYP;
    READ_READING_EV_SLOTNUM : in EV_BUFFER_SLOTS_TYP;

    -- @152MHz
    DATA_SORTER_PRE_FRAME_START : in std_logic;
    EVOLVING_PRE_FRAME_START    : in  std_logic;

    -- @64MHz
    READ_ECC_ERROR              : in std_logic;  -- ECC error (double,unrecoverable)
    ECC_ERROR_INTERNAL          : in  boolean;                       -- output from ECC check
    ECC_DOUBLE_ERROR_INTERNAL   : in  boolean;                       -- output from ECC check
    READ_ECC_ERROR_CHIPNUM      : in  std_logic_vector(3 downto 0);
    READ_ECC_ERROR_ADDR         : in  DDR3_ADDR_BUS_TYP;             -- 40MHz
    ECC_ERROR_INJECTION_CMD     : out std_logic_vector(1 downto 0);  -- 0,1,2 errors
    ECC_ERROR_MASK              : in  std_logic_vector(6 downto 0);
    DATA_READ_TIMEOUT_INTERRUPT : in  std_logic;                     -- NU
    MEM_TEST_INTERRUPTED        : in  std_logic;
    MEM_TEST_DONE               : in  std_logic;
    MEM_TEST_SUCCESSFUL         : in  std_logic;
    MEM_TEST_PASSED             : in  std_logic;
    MEM_TEST_FAILED_DEVICES     : in  std_logic_vector(8 downto 0);  -- @152MHz
    MEM_TEST_ERROR_DATA_ADDR    : in  DDR3_ADDR_BUS_TYP;             -- @152MHz
    MEM_TEST_FULL               : out std_logic;
    -- DISABLE_REFRESH             : out std_logic;
    DISABLE_RAW_REQ             : out std_logic;
    DISABLE_EV_REQ              : out std_logic;
    DISABLE_READ_REQ            : out std_logic;
    INJECT_OUTPUT_FIFO_DATA     : out std_logic;
    SLICE_REQ_ERROR             : in  std_logic;                     -- slice request in busy time

    -- Test counters (check reading number) @64MHz
    RAW_WR_COUNTER     : in  std_logic_vector(31 downto 0);
    EV_WR_COUNTER      : in  std_logic_vector(31 downto 0);
    RAW_RD_COUNTER     : in  std_logic_vector(31 downto 0);
    EV_RD_COUNTER      : in  std_logic_vector(31 downto 0);

    UNMASKED_INTERRUPT : out std_logic;
    DDR_LOCAL_REGS_TP  : out std_logic_vector (31 downto 0)
  );

end ddr_local_regs;


architecture ar of ddr_local_regs is

  -- Architecture declarations
  constant USE_LA : boolean := TRUE;    -- use LA memory
  constant RAW_BUFFER_UNDERRUN_LIMIT    : DDR3_ADDR_BUS_TYP := resize(X"0000002",DDR3_ADDR_BUS_TYP'LENGTH);
  constant EV_UNDERRUN_LIMIT            : integer := 1;
  constant PTR_UNDERRUN_LIMIT           : DDR3_ADDR_BUS_TYP := resize(X"0000002",DDR3_ADDR_BUS_TYP'LENGTH);
  constant EV_OVERFLOW_LIMIT           : EV_BUFFER_SLOTS_TYP := X"50"; -- 80 available readings, meaning 128 - 80 = 48 readings occupied

  constant EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_INIT  : EV_BUFFER_SLOTS_TYP := "00110000"; -- 48
  constant EVOLVING_STOP_IP_HIGH_LIMIT_INIT              : EV_BUFFER_SLOTS_TYP := "00111100"; --60
  constant EVOLVING_STOP_IP_LOW_LIMIT_INIT               : EV_BUFFER_SLOTS_TYP := "00100000"; --32

  -- Internal signal declarations


  -- Component Declarations


  -- Buffer Control Registers
  signal buffer_control_interrupt_status_register_reg : unsigned(31 downto 0);  -- RW
  signal buffer_control_unmasked_interrupt_reg_reg : unsigned(31 downto 0);  -- R
  signal buffer_control_interrupt_mask_register_reg   : unsigned(31 downto 0);  -- RW

  signal buffer_status_lsb_reg : unsigned(15 downto 0);
  signal buffer_status_msb_reg : unsigned(15 downto 0);

  signal ev_buffer_status_reg : unsigned(15 downto 0);

  signal reading_pointer_buffer_status_lsb_reg : unsigned(15 downto 0);
  signal reading_pointer_buffer_status_msb_reg : unsigned(15 downto 0);

  signal raw_fifo_status_reg : unsigned(15 downto 0);
  signal ev_fifo_status_reg  : unsigned(15 downto 0);

  signal comm_tx_fifo_status_reg : unsigned(15 downto 0);

  signal raw_write_pointer_lsb_reg : unsigned(15 downto 0);
  signal raw_write_pointer_msb_reg : unsigned(15 downto 0);

  signal evolving_write_pointer_lsb_reg : unsigned(15 downto 0);
  signal evolving_write_pointer_msb_reg : unsigned(15 downto 0);

  signal comm_tx_raw_read_pointer_lsb_reg : unsigned(15 downto 0);
  signal comm_tx_raw_read_pointer_msb_reg : unsigned(15 downto 0);

  signal comm_tx_ev_read_pointer_lsb_reg : unsigned(15 downto 0);
  signal comm_tx_ev_read_pointer_msb_reg : unsigned(15 downto 0);

  signal ddr2_device_test_status_reg      : unsigned(15 downto 0);
  signal ddr2_address_test_status_lsb_reg : unsigned(15 downto 0);
  signal ddr2_address_test_status_msb_reg : unsigned(15 downto 0);

  signal ecc_error_chip_number_reg        : unsigned(8 downto 0);
  signal ecc_error_address_lsb_reg        : unsigned(15 downto 0);
  signal ecc_error_address_msb_reg        : unsigned(15 downto 0);
  signal ecc_corrected_errors_counter_reg : unsigned(15 downto 0);  -- RW
  signal ecc_errors_counter_reg           : unsigned(15 downto 0);  -- RW

  signal ecc_error_injection_reg : unsigned(8 downto 0);  -- RW
  signal ddr_driver_control_reg, ddr_driver_control_reg_sampled : unsigned(15 downto 0);  -- R/W

  signal raw_wr_counter_lsb_reg : unsigned(15 downto 0);  -- R
  signal raw_wr_counter_msb_reg : unsigned(15 downto 0);  -- R
  signal ev_wr_counter_lsb_reg : unsigned(15 downto 0);  -- R
  signal ev_wr_counter_msb_reg : unsigned(15 downto 0);  -- R
  signal raw_rd_counter_lsb_reg : unsigned(15 downto 0);  -- R
  signal raw_rd_counter_msb_reg : unsigned(15 downto 0);  -- R
  signal ev_rd_counter_lsb_reg : unsigned(15 downto 0);  -- R
  signal ev_rd_counter_msb_reg : unsigned(15 downto 0);  -- R

  -- signal periph_la_depth_reg    : unsigned(15 downto 0);  -- R
  -- signal periph_la_data_lsb_reg : unsigned(15 downto 0);  -- R
  -- signal periph_la_data_msb_reg : unsigned(15 downto 0);  -- R

  -- misc
  signal raw_buffer_overflow_i, raw_buffer_overflow_i_sampled, raw_buffer_overflow_i_64m : std_logic;
  signal ptr_buffer_overflow_i  : std_logic;
  signal ptr_buffer_underflow_i : std_logic;
  signal slice_req_error_64m    : std_logic;

  signal raw_addr_cmp_result, raw_addr_cmp_result_sampled : DDR3_ADDR_BUS_TYP;  -- address comarison result
  signal raw_addr_cmp_result_64m       : DDR3_ADDR_BUS_TYP;
  signal ev_addr_cmp_result            : DDR3_ADDR_BUS_TYP;  -- address comarison result
  signal ptr_addr_cmp_result, ptr_addr_cmp_result_r : DDR3_ADDR_BUS_TYP;  -- address comarison result
  signal ptr_addr_cmp_result_r_sampled : DDR3_ADDR_BUS_TYP;
  signal ptr_addr_cmp_underflow_result : DDR3_ADDR_BUS_TYP;  -- address comarison result
  signal sorter_pre_frame_start_r      : std_logic_vector(2 downto 0);

  signal evolving_pre_frame_start_r    : unsigned(2 downto 0);
  signal ev_slotnum_cmp_result, ev_slotnum_cmp_result_64m : EV_BUFFER_SLOTS_TYP := (others => '0');
  signal ev_slotnum_cmp_underflow_result  : EV_BUFFER_SLOTS_TYP;
  signal ev_slots_overflow_i : std_logic;
  signal ev_slots_underflow_i : std_logic;
  signal ev_buffer_overflow_i, ev_buffer_overflow_i_sampled    : std_logic;

  signal ptr_buffer_overflow_cnt, read_fsm_error_cnt : natural range 0 to 15;
  signal ptr_buffer_overflow_r, read_fsm_error_r       : std_logic;
  signal memory_goes_fill                                                     : boolean;


  -- For DDR driver (buffers) registers
  signal local_address           : unsigned(15 downto 0);
  --  signal DDR_DRIVER_LOCAL_DATA_R : std_logic_vector (15 downto 0);  -- muxed bus
  --  signal DDR_DRIVER_CS           : std_logic;

  signal fpga_selected       : boolean;
  signal ddr_driver_selected : boolean;
  signal do_read, do_write, do_read_r   : boolean;
  signal port_ale_r : std_logic;
  signal write_ack : std_logic;         -- internal ACK after write to registers

  signal div3 : unsigned(2 downto 0);
  signal raw_reading_raw_data_addr_sampled, raw_reading_raw_data_addr_64m   : DDR3_ADDR_BUS_TYP;
  signal ev_reading_ev_data_addr_sampled, ev_reading_ev_data_addr_64m       : DDR3_ADDR_BUS_TYP;
  signal read_reading_raw_data_addr_sampled, read_reading_raw_data_addr_64m  : DDR3_ADDR_BUS_TYP;
  signal ptr_addr_cmp_result_64m  : DDR3_ADDR_BUS_TYP;
  -- signal raw_fsm_error_64m, ev_fsm_error_sampled , ev_fsm_error_64m : std_logic;
  signal read_reading_ev_data_addr_sampled, read_reading_ev_data_addr_64m : DDR3_ADDR_BUS_TYP;
  signal read_ecc_error_addr_64m : DDR3_ADDR_BUS_TYP;
  -- signal read_fifo_space_sampled, read_fifo_space_64m : std_logic_vector(10 downto 0);  -- available words in FIFO
  signal mem_test_error_data_addr_sampled, mem_test_error_data_addr_64m : DDR3_ADDR_BUS_TYP;
  signal mem_test_failed_devices_sampled, mem_test_failed_devices_64m : std_logic_vector(8 downto 0);

  -- signal raw_fifo_notempty_sampled, raw_fifo_notempty_64m : std_logic;

  signal read_ecc_error_cnt, read_double_ecc_error_cnt : natural range 0 to (2**16 - 1);
  signal ecc_error_r, ecc_double_error_r          : boolean;
  signal ecc_corrected_errors_counter_reset, ecc_errors_counter_reset  : boolean;
  signal ecc_error_pipe   : std_logic_vector(1 downto 0);
  signal ecc_error_interrupt_pulse : std_logic;
  signal ecc_double_error_pipe   : std_logic_vector(1 downto 0);
  signal ecc_double_error_interrupt_pulse : std_logic;
  signal one_ecc_error_internal_interrupt : std_logic;
  signal double_ecc_error_internal_interrupt : std_logic;

  attribute noprune        : boolean;
  attribute noprune of all : signal is true;
  attribute syn_keep       : boolean;
  attribute syn_keep of ev_slots_underflow_i, ptr_addr_cmp_underflow_result,
    ptr_buffer_underflow_i, EV_BUFFER_UNDERFLOW, PTR_BUFFER_UNDERFLOW : signal is true;

  type LA_MEMORY_TYP is array (0 to 127) of unsigned(31 downto 0);
  signal la_memory : LA_MEMORY_TYP;
  signal la_done, la_done_r : boolean;             -- stop write data to LA buffer and enable read
                                        -- (as not Run_nStop)
  signal sample_la_data : boolean;      -- update registers, used for LA data
  signal la_memory_addr : natural range 0 to 127; -- read LA address
  signal la_incr : boolean;                       -- auto after RD from ports

-- raw_addr_cmp_pr
  signal stop_scan_highbound : std_logic; -- RanF 8/10/2006
  signal stop_scan_lowbound  : std_logic; -- RanF 8/10/2006
  signal ev_stop_scan_highbound : std_logic; -- MeitalR 10/12/07
  signal ev_stop_scan_lowbound  : std_logic; -- MeitalR 10/12/07
  signal ptr_stop_scan_highbound : std_logic; -- MeitalR 12/03/08
  signal ptr_stop_scan_lowbound : std_logic; -- MeitalR 12/03/08
  signal ddr_driver_stop_scan_interrupt  : std_logic; -- RanF 30/8/2007
  signal stop_scan_interrupt_pulse 		 : std_logic;
  signal EV_stop_scan_interrupt          : std_logic;
  signal EV_stop_scan_interrupt_pulse	 : std_logic;
  signal ptr_stop_scan_interrupt         : std_logic;
  signal ptr_stop_scan_interrupt_pulse   : std_logic;
  signal Raw_Buffer_underrun_interrupt_pulse : std_logic;
  signal ev_slots_overflow_pulse            : std_logic;
  signal ev_slots_underflow_pulse            : std_logic;
  signal ptr_underflow_pulse                 : std_logic;
  signal ptr_overflow_pulse                  : std_logic;
  signal Raw_overflow_pulse                  : std_logic;
  signal ev_slots_overflow_i_64m       : std_logic;

  -- 08/07/2018
  -- signal EV_DATA_STOP_SCAN_INTERRUPT     : EV_BUFFER_SLOTS_TYP;
  -- signal EV_DATA_STOP_SCAN_HIGHBOUND     : EV_BUFFER_SLOTS_TYP;
  -- signal EV_DATA_STOP_SCAN_LOWBOUND      : EV_BUFFER_SLOTS_TYP;
  constant EV_DATA_STOP_SCAN_HIGHBOUND     : EV_BUFFER_SLOTS_TYP := EV_NUM_OF_SLOTS - EVOLVING_STOP_IP_HIGH_LIMIT_INIT;
  constant EV_DATA_STOP_SCAN_LOWBOUND      : EV_BUFFER_SLOTS_TYP := EV_NUM_OF_SLOTS - EVOLVING_STOP_IP_LOW_LIMIT_INIT;

  signal EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_reg : EV_BUFFER_SLOTS_TYP;
  signal EVOLVING_STOP_IP_HIGH_LIMIT_reg : EV_BUFFER_SLOTS_TYP;
  signal EVOLVING_STOP_IP_LOW_LIMIT_reg  : EV_BUFFER_SLOTS_TYP;
  signal Raw_Buffer_underrun_interrupt  : std_logic ; -- MeitalR 10/12/07
  signal Raw_buffer_underrun_relevant   : boolean;
  signal Ev_underrun_relevant           : boolean;
  signal Ptr_underrun_relevant          : boolean;
  signal raw_addr_occupied : DDR3_ADDR_BUS_TYP;
  signal ev_addr_occupied  : integer;
  signal EV_stop_scan_pipe          : std_logic_vector(1 downto 0);
  signal ddr_driver_stop_scan_pipe  : std_logic_vector(1 downto 0);
  signal PTR_stop_scan_pipe         : std_logic_vector(1 downto 0);
  signal ev_slots_overflow_i_pipe   : std_logic_vector(1 downto 0);
  signal ev_slots_underflow_i_pipe      : std_logic_vector(1 downto 0);
  signal ev_buffer_overflow_pipe        : std_logic_vector(1 downto 0);
  signal raw_underflow_pipe : std_logic_vector(1 downto 0);
  signal ev_slots_underflow_pipe : std_logic_vector(1 downto 0);
  signal ptr_underflow_pipe      : std_logic_vector(1 downto 0);
  signal ptr_overflow_pipe       : std_logic_vector(1 downto 0);
  signal Raw_buffer_overflow_pipe: std_logic_vector(1 downto 0);

  signal DDR_LOCAL_REGS_TP_3_i : std_logic;
  type REGS_ARRAY_TYP is array(natural range 0 to 39) of unsigned(15 downto 0); -- 15/05/2017
  signal mon_a_0, mon_a : REGS_ARRAY_TYP;

  -- 19/12/2017
  signal ddr_driver_stop_scan, ddr_driver_stop_scan_64m : std_logic;
  signal ev_stop_scan, ev_stop_scan_64m		  : std_logic;
  signal ptr_stop_scan, ptr_stop_scan_64m	  : std_logic;

begin


  -- Purpose: check raw_buffer_overflow, when write to RAW buffer
  raw_addr_cmp_pr : process (RESET_128, TOP_CLK_MEM_128M) is
  begin  -- process raw_addr_cmp_pr
    if RESET_128 = '0' then               -- asynchronous reset (active low)

		raw_addr_cmp_result <= (others => '1');
		raw_addr_occupied   <= (others => '0');

		raw_buffer_overflow_i <= '0';
		stop_scan_highbound 		<= '0';
		stop_scan_lowbound 			<= '0';
		ddr_driver_stop_scan 		<= '1';  -- Debugged by Meital R. used to be set to '0' after RESET, which is incorrect since this signal is active low
		Raw_Buffer_underrun_interrupt <='0';
		ddr_driver_stop_scan_interrupt <= '0';
		Raw_buffer_underrun_relevant   <= FALSE;

    elsif TOP_CLK_MEM_128M'EVENT and TOP_CLK_MEM_128M = '1' then  -- rising clock edge

      if (raw_addr_occupied > RAW_BUFFER_UNDERRUN_LIMIT) then
      	Raw_buffer_underrun_relevant <= TRUE;
      end if;

      if (RAW_READING_RAW_DATA_ADDR < READ_READING_RAW_DATA_ADDR) then  --128MHz

        raw_addr_cmp_result <= READ_READING_RAW_DATA_ADDR - RAW_READING_RAW_DATA_ADDR;

		raw_addr_occupied   <= (READ_READING_RAW_DATA_ADDR - RAW_DATA_BASE_ADDR) +   -- occupied addressess
                               (RAW_DATA_END_ADDR - RAW_READING_RAW_DATA_ADDR);

      elsif (RAW_READING_RAW_DATA_ADDR > READ_READING_RAW_DATA_ADDR) then

        raw_addr_occupied <= READ_READING_RAW_DATA_ADDR - RAW_READING_RAW_DATA_ADDR;  -- occupied addressess

        raw_addr_cmp_result <= (READ_READING_RAW_DATA_ADDR - RAW_DATA_BASE_ADDR) +
                               (RAW_DATA_END_ADDR - RAW_READING_RAW_DATA_ADDR);

      else

		raw_addr_occupied   <= (others => '0');

        raw_addr_cmp_result <= RAW_DATA_END_ADDR - RAW_DATA_BASE_ADDR;

      end if;


---------------------------------------
-- HW overflow (Memory overwritten).

      if (raw_addr_cmp_result < RAW_DATA_OVERFLOW_THRESHOLD) and ( CENTRAL_INTERFACE_SETUP_VALID = '1' ) then -- max bundle -- used to be and ( CENTRAL_INTERFACE_SETUP_VALID = '1' )
        raw_buffer_overflow_i <= '1';                                -- ?check: clear
      else
        raw_buffer_overflow_i <= '0';
      end if;

      if (raw_addr_cmp_result < DDR_DRIVER_STOP_SCAN_HIGHBOUND)   then -- trigger stop_scan on -- used to be and ( CENTRAL_INTERFACE_SETUP_VALID = '1' )
        stop_scan_highbound <= '1';                         		-- trigger stop_scan ON
      else
        stop_scan_highbound <= '0';
      end if;

      if (raw_addr_cmp_result < DDR_DRIVER_STOP_SCAN_LOWBOUND) then
        stop_scan_lowbound <= '1';
      else
        stop_scan_lowbound <= '0';      							-- trigger stop_scan OFF
      end if;

      if (stop_scan_highbound = '1') and ( CENTRAL_INTERFACE_SETUP_VALID = '1' ) then
		ddr_driver_stop_scan <= '0'; 								-- active low
	  elsif (stop_scan_lowbound = '0') then
		ddr_driver_stop_scan <= '1';
	  end if;

      if (raw_addr_cmp_result < DDR_DRIVER_STOP_SCAN_HIGHBOUND) and ( CENTRAL_INTERFACE_SETUP_VALID = '1' )  then -- trigger stop_scan INTERRUPT ON -- and ( CENTRAL_INTERFACE_SETUP_VALID = '1' )
		  ddr_driver_stop_scan_interrupt <= '1';
      else
		  ddr_driver_stop_scan_interrupt <= '0';
      end if;


      -- Underrun condition detection

      if ((raw_addr_occupied < RAW_BUFFER_UNDERRUN_LIMIT) and Raw_buffer_underrun_relevant and CENTRAL_INTERFACE_SETUP_VALID = '1')  then

        Raw_Buffer_underrun_interrupt <= '1';
                                      -- ?check: clear
      else

        Raw_Buffer_underrun_interrupt <= '0';

      end if;



    end if;
  end process raw_addr_cmp_pr;


	-- STOP_SCAN interrupts
	stop_scan_interrupt_pulse <= bool2std( rise_detect( ddr_driver_stop_scan_pipe ) );
    EV_stop_scan_interrupt_pulse <= bool2std( rise_detect( EV_stop_scan_pipe ) );
    ptr_stop_scan_interrupt_pulse <= bool2std( rise_detect( PTR_stop_scan_pipe ) );
    -- EV Buffer
    ev_slots_overflow_pulse <= bool2std( rise_detect(ev_slots_overflow_i_pipe ) );
    ev_slots_underflow_pulse <= bool2std( rise_detect(ev_slots_underflow_pipe));
    -- PTR Buffer
    ptr_underflow_pulse      <= bool2std( rise_detect(ptr_underflow_pipe));
    ptr_overflow_pulse       <= bool2std( rise_detect(ptr_overflow_pipe));
    -- Raw Buffer
    Raw_overflow_pulse       <= bool2std( rise_detect(Raw_buffer_overflow_pipe));
    Raw_Buffer_underrun_interrupt_pulse <= bool2std( rise_detect(  raw_underflow_pipe ) );


  -- Purpose: check ev_buffer_overflow, when write to EV buffer
  ev_addr_cmp_pr : process (RESET_128, TOP_CLK_MEM_128M) is
  begin  -- process ev_addr_cmp_pr
    if RESET_128 = '0' then               -- asynchronous reset (active low)

      ev_addr_cmp_result <= (others => '1');
      ev_buffer_overflow_i <= '0';

    elsif TOP_CLK_MEM_128M'EVENT and TOP_CLK_MEM_128M = '1' then  -- rising clock edge

      if (EV_READING_EV_DATA_ADDR < READ_READING_EV_DATA_ADDR) then  --128MHz

        ev_addr_cmp_result <= READ_READING_EV_DATA_ADDR - EV_READING_EV_DATA_ADDR;

      elsif (EV_READING_EV_DATA_ADDR > READ_READING_EV_DATA_ADDR) then

        ev_addr_cmp_result <= (READ_READING_EV_DATA_ADDR - EV_DATA_BASE_ADDR) +
                               (EV_DATA_END_ADDR - EV_READING_EV_DATA_ADDR);

      else

        ev_addr_cmp_result <= EV_DATA_END_ADDR - EV_DATA_BASE_ADDR;

      end if;

      if (ev_addr_cmp_result < EV_DATA_OVERFLOW_THRESHOLD) then
        ev_buffer_overflow_i <= '1';                                -- ?check: clear
      else
        ev_buffer_overflow_i <= '0';
      end if;


    end if;
  end process ev_addr_cmp_pr;


  -- Purpose: check ptr_buffer (fifo_buffer) overflow, when write to RAW buffer
  ptr_addr_cmp_pr : process (RESET_128, TOP_CLK_MEM_128M) is
  begin  -- process ptr_addr_cmp_pr
    if RESET_128 = '0' then               -- asynchronous reset (active low)

      sorter_pre_frame_start_r      <= "000";
      ptr_addr_cmp_result           <= (others => '1');
      ptr_addr_cmp_result_r         <= (others => '1');
      ptr_addr_cmp_underflow_result <= (others => '0');
      ptr_buffer_overflow_i         <= '0';
      ptr_buffer_underflow_i        <= '0';
      ptr_stop_scan_interrupt       <= '0';

      ptr_buffer_overflow_cnt <= 0;
      ptr_buffer_overflow_r   <= '0';
      memory_goes_fill        <= FALSE;
      Ptr_underrun_relevant   <= FALSE;
      ptr_stop_scan                 <= '1';
      ptr_stop_scan_lowbound        <= '0';
      ptr_stop_scan_highbound       <= '0';


    elsif TOP_CLK_MEM_128M'EVENT and TOP_CLK_MEM_128M = '1' then  -- rising clock edge

      if (ptr_addr_cmp_result > to_unsigned(7, ptr_addr_cmp_result'LENGTH) and
          ptr_addr_cmp_result < to_unsigned(32, ptr_addr_cmp_result'LENGTH)) then
        memory_goes_fill <= TRUE;
      end if;

      sorter_pre_frame_start_r <= sorter_pre_frame_start_r(1 downto 0) &
                                  DATA_SORTER_PRE_FRAME_START;  -- 64MHz input

      ptr_buffer_overflow_r <= ptr_buffer_overflow_i;

      if (ptr_addr_cmp_result < PTR_OVERFLOW_THRESHOLD )then
--          and sorter_pre_frame_start_r = "110" and INIT_DONE_ALL_O = '1')
															  -- 64MHz, need sync
        ptr_buffer_overflow_i <= '1';
      else
        ptr_buffer_overflow_i <= '0';
      end if;


      if (ptr_addr_cmp_result < PTR_BUFFER_STOP_SCAN_HIGHBOUND)  then -- trigger stop_scan on
        ptr_stop_scan_highbound <= '1';                         		-- trigger stop_scan ON
      else
        ptr_stop_scan_highbound <= '0';
      end if;

      if (ptr_addr_cmp_result < PTR_BUFFER_STOP_SCAN_LOWBOUND) then
        ptr_stop_scan_lowbound <= '1';
      else
        ptr_stop_scan_lowbound <= '0'; -- trigger stop_scan OFF
      end if;

      if (ptr_stop_scan_highbound = '1') then
		ptr_stop_scan <= '0';-- active low
	  elsif (ptr_stop_scan_lowbound = '0') then
		ptr_stop_scan <= '1';
	  end if;

      if (ptr_addr_cmp_result < PTR_BUFFER_STOP_SCAN_HIGHBOUND)  then -- trigger stop_scan INTERRUPT ON
		  ptr_stop_scan_interrupt <= '1';
      else
		  ptr_stop_scan_interrupt <= '0';
      end if;




      if (ptr_buffer_overflow_r = '0' and ptr_buffer_overflow_i = '1' and
          ptr_buffer_overflow_cnt < 15) then
        ptr_buffer_overflow_cnt <= ptr_buffer_overflow_cnt + 1;  -- !debug: test counter
      end if;

      if (ptr_addr_cmp_underflow_result > PTR_UNDERRUN_LIMIT) then
      	Ptr_underrun_relevant <= TRUE;
      end if;


      if (RAW_READING_ADDR_FIFO_ADDR < READ_READING_ADDR_FIFO_ADDR) then

        ptr_addr_cmp_result <= READ_READING_ADDR_FIFO_ADDR - RAW_READING_ADDR_FIFO_ADDR;


        ptr_addr_cmp_underflow_result <=
          (RAW_READING_ADDR_FIFO_ADDR - ADDR_FIFO_BASE_ADDR) +
          (ADDR_FIFO_END_ADDR - READ_READING_ADDR_FIFO_ADDR);

      elsif (RAW_READING_ADDR_FIFO_ADDR > READ_READING_ADDR_FIFO_ADDR) then

        ptr_addr_cmp_result <=
          (READ_READING_ADDR_FIFO_ADDR - ADDR_FIFO_BASE_ADDR) +
          (ADDR_FIFO_END_ADDR - RAW_READING_ADDR_FIFO_ADDR);


        ptr_addr_cmp_underflow_result <= RAW_READING_ADDR_FIFO_ADDR -
                                         READ_READING_ADDR_FIFO_ADDR;

      else

        ptr_addr_cmp_result <= ADDR_FIFO_END_ADDR - ADDR_FIFO_BASE_ADDR;  -- all buffer
                                                                          -- enabled for writing

        ptr_addr_cmp_underflow_result <= unsigned'(DDR3_ADDR_BUS_TYP'REVERSE_RANGE => '0');

      end if;

      if (ptr_addr_cmp_underflow_result < PTR_UNDERFLOW_THRESHOLD) and ( Ptr_underrun_relevant ) then
        ptr_buffer_underflow_i <= '1';
      else
        ptr_buffer_underflow_i <= '0';
      end if;

      ptr_addr_cmp_result_r <= ptr_addr_cmp_result;

    end if;
  end process ptr_addr_cmp_pr;


  ev_slotnum_cmp_pr : process (RESET_128, TOP_CLK_MEM_128M) is
  begin  -- process ev_slotnum_cmp_pr
    if RESET_128 = '0' then               -- asynchronous reset (active low)

      evolving_pre_frame_start_r      <= "000";
      ev_slotnum_cmp_result           <= (others => '1');
      ev_slotnum_cmp_underflow_result <= (others => '0');
      ev_slots_overflow_i           <= '0';
      ev_slots_underflow_i          <= '0';
      EV_stop_scan_interrupt        <= '0';
      -- EV_DATA_STOP_SCAN_INTERRUPT   <= EV_NUM_OF_SLOTS - EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_INIT;
      -- EV_DATA_STOP_SCAN_HIGHBOUND   <= EV_NUM_OF_SLOTS - EVOLVING_STOP_IP_HIGH_LIMIT_INIT;
      -- EV_DATA_STOP_SCAN_LOWBOUND    <= EV_NUM_OF_SLOTS - EVOLVING_STOP_IP_LOW_LIMIT_INIT;
      Ev_underrun_relevant <= FALSE;
      ev_stop_scan                  <= '1';
      ev_stop_scan_highbound        <= '0';
      ev_stop_scan_lowbound         <= '0';

    elsif TOP_CLK_MEM_128M'EVENT and TOP_CLK_MEM_128M = '1' then  -- rising clock edge

      evolving_pre_frame_start_r <= evolving_pre_frame_start_r(1 downto 0) &
                                  EVOLVING_PRE_FRAME_START;  -- 64MHz input

      if (ev_slotnum_cmp_result < EV_OVERFLOW_LIMIT -- Evolving overflow was changed to 80 available readings on 14/2/08
--          and evolving_pre_frame_start_r(2 downto 1) = "11")
          ) then
        ev_slots_overflow_i <= '1';     -- !debug
      else
        ev_slots_overflow_i <= '0';
      end if;

      if (ev_slotnum_cmp_underflow_result > EV_UNDERRUN_LIMIT) then
      	Ev_underrun_relevant <= TRUE;
      end if;


      if (EV_READING_EV_SLOTNUM < READ_READING_EV_SLOTNUM) then

        ev_slotnum_cmp_result <= READ_READING_EV_SLOTNUM - EV_READING_EV_SLOTNUM;

        ev_slotnum_cmp_underflow_result <=
          EV_READING_EV_SLOTNUM + (to_unsigned(EV_NUM_OF_SLOTS, EV_BUFFER_SLOTS_TYP'LENGTH) - READ_READING_EV_SLOTNUM);

      elsif (EV_READING_EV_SLOTNUM > READ_READING_EV_SLOTNUM) then

        ev_slotnum_cmp_result <=
          READ_READING_EV_SLOTNUM + (to_unsigned(EV_NUM_OF_SLOTS, EV_BUFFER_SLOTS_TYP'LENGTH) - EV_READING_EV_SLOTNUM);


        ev_slotnum_cmp_underflow_result <= EV_READING_EV_SLOTNUM -
                                         READ_READING_EV_SLOTNUM;

      else

        ev_slotnum_cmp_result <= to_unsigned(EV_NUM_OF_SLOTS, EV_BUFFER_SLOTS_TYP'LENGTH);  -- all buffer enabled for writing

        ev_slotnum_cmp_underflow_result <= to_unsigned(0, EV_BUFFER_SLOTS_TYP'LENGTH);

      end if;


      if (ev_slotnum_cmp_underflow_result < EV_SLOTS_UNDERFLOW_THRESHOLD) and ( Ev_underrun_relevant ) then
        ev_slots_underflow_i <= '1';
      else
        ev_slots_underflow_i <= '0';
      end if;

-------Added by MeitalR ----------------
      if (ev_slotnum_cmp_result < EV_DATA_STOP_SCAN_HIGHBOUND)  then -- trigger stop_scan on
        ev_stop_scan_highbound <= '1';                         		-- trigger stop_scan ON
      else
        ev_stop_scan_highbound <= '0';
      end if;

      if (ev_slotnum_cmp_result < EV_DATA_STOP_SCAN_LOWBOUND) then
        ev_stop_scan_lowbound <= '1';
      else
        ev_stop_scan_lowbound <= '0';      							-- trigger stop_scan OFF
      end if;

      if (ev_stop_scan_highbound = '1') then
		ev_stop_scan <= '0'; 								-- active low
	  elsif (ev_stop_scan_lowbound = '0') then
		ev_stop_scan <= '1';
	  end if;
      if (ev_slotnum_cmp_result < EV_DATA_STOP_SCAN_HIGHBOUND)  then -- trigger stop_scan INTERRUPT ON
		  ev_stop_scan_interrupt <= '1';
      else
		  ev_stop_scan_interrupt <= '0';
      end if;

    end if;
  end process ev_slotnum_cmp_pr;


  -- purpose: sampling from/to local controller
  local_regs_pr : process (RESET_I, SYSTEM_CLK64_I) is
    variable local_address_natural : natural;
  begin  -- process local_regs_pr
    if RESET_I = '0' then


      PORT_A_D_B_OUT <= (others => '0');  -- !check, what default value
      Bi_Dir_Direction <= '0';

      buffer_control_unmasked_interrupt_reg_reg    <= (others => '0');   -- !check, for ALL registers what default value
      buffer_control_interrupt_mask_register_reg   <= (others => '0'); -- Since 02/07/08 default value on power up is disabling the interrupts --> Masking! (done as SW demand)
      buffer_status_lsb_reg                        <= (others => '0');
      buffer_status_msb_reg                        <= (others => '0');
      ev_buffer_status_reg                         <= (others => '0');
      reading_pointer_buffer_status_lsb_reg        <= (others => '0');
      reading_pointer_buffer_status_msb_reg        <= (others => '0');
      raw_fifo_status_reg                          <= (others => '0');
      ev_fifo_status_reg                           <= (others => '0');
      comm_tx_fifo_status_reg                      <= (others => '0');
      raw_write_pointer_lsb_reg                    <= (others => '0');
      raw_write_pointer_msb_reg                    <= (others => '0');
      evolving_write_pointer_lsb_reg               <= (others => '0');
      evolving_write_pointer_msb_reg               <= (others => '0');
      comm_tx_raw_read_pointer_lsb_reg             <= (others => '0');
      comm_tx_raw_read_pointer_msb_reg             <= (others => '0');
      comm_tx_ev_read_pointer_lsb_reg              <= (others => '0');
      comm_tx_ev_read_pointer_msb_reg              <= (others => '0');
      ddr2_device_test_status_reg                  <= (others => '0');
      ddr2_address_test_status_lsb_reg             <= (others => '0');
      ddr2_address_test_status_msb_reg             <= (others => '0');
      ecc_error_chip_number_reg                    <= (others => '0');
      ecc_error_address_lsb_reg                    <= (others => '0');
      ecc_error_address_msb_reg                    <= (others => '0');
      ecc_corrected_errors_counter_reg             <= (others => '0');
      ecc_errors_counter_reg                       <= (others => '0');
      ecc_error_injection_reg                      <= (others => '0');
      ddr_driver_control_reg                       <= (others => '0'); -- !debug: 19/12/2017 was X"8000", seems need when disabled test block
      raw_wr_counter_lsb_reg                       <= (others => '0');
      raw_wr_counter_msb_reg                       <= (others => '0');
      ev_wr_counter_lsb_reg                        <= (others => '0');
      ev_wr_counter_msb_reg                        <= (others => '0');
      raw_rd_counter_lsb_reg                       <= (others => '0');
      raw_rd_counter_msb_reg                       <= (others => '0');
      ev_rd_counter_lsb_reg                        <= (others => '0');
      ev_rd_counter_msb_reg                        <= (others => '0');
      -- periph_la_depth_reg                          <= unsigned'(X"007F"); -- !debug
      -- periph_la_data_lsb_reg                       <= (others => '0');
      -- periph_la_data_msb_reg                       <= (others => '0');
      EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_reg  <= EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_INIT;
      EVOLVING_STOP_IP_HIGH_LIMIT_reg              <= EVOLVING_STOP_IP_HIGH_LIMIT_INIT;
      EVOLVING_STOP_IP_LOW_LIMIT_reg               <= EVOLVING_STOP_IP_LOW_LIMIT_INIT;


      DDR_DRIVER_ACK <= '1';
      write_ack <= '1';
      ecc_corrected_errors_counter_reset <= FALSE;
      ecc_errors_counter_reset <= FALSE;
      la_incr <= FALSE;


    elsif SYSTEM_CLK64_I'EVENT and SYSTEM_CLK64_I = '1' then  -- system clock 64MHz

      ecc_corrected_errors_counter_reset <= FALSE;
      ecc_errors_counter_reset <= FALSE;

      local_address_natural := to_integer(local_address(11 downto 0));


      -- Reading from registers
      if (PORTS_CLK_LAUNCH_EN = '1') then

        DDR_DRIVER_ACK <= write_ack; -- write_ack synced to PORTS_CLK_LAUNCH_EN

        PORT_A_D_B_OUT <= (others => '0');
        Bi_Dir_Direction <= '0';

        la_incr <= FALSE;

        if (do_read_r) then  -- read from local registers, one port clock pulse

          DDR_DRIVER_ACK <= '0';        -- ack after read operation

          case local_address_natural is
            when BUFFER_CONTROL_INTERRUPT_REG_LSB_ADDR =>  -- !debug, now UNMASKED!!!
              PORT_A_D_B_OUT <= std_logic_vector(buffer_control_unmasked_interrupt_reg_reg(15 downto 0) );
              Bi_Dir_Direction <= '1';
            when BUFFER_CONTROL_INTERRUPT_REG_MSB_ADDR =>  -- !debug, now UNMASKED!!!
              PORT_A_D_B_OUT <= std_logic_vector(buffer_control_unmasked_interrupt_reg_reg(31 downto 16) );
              Bi_Dir_Direction <= '1';
            when BUFFER_CONTROL_INTERRUPT_MASKED_LSB_ADDR =>  -- !debug, now MASKED!!!
              PORT_A_D_B_OUT <= std_logic_vector(buffer_control_interrupt_status_register_reg(15 downto 0) );
              Bi_Dir_Direction <= '1';
            when BUFFER_CONTROL_INTERRUPT_MASKED_MSB_ADDR =>  -- !debug, now MASKED!!!
              PORT_A_D_B_OUT <= std_logic_vector(buffer_control_interrupt_status_register_reg(31 downto 16) );
              Bi_Dir_Direction <= '1';
            when BUFFER_CONTROL_INTERRUPT_MASK_REGISTER_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(buffer_control_interrupt_mask_register_reg(15 downto 0) );
              Bi_Dir_Direction <= '1';
            when BUFFER_CONTROL_INTERRUPT_MASK_REGISTER_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(buffer_control_interrupt_mask_register_reg(31 downto 16) );
              Bi_Dir_Direction <= '1';

            when BUFFER_STATUS_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(buffer_status_lsb_reg);
              Bi_Dir_Direction <= '1';

            when BUFFER_STATUS_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(buffer_status_msb_reg);
              Bi_Dir_Direction <= '1';

            when EV_BUFFER_STATUS_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ev_buffer_status_reg);
              Bi_Dir_Direction <= '1';

            when READING_POINTER_BUFFER_STATUS_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(reading_pointer_buffer_status_lsb_reg);
              Bi_Dir_Direction <= '1';

            when READING_POINTER_BUFFER_STATUS_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(reading_pointer_buffer_status_msb_reg);
              Bi_Dir_Direction <= '1';

            when RAW_FIFO_STATUS_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(raw_fifo_status_reg);
              Bi_Dir_Direction <= '1';

            when EV_FIFO_STATUS_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ev_fifo_status_reg);
              Bi_Dir_Direction <= '1';

            when COMM_TX_FIFO_STATUS_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(comm_tx_fifo_status_reg);
              Bi_Dir_Direction <= '1';

            when RAW_WRITE_POINTER_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(raw_write_pointer_lsb_reg);
              Bi_Dir_Direction <= '1';

            when RAW_WRITE_POINTER_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(raw_write_pointer_msb_reg);
              Bi_Dir_Direction <= '1';

            when EVOLVING_WRITE_POINTER_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(evolving_write_pointer_lsb_reg);
              Bi_Dir_Direction <= '1';

            when EVOLVING_WRITE_POINTER_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(evolving_write_pointer_msb_reg);
              Bi_Dir_Direction <= '1';

            when COMM_TX_RAW_READ_POINTER_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(comm_tx_raw_read_pointer_lsb_reg);
              Bi_Dir_Direction <= '1';

            when COMM_TX_RAW_READ_POINTER_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(comm_tx_raw_read_pointer_msb_reg);
              Bi_Dir_Direction <= '1';

            when COMM_TX_EV_READ_POINTER_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(comm_tx_ev_read_pointer_lsb_reg);
              Bi_Dir_Direction <= '1';

            when COMM_TX_EV_READ_POINTER_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(comm_tx_ev_read_pointer_msb_reg);
              Bi_Dir_Direction <= '1';

            when DDR2_DEVICE_TEST_STATUS_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ddr2_device_test_status_reg);
              Bi_Dir_Direction <= '1';

            when DDR2_ADDRESS_TEST_STATUS_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ddr2_address_test_status_lsb_reg);
              Bi_Dir_Direction <= '1';

            when DDR2_ADDRESS_TEST_STATUS_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ddr2_address_test_status_msb_reg);
              Bi_Dir_Direction <= '1';

            when ECC_ERROR_CHIP_NUMBER_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(ecc_error_chip_number_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when ECC_ERROR_ADDRESS_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ecc_error_address_lsb_reg);
              Bi_Dir_Direction <= '1';

            when ECC_ERROR_ADDRESS_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ecc_error_address_msb_reg);
              Bi_Dir_Direction <= '1';

            when ECC_CORRECTED_ERRORS_COUNTER_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ecc_corrected_errors_counter_reg);
              Bi_Dir_Direction <= '1';

            when ECC_ERRORS_COUNTER_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(ecc_errors_counter_reg);
              Bi_Dir_Direction <= '1';

            when ECC_ERROR_INJECTION_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(ecc_error_injection_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when RAW_WR_COUNTER_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(raw_wr_counter_lsb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when RAW_WR_COUNTER_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(raw_wr_counter_msb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when EV_WR_COUNTER_LSB_ADDR  =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(ev_wr_counter_lsb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when EV_WR_COUNTER_MSB_ADDR  =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(ev_wr_counter_msb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when RAW_RD_COUNTER_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(raw_rd_counter_lsb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when RAW_RD_COUNTER_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(raw_rd_counter_msb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when EV_RD_COUNTER_LSB_ADDR  =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(ev_rd_counter_lsb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when EV_RD_COUNTER_MSB_ADDR  =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(ev_rd_counter_msb_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when DDR_DRIVER_CONTROL_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(ddr_driver_control_reg, PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when DDR_DRIVER_DATE_LSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(CURRENT_DATE_PARAM(15 downto 0), PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when DDR_DRIVER_DATE_MSB_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(CURRENT_DATE_PARAM(CURRENT_DATE_PARAM'LEFT downto 16),
                                                    PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            -- when PERIPH_LA_DEPTH_ADDR =>
            --   PORT_A_D_B_OUT <= std_logic_vector(periph_la_depth_reg);
            --   Bi_Dir_Direction <= '1';
            --
            -- when PERIPH_LA_DATA_LSB_ADDR =>
            --   PORT_A_D_B_OUT <= std_logic_vector(periph_la_data_lsb_reg);
            --   Bi_Dir_Direction <= '1';
            --
            -- when PERIPH_LA_DATA_MSB_ADDR =>
            --   PORT_A_D_B_OUT <= std_logic_vector(periph_la_data_msb_reg);
            --   Bi_Dir_Direction <= '1';
            --   la_incr <= TRUE;          -- read sequence lsb->msb->inc

            when EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_reg,PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when EVOLVING_STOP_IP_HIGH_LIMIT_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(EVOLVING_STOP_IP_HIGH_LIMIT_reg,PORT_A_D_B_OUT'LENGTH));
			  Bi_Dir_Direction <= '1';

            when EVOLVING_STOP_IP_LOW_LIMIT_ADDR =>
              PORT_A_D_B_OUT <= std_logic_vector(resize(EVOLVING_STOP_IP_LOW_LIMIT_reg,PORT_A_D_B_OUT'LENGTH));
              Bi_Dir_Direction <= '1';

            when others =>
              PORT_A_D_B_OUT <= ( others => '0' );
              DDR_DRIVER_ACK <= '1';
          end case;

        end if;
      end if;

      -- Writing to registers:
      if (PORTS_CLK_EN = '1') then  -- enable 16MHz --and DDR_DRIVER_CS = LOCAL_BUS_CS_POLARITY

        write_ack <= '1';

        if (do_write) then  -- write to local registers from TDMC !!!debug

          if (local_address_natural = BUFFER_CONTROL_INTERRUPT_REG_LSB_ADDR) then
          -- Changed by MeitalR 10/12/07
				buffer_control_unmasked_interrupt_reg_reg(15 downto 0) <=
          		buffer_control_unmasked_interrupt_reg_reg(15 downto 0) and not unsigned(PORT_A_D_B_IN(15 downto 0));


			Bi_Dir_Direction <= '0';

--             buffer_control_unmasked_interrupt_reg_reg(15) <= PORT_A_D_B_IN(15); -- injection interrupt -- Canceled Ran 17-Sep-2007
            write_ack <= '0';        -- ack after write operation
          end if;

          if (local_address_natural = BUFFER_CONTROL_INTERRUPT_REG_MSB_ADDR) then
          -- Changed by MeitalR 12/03/08
                    -- Software can clear SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT or SDRAM_EV_BUFFER_STOP_SCAN_BIT only if the interrupt is gone!

          	if(ddr_driver_stop_scan_64m = '1') then
          		buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT) <=
          		buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT) and not PORT_A_D_B_IN(SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT);
          	end if;

          	if(ev_stop_scan_64m = '1') then
          		buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_EV_BUFFER_STOP_SCAN_BIT) <=
          		buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_EV_BUFFER_STOP_SCAN_BIT) and not PORT_A_D_B_IN(SDRAM_EV_BUFFER_STOP_SCAN_BIT);
          	end if;

          -- Software can clear SDRAM_PTR_BUFFER_OVERFLOW_STOP_SCAN only if the interrupt is gone!
          	if( ptr_stop_scan_64m = '1') then
          		buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_PTR_BUFFER_OVERFLOW_STOP_SCAN_BIT) <=
          		buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_PTR_BUFFER_OVERFLOW_STOP_SCAN_BIT) and not PORT_A_D_B_IN(SDRAM_PTR_BUFFER_OVERFLOW_STOP_SCAN_BIT);
          	end if;
				-- bit no. 3 at register 890A10 can be reset only if the bit is not active, by SW.
            	buffer_control_unmasked_interrupt_reg_reg(31 downto 22) <=
              	buffer_control_unmasked_interrupt_reg_reg(31 downto 22) and not unsigned(PORT_A_D_B_IN(15 downto 6)); --- clear only the rest of the bits!

                buffer_control_unmasked_interrupt_reg_reg(18 downto 16) <=
              	buffer_control_unmasked_interrupt_reg_reg(18 downto 16) and not unsigned(PORT_A_D_B_IN(2 downto 0));--- clear only the rest of the bits!


            Bi_Dir_Direction <= '0';
            write_ack <= '0';        -- ack after write operation
          end if;

          DDR_LOCAL_REGS_TP_3_i <= '0';
          if (local_address_natural = BUFFER_CONTROL_INTERRUPT_MASK_REGISTER_LSB_ADDR) then
            buffer_control_interrupt_mask_register_reg(15 downto 0) <= unsigned(PORT_A_D_B_IN);
            Bi_Dir_Direction <= '0';
            write_ack <= '0';        -- ack after write operation
            DDR_LOCAL_REGS_TP_3_i <= '1';
          end if;

          if (local_address_natural = BUFFER_CONTROL_INTERRUPT_MASK_REGISTER_MSB_ADDR) then
            buffer_control_interrupt_mask_register_reg(31 downto 16) <= unsigned(PORT_A_D_B_IN);
            Bi_Dir_Direction <= '0';
            write_ack <= '0';        -- ack after write operation
          end if;

          if (local_address_natural = ECC_CORRECTED_ERRORS_COUNTER_ADDR) then
            ecc_corrected_errors_counter_reset <= TRUE; -- writing resets counter
            Bi_Dir_Direction <= '0';
            write_ack <= '0';        -- ack after write operation
          end if;

          if (local_address_natural = ECC_ERRORS_COUNTER_ADDR) then
            ecc_errors_counter_reset <= TRUE; -- writing resets counter
            Bi_Dir_Direction <= '0';
            write_ack <= '0';        -- ack after write operation
          end if;

          -- ECC error injection, register 0x0CE
          -- !debug, size changed. Add bits 8..2 - error_mask value
          if (local_address_natural = ECC_ERROR_INJECTION_ADDR) then
            ecc_error_injection_reg(1 downto 0) <= unsigned(PORT_A_D_B_IN(1 downto 0));
            Bi_Dir_Direction <= '0';
            write_ack <= '0';        -- ack after write operation
          end if;

          if (local_address_natural = DDR_DRIVER_CONTROL_ADDR) then
            -- Bits:

            -- 0 - Disable Refresh to DDR2 SDRAM
            -- 1 - Execute Full Memory Test
            -- 3 - Inject extra word into COMM_TX_FIFO (RanF)
            --
            -- 4 - Disable RAW request (RAW FIFO overflow check)
            -- 5 - Disable EV request (EV FIFO overflow check)
            -- 6 - Disable read from memory buffers request (memory buffer overflow check)
            --
            -- 13 – Test Interrupted. (Read Only)
            -- 14 – Test successful (Read Only).
            -- 15 – Mem test done.(Read Only).

            ddr_driver_control_reg(11 downto 0) <= unsigned(PORT_A_D_B_IN(11 downto 0));
            Bi_Dir_Direction <= '0';

            write_ack <= '0';        -- ack after write operation
          end if;


          if (local_address_natural = EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_ADDR) then
          	EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_reg <= unsigned(PORT_A_D_B_IN(7 downto 0));
          	Bi_Dir_Direction <= '0';
          	write_ack <= '0';
          end if;

          if (local_address_natural = EVOLVING_STOP_IP_HIGH_LIMIT_ADDR) then
            EVOLVING_STOP_IP_HIGH_LIMIT_reg <= unsigned(PORT_A_D_B_IN(7 downto 0));
          	Bi_Dir_Direction <= '0';
          	write_ack <= '0';
          end if;

          if (local_address_natural = EVOLVING_STOP_IP_LOW_LIMIT_ADDR) then
            EVOLVING_STOP_IP_LOW_LIMIT_reg <=  unsigned(PORT_A_D_B_IN(7 downto 0));
          	Bi_Dir_Direction <= '0';
          	write_ack <= '0';
          end if;
        else                            -- update registers from ddr_driver blocks

          -----------------------------------------------------------------------------------------
          -- Unmasked Buffer Control Interrupt Status Register (active level '1'), register 0x0A0
          -- (look TDMC HRS Figure 3 - Interrupt Scheme), clear only by reset
          -- buffer_control_unmasked_interrupt_reg_reg

          buffer_control_unmasked_interrupt_reg_reg(RAW_INPUT_FIFO_OVERFLOW_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(RAW_INPUT_FIFO_OVERFLOW_BIT) or RAW_FIFO_OVERFLOW;  --64MHz
          buffer_control_unmasked_interrupt_reg_reg(EV_INPUT_FIFO_OVERFLOW_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(EV_INPUT_FIFO_OVERFLOW_BIT) or EV_FIFO_OVERFLOW; --64MHz
          buffer_control_unmasked_interrupt_reg_reg(COMM_TX_OUTPUT_FIFO_OVERFLOW_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(COMM_TX_OUTPUT_FIFO_OVERFLOW_BIT) or READ_FIFO_OVERFLOW; --64MHz

          buffer_control_unmasked_interrupt_reg_reg(SDRAM_RAW_BUFFER_OVERFLOW_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(SDRAM_RAW_BUFFER_OVERFLOW_BIT) or Raw_overflow_pulse;
          buffer_control_unmasked_interrupt_reg_reg(SDRAM_EV_BUFFER_OVERFLOW_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(SDRAM_EV_BUFFER_OVERFLOW_BIT) or ev_slots_overflow_pulse;
          buffer_control_unmasked_interrupt_reg_reg(SDRAM_READING_POINTER_BUFFER_OVERFLOW_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(SDRAM_READING_POINTER_BUFFER_OVERFLOW_BIT) or ptr_overflow_pulse;
          buffer_control_unmasked_interrupt_reg_reg(RAW_FSM_ERROR_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(RAW_FSM_ERROR_BIT) or RAW_FSM_ERROR;
          buffer_control_unmasked_interrupt_reg_reg(EV_FSM_ERROR_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(EV_FSM_ERROR_BIT) or EV_FSM_ERROR;
          buffer_control_unmasked_interrupt_reg_reg(COMM_TX_FSM_ERROR_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(COMM_TX_FSM_ERROR_BIT) or READ_FSM_ERROR;  --64MHz
          buffer_control_unmasked_interrupt_reg_reg(ECC_UNRECOVERABLE_ERROR_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(ECC_UNRECOVERABLE_ERROR_BIT) or READ_ECC_ERROR; -- READ_ECC_ERROR is raised up when ecc error was detected, and fall down when next reading begin
          buffer_control_unmasked_interrupt_reg_reg(COMM_TX_MODULE_DATA_BURST_FIFO_NOT_EMPTIED_BIT)           <=
            buffer_control_unmasked_interrupt_reg_reg(COMM_TX_MODULE_DATA_BURST_FIFO_NOT_EMPTIED_BIT) or READ_FIFO_NOTEMPTY;  --64MHz
          buffer_control_unmasked_interrupt_reg_reg(NEW_FRAME_WHILE_RAW_FIFO_NOT_EMPTY_BIT)           <=
            buffer_control_unmasked_interrupt_reg_reg(NEW_FRAME_WHILE_RAW_FIFO_NOT_EMPTY_BIT) or RAW_FIFO_NOTEMPTY;  --64MHz
          buffer_control_unmasked_interrupt_reg_reg(NEW_FRAME_WHILE_EV_FIFO_NOT_EMPTY_BIT)           <=
            buffer_control_unmasked_interrupt_reg_reg(NEW_FRAME_WHILE_EV_FIFO_NOT_EMPTY_BIT) or EV_FIFO_NOTEMPTY;  --64MHz
          buffer_control_unmasked_interrupt_reg_reg(SL_REQ_DURING_SLICE_TRANSMISSION_BIT)           <=
            buffer_control_unmasked_interrupt_reg_reg(SL_REQ_DURING_SLICE_TRANSMISSION_BIT) or slice_req_error_64m;  --64MHz

          buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_RAW_BUFFER_UNDERRUN_BIT)           <=
            ( buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_RAW_BUFFER_UNDERRUN_BIT) or Raw_Buffer_underrun_interrupt_pulse );
          buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_EV_BUFFER_UNDERRUN_BIT)           <=
            buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_EV_BUFFER_UNDERRUN_BIT) or ev_slots_underflow_pulse;
          buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_PTR_BUFFER_UNDERRUN_BIT)           <=
            buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_PTR_BUFFER_UNDERRUN_BIT) or ptr_underflow_pulse;
          buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_PTR_BUFFER_OVERFLOW_STOP_SCAN_BIT)           <=
            buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_PTR_BUFFER_OVERFLOW_STOP_SCAN_BIT) or PTR_stop_scan_pipe(1);
          buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_EV_BUFFER_STOP_SCAN_BIT)           <=
          buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_EV_BUFFER_STOP_SCAN_BIT) or EV_stop_scan_pipe(1);  --64MHz
                    buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT)            <=
            buffer_control_unmasked_interrupt_reg_reg(16 + SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT) or ddr_driver_stop_scan_pipe(1);

--           buffer_control_unmasked_interrupt_reg_reg(16 + READ_TIMEOUT_BIT)           <=
--             buffer_control_unmasked_interrupt_reg_reg(16 + READ_TIMEOUT_BIT) or '0';-- used to be DATA_READ_TIMEOUT_INTERRUPT which belongs to read_block_2 this interrupt is irrelevant!
          buffer_control_unmasked_interrupt_reg_reg(31 downto 22)           <= (others => '0');
          EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_reg(7 downto 0) <= EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_reg(7 downto 0);
          EVOLVING_STOP_IP_HIGH_LIMIT_reg(7 downto 0) <= EVOLVING_STOP_IP_HIGH_LIMIT_reg(7 downto 0);
          EVOLVING_STOP_IP_LOW_LIMIT_reg(7 downto 0) <= EVOLVING_STOP_IP_LOW_LIMIT_reg(7 downto 0);

          UNMASKED_INTERRUPT <= ieee.std_logic_misc.nor_reduce( std_logic_vector( buffer_control_unmasked_interrupt_reg_reg) );
          -----------------------------------------------------------------------------------------
          -- buffer_control_interrupt_mask_register_reg, register 0x0A4
          -- ?only updated from local controller?

          -----------------------------------------------------------------------------------------
          -- RAW Buffer status, registers 0x0A8 , 0x0A9
          -- Current available space (for write) on the RAW memory buffer
          if ((local_address_natural = BUFFER_STATUS_LSB_ADDR and port_ale_r = '0')
            or sample_la_data) then
            buffer_status_lsb_reg <= raw_addr_cmp_result_64m(15 downto 0);
            buffer_status_msb_reg <=
              resize(raw_addr_cmp_result_64m(raw_addr_cmp_result_64m'LEFT downto 16), 16);
          end if;

          -----------------------------------------------------------------------------------------
          -- EV Buffer status, register 0x0AA
          -- Current available space (for write) on the EV memory buffer
          ev_buffer_status_reg <=
            resize(ev_slotnum_cmp_result_64m(EV_BUFFER_SLOTS_TYP'RANGE), 16);

          -----------------------------------------------------------------------------------------
          -- Reading Pointer Buffer status,  registers 0x0AC , 0x0AD
          -- Current available space (for write) on the PTR (FIFO) memory buffer
          if ((local_address_natural = READING_POINTER_BUFFER_STATUS_LSB_ADDR
              and port_ale_r = '0') or sample_la_data) then
            reading_pointer_buffer_status_lsb_reg <= ptr_addr_cmp_result_64m(15 downto 0);
            reading_pointer_buffer_status_msb_reg <=
              resize(ptr_addr_cmp_result_64m(ptr_addr_cmp_result_64m'LEFT downto 16), 16);
          end if;

--           -----------------------------------------------------------------------------------------
--           -- Available space in Raw data FIFO, register 0x0AE
--           raw_fifo_status_reg <= resize(unsigned(RAW_FIFO_SPACE), raw_fifo_status_reg'LENGTH);
          raw_fifo_status_reg                          <= (others => '0');

          -----------------------------------------------------------------------------------------
          -- Available space in EV data FIFO, register 0x0B0
          ev_fifo_status_reg <= resize(unsigned(EV_FIFO_SPACE), ev_fifo_status_reg'LENGTH);

          -----------------------------------------------------------------------------------------
          -- Available space in COMM_TX data FIFO, register 0x0B2
          comm_tx_fifo_status_reg <= resize(unsigned(READ_FIFO_SPACE), comm_tx_fifo_status_reg'LENGTH);

          -----------------------------------------------------------------------------------------
          -- Write pointer (address) in RAW buffer, registers 0x0B4 , 0x0B5
          if ((local_address_natural = RAW_WRITE_POINTER_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            raw_write_pointer_lsb_reg <= raw_reading_raw_data_addr_64m(15 downto 0);
            raw_write_pointer_msb_reg <= resize(
              raw_reading_raw_data_addr_64m(raw_reading_raw_data_addr_64m'LEFT downto 16), 16);
          end if;

          -----------------------------------------------------------------------------------------
          -- Write pointer (address) in Evolving buffer, registers 0x0B6, 0x0B7
          if ((local_address_natural = EVOLVING_WRITE_POINTER_LSB_ADDR and port_ale_r = '0'
              ) or sample_la_data) then
            evolving_write_pointer_lsb_reg <= ev_reading_ev_data_addr_64m(15 downto 0);
            evolving_write_pointer_msb_reg <= resize(ev_reading_ev_data_addr_64m(ev_reading_ev_data_addr_64m'LEFT downto 16), 16);
          end if;

          -----------------------------------------------------------------------------------------
          -- Read pointer (address) in RAW buffer, registers 0x0B8 , 0x0B9
          if ((local_address_natural = COMM_TX_RAW_READ_POINTER_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            comm_tx_raw_read_pointer_lsb_reg <= read_reading_raw_data_addr_64m(15 downto 0);
            comm_tx_raw_read_pointer_msb_reg <= resize(
              read_reading_raw_data_addr_64m(read_reading_raw_data_addr_64m'LEFT downto 16), 16);
          end if;

          -----------------------------------------------------------------------------------------
          -- Read pointer (address) in Evolving buffer, registers 0x0BA , 0x0BB
          if ((local_address_natural = COMM_TX_EV_READ_POINTER_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            comm_tx_ev_read_pointer_lsb_reg <= read_reading_ev_data_addr_64m(15 downto 0);
            comm_tx_ev_read_pointer_msb_reg <= resize(
              read_reading_ev_data_addr_64m(read_reading_ev_data_addr_64m'LEFT downto 16), 16);
          end if;

          -- DDR-2 device test status, Indicates the device failed in the test, registers 0x0C0
            ddr2_device_test_status_reg(mem_test_failed_devices_64m'RANGE) <=
              unsigned(mem_test_failed_devices_64m);
            ddr2_device_test_status_reg(15 downto mem_test_failed_devices_64m'LEFT + 1) <=
              (others => '0');

          -- DDR-2 address test status, Indicates the address failed in the test, registers 0x0C2 , 0x0C3
          if ((local_address_natural = DDR2_ADDRESS_TEST_STATUS_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            ddr2_address_test_status_lsb_reg <= mem_test_error_data_addr_64m(15 downto 0);
            ddr2_address_test_status_msb_reg <= resize(
              mem_test_error_data_addr_64m(mem_test_error_data_addr_64m'LEFT downto 16), 16);
          end if;

          -- Chip number of ECC Corrected ERROR, registers 0x0C6
          if (READ_ECC_ERROR_CHIPNUM = (READ_ECC_ERROR_CHIPNUM'REVERSE_RANGE => '1')) then
            ecc_error_chip_number_reg <= (others => '0'); -- if X"F" - not detected single error
          else
            ecc_error_chip_number_reg <= (others => '0');
            ecc_error_chip_number_reg(to_integer(unsigned(READ_ECC_ERROR_CHIPNUM))) <= '1';
          end if;

          -- Address of last ECC detected Error, registers 0x0C8, 0x0C9
          if ((local_address_natural = ECC_ERROR_ADDRESS_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            ecc_error_address_lsb_reg <= read_ecc_error_addr_64m(15 downto 0);
            ecc_error_address_msb_reg <= resize(
              read_ecc_error_addr_64m(read_ecc_error_addr_64m'LEFT downto 16), 16);
          end if;

          -- Counter indicating number of corrected errors since last reset, 0x0CA
          ecc_corrected_errors_counter_reg <= to_unsigned(read_ecc_error_cnt, 16);

          -- Counter indicating number of unrecoverable errors since last reset, 0x0CC
          ecc_errors_counter_reg <= to_unsigned(read_double_ecc_error_cnt, 16);

          -- ECC error injection, register 0x0CE
          -- !debug, size changed. Add bits 8..2 - error_mask value
          ecc_error_injection_reg(8 downto 2) <= unsigned(ECC_ERROR_MASK);

          -- ddr_driver_control_reg, register 0x0C4
          ddr_driver_control_reg(15 downto 12) <=
            (MEM_TEST_DONE & MEM_TEST_SUCCESSFUL & MEM_TEST_INTERRUPTED & MEM_TEST_PASSED);

          ddr_driver_control_reg(11 downto 7) <= (others => '0');  -- avoid latches

          -- ddr_driver_control_reg(6 downto 4) - write from ports
          ddr_driver_control_reg(3 downto 1)  <= "000";           -- test cmd. only pulse
          -- ddr_driver_control_reg(0) - write from ports

          -- Raw Readings Written into buffer, registers 0x0D2,0x0D3
          if ((local_address_natural = RAW_WR_COUNTER_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            raw_wr_counter_lsb_reg <= unsigned(RAW_WR_COUNTER(15 downto 0));
            raw_wr_counter_msb_reg <= unsigned(RAW_WR_COUNTER(31 downto 16));
          end if;

          -- EV Readings Written into buffer, registers 0x0D4,0x0D5
          if ((local_address_natural = EV_WR_COUNTER_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            ev_wr_counter_lsb_reg <= unsigned(EV_WR_COUNTER(15 downto 0));
            ev_wr_counter_msb_reg <= unsigned(EV_WR_COUNTER(31 downto 16));
          end if;

          -- Raw Reading Requests Read from buffer, registers 0x0D6,0x0D7
          if ((local_address_natural = RAW_RD_COUNTER_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            raw_rd_counter_lsb_reg <= unsigned(RAW_RD_COUNTER(15 downto 0));
            raw_rd_counter_msb_reg <= unsigned(RAW_RD_COUNTER(31 downto 16));
          end if;

          -- EV Reading Requests Read from buffer, registers 0x0D8,0x0D9
          if ((local_address_natural = EV_RD_COUNTER_LSB_ADDR and port_ale_r = '0'
               ) or sample_la_data) then
            ev_rd_counter_lsb_reg <= unsigned(EV_RD_COUNTER(15 downto 0));
            ev_rd_counter_msb_reg <= unsigned(EV_RD_COUNTER(31 downto 16));
          end if;

          -- Built-in Logic Analyzer words depth , registers 0x0E0
          -- !debug, const value          periph_la_depth_reg <= unsigned();

          -- -- Built-in Logic Analyzer, registers 0x0E2,0x0E3
          -- if ((local_address_natural = PERIPH_LA_DATA_LSB_ADDR and port_ale_r = '0'
          --      ) or sample_la_data) then
          --   periph_la_data_lsb_reg <= la_memory(la_memory_addr)(15 downto 0);
          --   periph_la_data_msb_reg <= la_memory(la_memory_addr)(31 downto 16);
          -- end if;


        end if;

      end if;
    end if;
  end process local_regs_pr;


  sync128_pr : process (TOP_CLK_MEM_128M, RESET_128) is
  begin  -- process sync128_pr
    if RESET_128 = '0' then               -- asynchronous reset (active low)
      div3 <= "001";
      read_reading_raw_data_addr_sampled <= (others => '0');
      ptr_addr_cmp_result_r_sampled <= (others => '0');
      ev_buffer_overflow_i_sampled <= '0';
      raw_buffer_overflow_i_sampled <= '0';
      raw_addr_cmp_result_sampled <= (others => '0');
      -- read_fifo_space_sampled <= (others => '0');
      read_reading_ev_data_addr_sampled <= (others => '0');
      mem_test_error_data_addr_sampled <= (others => '0');
      mem_test_failed_devices_sampled <= (others => '0');
      -- raw_fifo_notempty_sampled <= '0';
      -- ev_fsm_error_sampled <= '0';
      raw_reading_raw_data_addr_sampled  <= (others => '0');
      ev_reading_ev_data_addr_sampled  <= (others => '0');
      ddr_driver_control_reg_sampled <= (others => '0');

    elsif TOP_CLK_MEM_128M'event and TOP_CLK_MEM_128M = '1' then  -- rising clock edge
      div3 <= div3 rol 1;
      if (div3(0) = '1') then
        read_reading_raw_data_addr_sampled <= READ_READING_RAW_DATA_ADDR;
        ptr_addr_cmp_result_r_sampled <= ptr_addr_cmp_result_r;
        ev_buffer_overflow_i_sampled <= ev_buffer_overflow_i;

        raw_buffer_overflow_i_sampled <= raw_buffer_overflow_i;
        raw_addr_cmp_result_sampled <= raw_addr_cmp_result;
        -- read_fifo_space_sampled <= READ_FIFO_SPACE;
        read_reading_ev_data_addr_sampled <= (READ_READING_EV_DATA_ADDR -
                                              EV_DATA_BASE_ADDR); -- relative address
        mem_test_error_data_addr_sampled <= MEM_TEST_ERROR_DATA_ADDR;
        mem_test_failed_devices_sampled <= MEM_TEST_FAILED_DEVICES;
        -- raw_fifo_notempty_sampled <= RAW_FIFO_NOTEMPTY;
        -- ev_fsm_error_sampled <= EV_FSM_ERROR;
        raw_reading_raw_data_addr_sampled <= RAW_READING_RAW_DATA_ADDR;
        ev_reading_ev_data_addr_sampled  <= (EV_READING_EV_DATA_ADDR -
                                             EV_DATA_BASE_ADDR); -- relative address;
        ddr_driver_control_reg_sampled <= ddr_driver_control_reg; --25/12/2017
      end if;
    end if;
  end process sync128_pr;


  sync_pr : process (RESET_I, SYSTEM_CLK64_I) is
    variable mask_result : unsigned(31 downto 0);
  begin  -- process sync_pr
    if RESET_I = '0' then

      DDR_DRIVER_INTR_L  <= '1';                              -- active LOW
      buffer_control_interrupt_status_register_reg <= (others => '0');
      read_fsm_error_r   <= '0';
      read_fsm_error_cnt <= 0;
      raw_reading_raw_data_addr_64m <=  (others => '0');
      read_reading_raw_data_addr_64m <= (others => '0');
      ptr_addr_cmp_result_64m <= (others => '0');
      raw_addr_cmp_result_64m <= (others => '0');
      ev_slots_overflow_i_64m <= '0';
      raw_buffer_overflow_i_64m <= '0';
      -- ev_fsm_error_64m <= '0';
      -- raw_fsm_error_64m <= '0';
      slice_req_error_64m <= '0';
      read_reading_ev_data_addr_64m <= (others => '0');
      read_ecc_error_addr_64m <= (others => '0');
      -- read_fifo_space_64m <= (others => '0');
      mem_test_error_data_addr_64m <= (others => '0');
      mem_test_failed_devices_64m <= (others => '0');
      -- raw_fifo_notempty_64m          <= '0';
      ev_reading_ev_data_addr_64m <= (others => '0');
      ev_slotnum_cmp_result_64m <= (others => '1');
      EV_stop_scan_pipe <= "00";--
      ddr_driver_stop_scan_pipe <= "00";
      PTR_stop_scan_pipe <= "00";
   	  raw_underflow_pipe <= "00";
   	  ev_slots_overflow_i_pipe <= "00";
   	  ev_buffer_overflow_pipe <= "00";
   	  ev_slots_underflow_pipe <= "00";
   	  ptr_underflow_pipe <= "00";
   	  ptr_overflow_pipe <= "00";
   	  Raw_buffer_overflow_pipe <= "00";
   	  ddr_driver_stop_scan_64m <= '0';
      ev_stop_scan_64m <= '0';
      ptr_stop_scan_64m <= '0';
    elsif SYSTEM_CLK64_I'EVENT and SYSTEM_CLK64_I = '1' then  -- rising clock edge

      mask_result := (buffer_control_unmasked_interrupt_reg_reg and
                     buffer_control_interrupt_mask_register_reg); -- when unmasked_int. and mask both
                                                                  -- active, then int. goes to '0'

      DDR_DRIVER_INTR_L <= ieee.std_logic_misc.nor_reduce(std_logic_vector(mask_result));
      -- Buffer Control Interrupt Status Register (active level '1'), register 0x0A2
      buffer_control_interrupt_status_register_reg <= mask_result; -- '0' specified interrupts

      read_fsm_error_r <= READ_FSM_ERROR;
      if (read_fsm_error_r = '0' and READ_FSM_ERROR = '1' and read_fsm_error_cnt < 15) then
        read_fsm_error_cnt <= read_fsm_error_cnt + 1;
      end if;

      read_ecc_error_addr_64m        <= READ_ECC_ERROR_ADDR; -- 40MHz to 64MHz
      -- raw_fsm_error_64m              <= RAW_FSM_ERROR;                -- sampled
      slice_req_error_64m            <= SLICE_REQ_ERROR;              -- sampled

--      if (div3(0) /= '1') then          -- stable two 128 clocks
        read_reading_raw_data_addr_64m <= read_reading_raw_data_addr_sampled;
        ptr_addr_cmp_result_64m        <= ptr_addr_cmp_result_r_sampled;
        raw_buffer_overflow_i_64m      <= raw_buffer_overflow_i_sampled;
        raw_addr_cmp_result_64m        <= raw_addr_cmp_result_sampled;  -- 128MHz to 64MHz
        read_reading_ev_data_addr_64m  <= read_reading_ev_data_addr_sampled;
        -- read_fifo_space_64m            <= read_fifo_space_sampled;
        mem_test_error_data_addr_64m   <= mem_test_error_data_addr_sampled;
        mem_test_failed_devices_64m <= mem_test_failed_devices_sampled;
        -- raw_fifo_notempty_64m          <= raw_fifo_notempty_sampled;
        -- ev_fsm_error_64m               <= ev_fsm_error_sampled;
        raw_reading_raw_data_addr_64m  <= raw_reading_raw_data_addr_sampled;
        ev_reading_ev_data_addr_64m <= ev_reading_ev_data_addr_sampled;
--      end if;
      ev_slotnum_cmp_result_64m <= ev_slotnum_cmp_result; -- slow changed 128MHz to 64MHz

       if (PORTS_CLK_EN = '1') then  -- enable 16MHz --and DDR_DRIVER_CS = LOCAL_BUS_CS_POLARITY
       		--stop_scan_interrupts
       		EV_stop_scan_pipe            <= EV_stop_scan_pipe(0) & EV_stop_scan_interrupt;
       		ddr_driver_stop_scan_pipe    <= ddr_driver_stop_scan_pipe(0) & ddr_driver_stop_scan_interrupt;
       		PTR_stop_scan_pipe           <= PTR_stop_scan_pipe(0) & ptr_stop_scan_interrupt;

			ev_slots_overflow_i_pipe     <= ev_slots_overflow_i_pipe(0) & ev_slots_overflow_i;
			ev_slots_underflow_pipe      <=	ev_slots_underflow_pipe(0)	& ev_slots_underflow_i;
			-- not in used should be removed
			ev_buffer_overflow_pipe      <= ev_buffer_overflow_pipe(0) & ev_buffer_overflow_i;
			-- PTR buffer
			ptr_underflow_pipe           <=	ptr_underflow_pipe(0) & ptr_buffer_underflow_i;
			ptr_overflow_pipe            <= ptr_overflow_pipe(0) & ptr_buffer_overflow_i;
			-- Raw buffer
			Raw_buffer_overflow_pipe     <= Raw_buffer_overflow_pipe(0) & raw_buffer_overflow_i;
			raw_underflow_pipe           <= raw_underflow_pipe(0) & Raw_Buffer_underrun_interrupt;

	   end if;

      -- 19/12/2017
   	  ddr_driver_stop_scan_64m <= ddr_driver_stop_scan;
      ev_stop_scan_64m <= ev_stop_scan;
      ptr_stop_scan_64m <= ptr_stop_scan;

    end if;
  end process sync_pr;


  ecc_errors_pr : process (SYSTEM_CLK64_I, RESET_I) is
  begin  -- process ecc_errors_pr
    if RESET_I = '0' then               -- asynchronous reset (active low)

      read_ecc_error_cnt   <= 0;
      read_double_ecc_error_cnt <= 0;
      ecc_error_r            <= FALSE;
      ecc_double_error_r     <= FALSE;
      ecc_error_pipe         <= "00";
      ecc_double_error_pipe  <= "00";
      one_ecc_error_internal_interrupt <= '0';
      double_ecc_error_internal_interrupt <= '0';

    elsif SYSTEM_CLK64_I'event and SYSTEM_CLK64_I = '1' then  -- rising clock edge

      if(ECC_ERROR_INTERNAL) then
      	one_ecc_error_internal_interrupt <= '1';
      else
      	one_ecc_error_internal_interrupt <= '0';
      end if;

      ecc_error_pipe <= ecc_error_pipe(0) & one_ecc_error_internal_interrupt;
      ecc_error_interrupt_pulse <= bool2std( rise_detect( ecc_error_pipe ) );
      ecc_error_r <= ECC_ERROR_INTERNAL;

      if (ecc_corrected_errors_counter_reset) then -- writing resets the register
        read_ecc_error_cnt   <= 0;
      elsif (ecc_error_interrupt_pulse = '1') then
        read_ecc_error_cnt <= read_ecc_error_cnt + 1;
      end if;

	  if(ECC_DOUBLE_ERROR_INTERNAL) then
	  	double_ecc_error_internal_interrupt <= '1';
	  else
	  	double_ecc_error_internal_interrupt <= '0';
	  end if;

      ecc_double_error_pipe <= ecc_double_error_pipe(0) & double_ecc_error_internal_interrupt;
      ecc_double_error_interrupt_pulse <= bool2std( rise_detect( ecc_double_error_pipe ) );

      ecc_double_error_r <= ECC_DOUBLE_ERROR_INTERNAL;

      if (ecc_errors_counter_reset) then -- writing resets the register
        read_double_ecc_error_cnt <= 0;
      elsif (ecc_double_error_interrupt_pulse = '1') then
        read_double_ecc_error_cnt <= read_double_ecc_error_cnt + 1;
      end if;

    end if;

  end process ecc_errors_pr;


  local_ports_pr : process (SYSTEM_CLK64_I, RESET_I) is
  begin  -- process local_ports_pr
    if RESET_I = '0' then               -- asynchronous reset (active low)

      local_address <= (others => '0'); -- not in ddr_driver address RANGE
      port_ale_r <= '1';                -- active '0'
      do_write <= FALSE;
      do_read <= FALSE;
--      do_write_r <= FALSE;
      do_read_r <= FALSE;

    elsif SYSTEM_CLK64_I'event and SYSTEM_CLK64_I = '1' then  -- rising clock edge

      if (PORTS_CLK_EN = '1') then

		if (PORT_ALE_I = '0' and (PORT_READ_I = '0' or PORT_WRITE_I = '0')) then
			local_address <= unsigned(PORT_A_D_B_IN);

		end if;

        port_ale_r <= PORT_ALE_I;

        do_write <= fpga_selected and ddr_driver_selected and PORT_WRITE_I = '0'
                    and (PORT_ALE_I = '1' and port_ale_r = '0');
        do_read <= fpga_selected and ddr_driver_selected and PORT_READ_I = '0'
                   and (PORT_ALE_I = '1' and port_ale_r = '0');

      end if;

      if (PORTS_CLK_EN = '1') then  -- enable 16MHz _READ_ clock debug:or PORTS_CLK_LAUNCH_EN ?!
--        do_write_r <= do_write;
        do_read_r <= do_read;
      end if;

    end if;
  end process local_ports_pr;


  sample_la_data <= (buffer_control_unmasked_interrupt_reg_reg(15) = '1');

  -- LA memory fill
  la_fill_pr : process (SYSTEM_CLK64_I, RESET_I) is
  begin  -- process la_fill_pr
    if RESET_I = '0' then               -- asynchronous reset (active low)
      la_memory <= (others => (others => '0'));
      la_done <= FALSE;
      la_done_r <= FALSE;
      la_memory_addr <= 0;

    elsif SYSTEM_CLK64_I'event and SYSTEM_CLK64_I = '1' then  -- rising clock edge

      if (PORTS_CLK_EN = '1') then      -- registers values saved

        la_done <= sample_la_data;
        la_done_r <= la_done;

        -- LA buffer read address
        if (not la_done_r) then
          la_memory_addr <= 0;    -- read started from 1st addr
        elsif (la_memory_addr < 127 and la_incr) then  -- one port clock pulse
          la_memory_addr <= la_memory_addr + 1;
        end if;

      end if;


      if (USE_LA and sample_la_data and not la_done_r) then  -- pulse
        la_memory(0)   <= (resize(unsigned'(X"55555555"), 32));
        la_memory(1)   <= (resize(unsigned'(X"AAAAAAAA"), 32));
        la_memory(2)   <= (buffer_control_unmasked_interrupt_reg_reg);
        la_memory(3)   <= (buffer_control_interrupt_status_register_reg);
        la_memory(4)   <= (buffer_control_interrupt_mask_register_reg);
        la_memory(5)   <= (buffer_status_lsb_reg & to_unsigned(BUFFER_STATUS_LSB_ADDR, 16));
        la_memory(6)   <= (buffer_status_msb_reg & to_unsigned(BUFFER_STATUS_MSB_ADDR, 16));
        la_memory(7)   <= (ev_buffer_status_reg & to_unsigned(EV_BUFFER_STATUS_ADDR, 16));
        la_memory(8)   <= (reading_pointer_buffer_status_lsb_reg & to_unsigned(READING_POINTER_BUFFER_STATUS_LSB_ADDR, 16));
        la_memory(9)   <= (reading_pointer_buffer_status_msb_reg & to_unsigned(READING_POINTER_BUFFER_STATUS_MSB_ADDR, 16));
        la_memory(10)  <= (raw_fifo_status_reg & to_unsigned(RAW_FIFO_STATUS_ADDR, 16));
        la_memory(11)  <= (ev_fifo_status_reg & to_unsigned(EV_FIFO_STATUS_ADDR, 16));
        la_memory(12)  <= (comm_tx_fifo_status_reg & to_unsigned(COMM_TX_FIFO_STATUS_ADDR, 16));
        la_memory(13)  <= (raw_write_pointer_lsb_reg & to_unsigned(RAW_WRITE_POINTER_LSB_ADDR, 16));
        la_memory(14)  <= (raw_write_pointer_msb_reg & to_unsigned(RAW_WRITE_POINTER_MSB_ADDR, 16));
        la_memory(15)  <= (evolving_write_pointer_lsb_reg & to_unsigned(EVOLVING_WRITE_POINTER_LSB_ADDR, 16));
        la_memory(16)  <= (evolving_write_pointer_msb_reg & to_unsigned(EVOLVING_WRITE_POINTER_MSB_ADDR, 16));
        la_memory(17)  <= (comm_tx_raw_read_pointer_lsb_reg & to_unsigned(COMM_TX_RAW_READ_POINTER_LSB_ADDR, 16));
        la_memory(18)  <= (comm_tx_raw_read_pointer_msb_reg & to_unsigned(COMM_TX_RAW_READ_POINTER_MSB_ADDR, 16));
        la_memory(19)  <= (comm_tx_ev_read_pointer_lsb_reg & to_unsigned(COMM_TX_EV_READ_POINTER_LSB_ADDR, 16));
        la_memory(20)  <= (comm_tx_ev_read_pointer_msb_reg & to_unsigned(COMM_TX_EV_READ_POINTER_MSB_ADDR, 16));
        la_memory(21)  <= (ddr2_device_test_status_reg & to_unsigned(DDR2_DEVICE_TEST_STATUS_ADDR, 16));
        la_memory(22)  <= (ddr2_address_test_status_lsb_reg & to_unsigned(DDR2_ADDRESS_TEST_STATUS_LSB_ADDR, 16));
        la_memory(23)  <= (ddr2_address_test_status_msb_reg & to_unsigned(DDR2_ADDRESS_TEST_STATUS_MSB_ADDR, 16));
        la_memory(24)  <= (ddr_driver_control_reg & to_unsigned(DDR_DRIVER_CONTROL_ADDR, 16));
        la_memory(25)  <= (resize(ecc_error_chip_number_reg, 16) & to_unsigned(ECC_ERROR_CHIP_NUMBER_ADDR, 16));
        la_memory(26)  <= (ecc_error_address_lsb_reg & to_unsigned(ECC_ERROR_ADDRESS_LSB_ADDR, 16));
        la_memory(27)  <= (ecc_error_address_msb_reg & to_unsigned(ECC_ERROR_ADDRESS_MSB_ADDR, 16));
        la_memory(28)  <= (ecc_corrected_errors_counter_reg & to_unsigned(ECC_CORRECTED_ERRORS_COUNTER_ADDR, 16));
        la_memory(29)  <= (ecc_errors_counter_reg & to_unsigned(ECC_ERRORS_COUNTER_ADDR, 16));
        la_memory(30)  <= (resize(ecc_error_injection_reg, 16) & to_unsigned(ECC_ERROR_INJECTION_ADDR, 16));
        la_memory(31)  <= (resize(raw_wr_counter_lsb_reg, 16) & to_unsigned(RAW_WR_COUNTER_LSB_ADDR, 16));  -- 0x0D2
        la_memory(32)  <= (resize(raw_wr_counter_msb_reg, 16) & to_unsigned(RAW_WR_COUNTER_MSB_ADDR, 16));  -- 0x0D3
        la_memory(33)  <= (resize(unsigned'(X"FFFFFF02"), 32));
        la_memory(125) <= (unsigned'(X"FFFFFF02"));
        la_memory(126) <= (unsigned'(X"FFFFFF01"));
        la_memory(127) <= (unsigned'(X"FFFFFF00"));
      end if;


    end if;
  end process la_fill_pr;


  fpga_selected <= (local_address(15 downto 12) = unsigned(FPGA_ID)) or
                   (local_address(15 downto 12) = unsigned(ALL_PERIPH_BROADCAST));

  ddr_driver_selected <=
    (local_address(11 downto 0) >= to_unsigned(BUFFER_CONTROL_BOTTOM_ADDR, 12)) and
    (local_address(11 downto 0) <= to_unsigned(BUFFER_CONTROL_TOP_ADDR, 12));


  RAW_BUFFER_OVERFLOW <= raw_buffer_overflow_i; -- NU input to data_sort_2_ddr_w
  PTR_BUFFER_OVERFLOW <= ptr_buffer_overflow_i; -- NU
  PTR_BUFFER_UNDERFLOW <= ptr_buffer_underflow_i;
  EV_BUFFER_OVERFLOW <= ev_slots_overflow_i; -- ev_buffer_overflow_i; -- NU input to evolving_2_ddr_w
  EV_BUFFER_UNDERFLOW  <= ev_slots_underflow_i;

  -- DISABLE_REFRESH         <= ddr_driver_control_reg_sampled(0);
  MEM_TEST_FULL           <= ddr_driver_control_reg_sampled(1);
  INJECT_OUTPUT_FIFO_DATA <= ddr_driver_control_reg_sampled(DD_INJECT_DATA_OUTPUT_FIFO_BIT);
  DISABLE_RAW_REQ         <= not(ddr_driver_control_reg_sampled(15));
  DISABLE_EV_REQ          <= not(ddr_driver_control_reg_sampled(15));
  DISABLE_READ_REQ        <= not(ddr_driver_control_reg_sampled(15));

  ECC_ERROR_INJECTION_CMD <= std_logic_vector(ecc_error_injection_reg(1 downto 0));


  DDR_LOCAL_REGS_TP(0) <= PORT_ALE_I;
  DDR_LOCAL_REGS_TP(1) <= PORT_WRITE_I;
  DDR_LOCAL_REGS_TP(2) <= PORT_READ_I;

  DDR_LOCAL_REGS_TP(3) <= DDR_LOCAL_REGS_TP_3_i;

  DDR_LOCAL_REGS_TP(4) <= '1' when memory_goes_fill else '0'; -- dummy for SignalTap
  DDR_LOCAL_REGS_TP(5) <= '0'; -- NU, only to tp
  DDR_LOCAL_REGS_TP(6) <= '1' when (ptr_buffer_overflow_cnt = 1) else '0';
  DDR_LOCAL_REGS_TP(7) <= '1' when (read_fsm_error_cnt = 1) else '0';

  DDR_LOCAL_REGS_TP(15 downto 8) <= std_logic_vector(ptr_addr_cmp_underflow_result(7 downto 0));
  DDR_LOCAL_REGS_TP(16) <= '1' when (EV_READING_EV_SLOTNUM < READ_READING_EV_SLOTNUM) else '0';
  DDR_LOCAL_REGS_TP(17) <= '1' when (EV_READING_EV_SLOTNUM > READ_READING_EV_SLOTNUM) else '0';
  DDR_LOCAL_REGS_TP(18) <= '0' when (to_integer(ev_slotnum_cmp_result_64m) > 100) else '1'; -- !debug: 30/10/2017
  DDR_LOCAL_REGS_TP(31 downto 19) <= (others => '0');

  -- !debug: 15/05/2017 only for test
  mon_pr : process (SYSTEM_CLK64_I) is
  begin  -- process mon_pr
    if (SYSTEM_CLK64_I'event and SYSTEM_CLK64_I = '1') then  -- rising clock edge

      mon_a_0(0) <= buffer_control_interrupt_status_register_reg(31 downto 16);
      mon_a_0(1) <= buffer_control_interrupt_status_register_reg(15 downto 0);
      mon_a_0(2) <= buffer_control_unmasked_interrupt_reg_reg(31 downto 16);
      mon_a_0(3) <= buffer_control_unmasked_interrupt_reg_reg(15 downto 0);
      mon_a_0(4) <= buffer_control_interrupt_mask_register_reg(31 downto 16);
      mon_a_0(5) <= buffer_control_interrupt_mask_register_reg(15 downto 0);
      mon_a_0(6) <= buffer_status_lsb_reg;
      mon_a_0(7) <= buffer_status_msb_reg;
      mon_a_0(8) <= ev_buffer_status_reg;
      mon_a_0(9) <= reading_pointer_buffer_status_lsb_reg;
      mon_a_0(10) <= reading_pointer_buffer_status_msb_reg;
      mon_a_0(11) <= (others => '0'); -- raw_fifo_status_reg;
      mon_a_0(12) <= (others => '0'); -- ev_fifo_status_reg ;
      mon_a_0(13) <= (others => '0'); -- comm_tx_fifo_status_reg;
      mon_a_0(14) <= raw_write_pointer_lsb_reg;
      mon_a_0(15) <= raw_write_pointer_msb_reg;
      mon_a_0(16) <= evolving_write_pointer_lsb_reg;
      mon_a_0(17) <= evolving_write_pointer_msb_reg;
      mon_a_0(18) <= comm_tx_raw_read_pointer_lsb_reg;
      mon_a_0(19) <= comm_tx_raw_read_pointer_msb_reg;
      mon_a_0(20) <= comm_tx_ev_read_pointer_lsb_reg;
      mon_a_0(21) <= comm_tx_ev_read_pointer_msb_reg;
      mon_a_0(22) <= ddr2_device_test_status_reg;
      mon_a_0(23) <= ddr2_address_test_status_lsb_reg;
      mon_a_0(24) <= ddr2_address_test_status_msb_reg;
      mon_a_0(25) <= resize(ecc_error_chip_number_reg(8 downto 0),16);
      mon_a_0(26) <= ecc_error_address_lsb_reg       ;
      mon_a_0(27) <= ecc_error_address_msb_reg       ;
      mon_a_0(28) <= ecc_corrected_errors_counter_reg;
      mon_a_0(29) <= ecc_errors_counter_reg          ;
      mon_a_0(30) <= resize(ecc_error_injection_reg(8 downto 0),16);
      mon_a_0(31) <= ddr_driver_control_reg;
      mon_a_0(32) <= raw_wr_counter_lsb_reg;
      mon_a_0(33) <= raw_wr_counter_msb_reg;
      mon_a_0(34) <= ev_wr_counter_lsb_reg;
      mon_a_0(35) <= ev_wr_counter_msb_reg;
      mon_a_0(36) <= raw_rd_counter_lsb_reg;
      mon_a_0(37) <= raw_rd_counter_msb_reg;
      mon_a_0(38) <= ev_rd_counter_lsb_reg;
      mon_a_0(39) <= ev_rd_counter_msb_reg;
      mon_a <= mon_a_0;

    end if;
  end process mon_pr;


  -- 19/12/2017
  DDR_DRIVER_STOP_SCAN_O <= ddr_driver_stop_scan_64m;
  EV_STOP_SCAN_O <= ev_stop_scan_64m;
  PTR_STOP_SCAN_O <= ptr_stop_scan_64m;


end ar;
