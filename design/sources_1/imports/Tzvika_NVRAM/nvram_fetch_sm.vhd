
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
entity nvram_fetch_sm is
    generic(
        G_TOUT : std_logic_vector(20 - 1 downto 0):= x"6D090" -- 10msec with 50MHz clk
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
end entity;
architecture nvram_fetch_sm_arch of nvram_fetch_sm is

    --------------------------------------------
    -- types:
    type main_sm is (
					idle_st,
					wait1_st,
					pull_st ,
					wait_wr_st,
					waw_st,
					send_rd_st,
					wait_rd_st
					);
    signal main_sm_sig :main_sm;
    
    type instruction_sm is (
                idle_st,
                wait_data_st ,
                latch_data_st,
                wait_read_st , 
                push_inst_st
                );
    signal instruction_sm_sig :instruction_sm;
     --------------------------------------------
    -- components:
    --------------------------------------------   

    --------------------------------------------
    -- signals:
    --------------------------------------------
    
    signal regs_data_sig                         : std_logic_vector(31 downto 0) := (others => '0');
    signal regs_addr_sig                         : std_logic_vector(31 downto 0) := (others => '0');    
    signal status_reg_sig                        : std_logic_vector(31 downto 0) := (others => '0');   
    --------------------------------------------
    signal sr_wr_en_sig                         : std_logic_vector(7 downto 0) := (others => '0');
    signal err_illegal_instruction_cnt_sig      : std_logic_vector(7 downto 0) := (others => '0');
    signal err_nvram_tout_cnt_sig               : std_logic_vector(7 downto 0) := (others => '0');
    signal err_illegal_state_cnt_sig            : std_logic_vector(7 downto 0) := (others => '0');
    signal instruction_vec_sig                  : std_logic_vector(63 downto 0) := (others => '0');
    signal fifo_wr_en_sig                       : std_logic:= '0';
    signal fifo_full_sig                        : std_logic:= '0';
    signal fifo_empty_sig                       : std_logic:= '0';
    signal fifo_rd_datacount_sig : std_logic_vector(7 downto 0);
    
    --------------------------------------------
    signal tout_cnt_sig : std_logic_vector(19 downto 0) := (others => '0');
    signal iic_tout_sig : std_logic;
    signal waw_dly_cnt  : std_logic_vector(19 downto 0) := (others => '0');
    --------------------------------------------
    signal fifo_rd_en_sig               : std_logic:= '0';
    signal nvram_addr_sig               : std_logic_vector(16 downto 0) := (others => '0');
    signal nvram_data_sig               : std_logic_vector(15 downto 0) := (others => '0');
    signal nvram_rd_wrn_sig             : std_logic:= '0';
    signal nvram_en_sig                 : std_logic:= '0';  
    --------------------------------------------
    signal nvram_rd_done_sig            : std_logic:= '0';
    signal nvram_wr_done_sig            : std_logic:= '0';
    signal nvram_busy_sig               : std_logic:= '0'; 
    signal start_rd_flag_sig            : std_logic:= '0';
    signal ff_start_rd_flag_sig         : std_logic:= '0';    
    
    --------------------------------------------
    signal err_wrong_st_sig             : std_logic:= '0';    
    --------------------------------------------
    signal instruction_st_num_sig       : std_logic_vector(7 downto 0) := (others => '0');
    signal main_st_num_sig       : std_logic_vector(7 downto 0) := (others => '0');
    --------------------------------------------
    signal ff_wr_done_sig       : std_logic_vector(3 downto 0) := (others => '0');
    signal ff_rd_done_sig       : std_logic_vector(3 downto 0) := (others => '0');
    --------------------------------------------
    signal wr_done_cnt_sig         : std_logic_vector(9 downto 0) := (others => '0');
    signal wr_done_latch_sig             : std_logic:= '0';  
    signal rd_done_latch_sig             : std_logic:= '0';  
    --------------------------------------------    
 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of main_st_num_sig,instruction_st_num_sig,ff_wr_done_sig,ff_rd_done_sig,nvram_busy_sig,instruction_sm_sig : signal is "true";
  attribute DONT_TOUCH of main_sm_sig : signal is "true";
  attribute DONT_TOUCH of err_illegal_instruction_cnt_sig : signal is "true";
   
    begin
        write_done_cnt_proc:process(CLK) is
        begin
            if rising_edge(CLK) then
                if (RESET = '1') then
                    wr_done_cnt_sig <= (others => '0'); 
                else
                     if (REGS_DATA(29) = '1' and regs_data_sig(29) = '0' and REGS_DATA(30) = '0') then --reset counter 
                        wr_done_cnt_sig <= (others => '0'); 
                     elsif (IIC_WR_DONE = '1' and ff_wr_done_sig(0) = '0') then
                        wr_done_cnt_sig <= std_logic_vector(unsigned(wr_done_cnt_sig)+ "1");
                     else
                        wr_done_cnt_sig <= wr_done_cnt_sig;
                     end if;
                end if;
            end if;
        end process;
        status_reg_proc:process(CLK) is
        begin
            if rising_edge(CLK) then
                if (RESET = '1') then
                    status_reg_sig <= (others => '0');
                    wr_done_latch_sig <= '0';
                    rd_done_latch_sig <= '0';
                else
                     if (IIC_WR_DONE = '1' and ff_wr_done_sig(0) = '0') then -- write done latching
                        wr_done_latch_sig <= IIC_WR_DONE;
                     elsif (REGS_DATA(31) = '1' and regs_data_sig(31) = '0' and REGS_DATA(30) = '0') then -- next write
                        wr_done_latch_sig <= '0';
                     else
                        wr_done_latch_sig <= wr_done_latch_sig;
                     end if;
                     if (IIC_RD_DONE = '1' and ff_rd_done_sig(0) = '0') then -- read done latching
                        rd_done_latch_sig <= IIC_RD_DONE;
                     elsif (REGS_DATA(31) = '1' and regs_data_sig(31) = '0' and REGS_DATA(30) = '1') then -- next read
                        rd_done_latch_sig <= '0';
                     else
                        rd_done_latch_sig <= rd_done_latch_sig;
                     end if;
                     if (REGS_DATA(29) = '1' and regs_data_sig(29) = '0' and REGS_DATA(30) = '0') then --reset status register
                        status_reg_sig <= (others => '0'); 
                     else
                        status_reg_sig(0) <= fifo_full_sig;
                        status_reg_sig(1) <= fifo_empty_sig;
                        status_reg_sig(2) <= nvram_busy_sig;
                        status_reg_sig(3) <= rd_done_latch_sig;
                        status_reg_sig(4) <= wr_done_latch_sig;
                        status_reg_sig(15 downto 8) <= fifo_rd_datacount_sig;
                        status_reg_sig(25 downto 16) <= wr_done_cnt_sig;
                     end if;
                end if;
            end if;
        end process;
        fifo_wr_ctrl_proc:process(CLK) is
        begin
            if rising_Edge(CLK) then
                if (RESET = '1') then
                    sr_wr_en_sig <= (others => '0');
                    fifo_wr_en_sig <= '0';
                    start_rd_flag_sig <= '0';
                    instruction_sm_sig <= idle_st;
                    err_wrong_st_sig <= '0';
                    instruction_st_num_sig <= (others => '0');
                    ff_rd_done_sig <= (others => '0');
                    ff_wr_done_sig <= (others => '0');
                else
                    --------------------------------------------------------

                    ff_rd_done_sig <= ff_rd_done_sig(2 downto 0)&IIC_RD_DONE ;
                    ff_wr_done_sig <= ff_wr_done_sig(2 downto 0)&IIC_WR_DONE ;
                     --------------------------------------------------------                   
                    case instruction_sm_sig is
                    when idle_st =>
                        instruction_st_num_sig <= x"01";
                        fifo_wr_en_sig <= '0';
                        regs_addr_sig  <=       REGS_ADDR ;
                        if (REGS_ADDR(31) = '1' and regs_addr_sig(31) = '0') then
                            instruction_sm_sig <= wait_data_st;
                            instruction_vec_sig(31 downto 0) <= '0'&REGS_ADDR(30 downto 0);
                        else
                            instruction_vec_sig <= instruction_vec_sig ;
                            instruction_sm_sig <= idle_st;
                        end if;
                    when wait_data_st =>
                        instruction_st_num_sig <= x"02";
--                        regs_addr_sig <= (others => '0');
                        regs_data_sig  <=       REGS_DATA ;
                        if (REGS_DATA(31) = '1' and regs_data_sig(31) = '0'  and REGS_DATA(30) = '1' ) then -- read
                            instruction_sm_sig <= wait_read_st;
                            start_rd_flag_sig <= '1';
                            instruction_vec_sig(63 downto 32) <= '0'&REGS_DATA(30 downto 0);
                        elsif (REGS_DATA(31) = '1' and regs_data_sig(31) = '0' and REGS_DATA(30) = '0') then -- write
                            instruction_sm_sig <= push_inst_st;
                            start_rd_flag_sig <= start_rd_flag_sig;
                            instruction_vec_sig(63 downto 32) <= '0'&REGS_DATA(30 downto 0);
                        else
                            instruction_sm_sig <= wait_data_st;
                            start_rd_flag_sig <= start_rd_flag_sig;
                            instruction_vec_sig <= instruction_vec_sig;
                        end if;

                    when wait_read_st => 
                        instruction_st_num_sig <= x"03";
                        if (IIC_RD_DONE = '1' and ff_rd_done_sig(0) = '0') then 
                            start_rd_flag_sig <= '0';
                            instruction_sm_sig <= idle_st;
                        else
                            start_rd_flag_sig <= start_rd_flag_sig;
                            instruction_sm_sig <= wait_read_st;
                        end if;
                    when push_inst_st =>
                        instruction_st_num_sig <= x"04";
--                        regs_data_sig <= (others => '0');
                         fifo_wr_en_sig <= '1';
                         instruction_sm_sig <= idle_st;
                    when others=>
                         instruction_st_num_sig <= x"05";
                         instruction_sm_sig <= idle_st;
                         err_wrong_st_sig  <= '1';
                    end case;
                end if;
            end if;
        end process;
        --------------------------------------------
        FIFO_WR_EN <= fifo_wr_en_sig;
        FIFO_RD_EN <= fifo_rd_en_sig;
        fifo_full_sig <= FIFO_FULL;
        fifo_empty_sig <= FIFO_EMPTY;
        FIFO_WR_DATA <= instruction_vec_sig;
        fifo_rd_datacount_sig <= FIFO_DATA_COUNT;
        --------------------------------------------
        fifo_rd_ctrl_proc:process(CLK) is
            begin
                if rising_Edge(CLK) then
                    if (RESET = '1') then
                        main_sm_sig <= idle_st;
                        fifo_rd_en_sig    <= '0';
                        nvram_addr_sig    <= (others => '0');
                        nvram_data_sig    <= (others => '0');
                        nvram_rd_wrn_sig  <= '0';
                        nvram_en_sig      <= '0';

                        nvram_rd_done_sig <= '0';
                        nvram_wr_done_sig <= '0';
                        nvram_busy_sig    <= '0';
                        err_nvram_tout_cnt_sig    <= (others => '0');
                        err_illegal_instruction_cnt_sig <= (others => '0');
                        err_illegal_state_cnt_sig <= (others => '0');
                        main_st_num_sig <= x"00";
                        waw_dly_cnt <= (others => '0');
                    else
                        case main_sm_sig is
                            when idle_st => 
                                main_st_num_sig <= x"01";
                                nvram_addr_sig    <= (others => '0');
                                nvram_data_sig    <= (others => '0');
                                nvram_rd_wrn_sig  <= '0';
                                nvram_en_sig      <= '0';
                                ff_start_rd_flag_sig <= start_rd_flag_sig ;
                                err_nvram_tout_cnt_sig    <= err_nvram_tout_cnt_sig;
                                err_illegal_instruction_cnt_sig <= err_illegal_instruction_cnt_sig;
                                err_illegal_state_cnt_sig <= err_illegal_state_cnt_sig;
                                if (start_rd_flag_sig = '1' and ff_start_rd_flag_sig = '0') then
                                    main_sm_sig <= send_rd_st;
                                    nvram_rd_done_sig <= '0';
                                elsif (FIFO_EMPTY = '0') then
                                    main_sm_sig <= wait1_st;
                                    fifo_rd_en_sig <= '1';
                                    nvram_wr_done_sig <= '0';
                                    nvram_busy_sig    <= '0';
                                else
                                    main_sm_sig <= idle_st;
                                    fifo_rd_en_sig <= '0';
                                    nvram_rd_done_sig <= nvram_rd_done_sig;
                                    nvram_wr_done_sig <= nvram_wr_done_sig;
                                    nvram_busy_sig    <= nvram_busy_sig;
                                end if;
                            when wait1_st => 
                                 main_sm_sig <= pull_st;
                                 fifo_rd_en_sig <= '0';
                            when pull_st =>
                                main_st_num_sig <= x"02";
                                fifo_rd_en_sig      <= '0';
                                nvram_addr_sig      <= FIFO_RD_DATA(16 downto 0);
                                nvram_data_sig      <= FIFO_RD_DATA(47 downto 32);
                                nvram_rd_wrn_sig    <= FIFO_RD_DATA(62);
                                nvram_en_sig        <= '1';
                                nvram_rd_done_sig <= nvram_rd_done_sig;
                                nvram_wr_done_sig <= nvram_wr_done_sig;
                                err_nvram_tout_cnt_sig    <= err_nvram_tout_cnt_sig;
                                err_illegal_state_cnt_sig    <= err_illegal_state_cnt_sig;
                                nvram_busy_sig    <= nvram_busy_sig;
                                if (FIFO_RD_DATA(62) = '0') then -- write
                                    main_sm_sig <= wait_wr_st;
                                    err_illegal_instruction_cnt_sig <= err_illegal_instruction_cnt_sig;
                                    nvram_busy_sig <= '1';
--                                elsif (FIFO_RD_DATA(62) = '1') then -- read
--                                    main_sm_sig <= wait_rd_st;
--                                    err_illegal_instruction_cnt_sig <= err_illegal_instruction_cnt_sig;
--                                    nvram_busy_sig <= '1';
                                else
                                    main_sm_sig <= idle_st;
                                    err_illegal_instruction_cnt_sig <= std_logic_vector(unsigned(err_illegal_instruction_cnt_sig)+ "1");
                                    nvram_busy_sig <= '0';
                                end if;
                            when wait_wr_st =>
                                main_st_num_sig <= x"03";
                                fifo_rd_en_sig   <= fifo_rd_en_sig  ;
                                nvram_addr_sig   <= nvram_addr_sig  ;
                                nvram_data_sig   <= nvram_data_sig  ;
                                nvram_rd_wrn_sig <= nvram_rd_wrn_sig;
                                nvram_en_sig     <= '0'    ;
                                err_illegal_state_cnt_sig     <= err_illegal_state_cnt_sig    ;
                                err_illegal_instruction_cnt_sig     <= err_illegal_instruction_cnt_sig    ;
                                nvram_wr_done_sig <= nvram_wr_done_sig;
                                if (IIC_WR_DONE = '1' and ff_wr_done_sig(0) = '0') then
--                                    main_sm_sig <= idle_st;
                                    main_sm_sig <= waw_st;                                    
                                elsif (iic_tout_sig = '1') then
                                    main_sm_sig <= idle_st;
                                    nvram_wr_done_sig <= '1';
                                    err_nvram_tout_cnt_sig <= std_logic_vector(unsigned(err_nvram_tout_cnt_sig)+ "1");
                                    nvram_busy_sig <= '0';
                                else
                                    main_sm_sig <= wait_wr_st;
                                    err_nvram_tout_cnt_sig <= err_nvram_tout_cnt_sig;
                                    nvram_busy_sig <= '1';
                                end if;
                            when waw_st => --wait after write state
                                if (waw_dly_cnt = x"649F0") then -- 9msec
                                    nvram_busy_sig <= '0';
                                    err_nvram_tout_cnt_sig  <= (others => '0');
                                    waw_dly_cnt             <= (others => '0');
                                    nvram_wr_done_sig <= '1';
                                    main_sm_sig <= idle_st;
                                 else
                                    err_nvram_tout_cnt_sig <= err_nvram_tout_cnt_sig;
                                    nvram_wr_done_sig <= nvram_wr_done_sig;
                                    waw_dly_cnt <= std_logic_vector(unsigned(waw_dly_cnt)+ "1");
                                    nvram_busy_sig <= nvram_busy_sig;
                                    main_sm_sig <= waw_st;
                                 end if;

                            when send_rd_st => 
                                main_st_num_sig <= x"04";
                                nvram_addr_sig      <= instruction_vec_sig(16 downto 0);
                                nvram_data_sig      <= instruction_vec_sig(47 downto 32);
                                nvram_rd_wrn_sig    <= '1';
                                nvram_en_sig        <= '1';
                                main_sm_sig <= wait_rd_st;
                            when wait_rd_st =>
                                main_st_num_sig <= x"05";
                                fifo_rd_en_sig   <= fifo_rd_en_sig  ;
                                nvram_addr_sig   <= nvram_addr_sig  ;
                                nvram_data_sig   <= nvram_data_sig  ;
                                nvram_rd_wrn_sig <= nvram_rd_wrn_sig;
                                nvram_en_sig     <= '0'    ;
                                err_illegal_state_cnt_sig     <= err_illegal_state_cnt_sig    ;
                                err_illegal_instruction_cnt_sig     <= err_illegal_instruction_cnt_sig    ;
                                if (IIC_RD_DONE = '1' and ff_rd_done_sig(0) = '0') then
                                    main_sm_sig <= idle_st;
                                    nvram_rd_done_sig   <= '1';
                                    err_nvram_tout_cnt_sig      <= (others => '0');
                                    nvram_busy_sig      <= '0';
                                elsif (iic_tout_sig = '1') then
                                    main_sm_sig         <= idle_st;
                                    nvram_rd_done_sig   <= '1';
                                    err_nvram_tout_cnt_sig <= std_logic_vector(unsigned(err_nvram_tout_cnt_sig)+ "1");
                                    nvram_busy_sig      <= '0';
                                else
                                    main_sm_sig <= wait_rd_st;
                                    nvram_rd_done_sig <= '0';
                                    err_nvram_tout_cnt_sig <= err_nvram_tout_cnt_sig;
                                    nvram_busy_sig <= '1';
                                end if;
                            when others =>
                                main_st_num_sig <= x"06";
                                main_sm_sig <= idle_st;
                                err_illegal_state_cnt_sig <= std_logic_vector(unsigned(err_illegal_state_cnt_sig)+ "1");
                        end case;
                    end if;
                end if;
            end process;
        --------------------------------------------
        NVRAM_DATA   <= nvram_data_sig;
        NVRAM_ADDR   <= nvram_addr_sig;
        NVRAM_RD_WRn <= nvram_rd_wrn_sig;
        NVRAM_ENABLE <= nvram_en_sig;
        REG_STATUS   <= status_reg_sig;

        --------------------------------------------
        tout_proc:process(CLK) is
        begin
            if rising_edge(CLK) then
                if (RESET = '1') then
                    tout_cnt_sig <= (others => '0');
                    iic_tout_sig <= '0';
                else
                    if (tout_cnt_sig = G_TOUT ) then
                        tout_cnt_sig <= (others => '0');
                        iic_tout_sig <= '1';
                    elsif ((tout_cnt_sig /= G_TOUT)  and (main_sm_sig = wait_rd_st or  main_sm_sig = wait_wr_st)) then
                        tout_cnt_sig <= std_logic_vector(unsigned(tout_cnt_sig)+ "1");
                        iic_tout_sig <= '0';
                    elsif (tout_cnt_sig /= G_TOUT  and main_sm_sig /= wait_rd_st and  main_sm_sig /= wait_wr_st) then
                        tout_cnt_sig <= (others => '0');
                        iic_tout_sig <= '0';
                    else
                        tout_cnt_sig <= tout_cnt_sig;
                        iic_tout_sig <= iic_tout_sig;
                    end if;
                end if;
            end if;
        end process;
        --------------------------------------------
end architecture;
