-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Tue Sep 13 16:40:45 2022
-- Host        : YY529462 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               C:/PR/Vivado/Spartan7_tmc/Spartan7_tmc.runs/axi4_master_vhdl_0_synth_1/axi4_master_vhdl_0_sim_netlist.vhdl
-- Design      : axi4_master_vhdl_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7s75fgga484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity axi4_master_vhdl_0_axi4_master_vhdl_v1_0_M00_AXI is
  port (
    \out\ : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_awvalid : out STD_LOGIC;
    m00_axi_rready : out STD_LOGIC;
    m00_axi_arvalid : out STD_LOGIC;
    m00_axi_wlast : out STD_LOGIC;
    m00_axi_wvalid : out STD_LOGIC;
    m00_axi_error : out STD_LOGIC;
    \master_axi_state[2]\ : out STD_LOGIC_VECTOR ( 2 downto 0 );
    fifo_rd_en : out STD_LOGIC;
    m00_axi_awlen : out STD_LOGIC_VECTOR ( 1 downto 0 );
    \write_index_reg[0]_0\ : out STD_LOGIC;
    reads_done_reg_0 : out STD_LOGIC;
    m00_axi_bready : out STD_LOGIC;
    m00_axi_aclk : in STD_LOGIC;
    m00_axi_aresetn : in STD_LOGIC;
    start_write : in STD_LOGIC;
    start_read : in STD_LOGIC;
    m00_axi_rvalid : in STD_LOGIC;
    m00_axi_rlast : in STD_LOGIC;
    m00_axi_wready : in STD_LOGIC;
    write_burst_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    read_burst_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi_if_req : in STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_awready : in STD_LOGIC;
    m00_axi_arready : in STD_LOGIC;
    m00_axi_bvalid : in STD_LOGIC;
    m00_axi_rresp : in STD_LOGIC_VECTOR ( 0 to 0 );
    m00_axi_bresp : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of axi4_master_vhdl_0_axi4_master_vhdl_v1_0_M00_AXI : entity is "axi4_master_vhdl_v1_0_M00_AXI";
end axi4_master_vhdl_0_axi4_master_vhdl_v1_0_M00_AXI;

architecture STRUCTURE of axi4_master_vhdl_0_axi4_master_vhdl_v1_0_M00_AXI is
  signal \FSM_onehot_gnt_ps[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_gnt_ps[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_gnt_ps[2]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_gnt_ps[2]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_onehot_gnt_ps[2]_i_5_n_0\ : STD_LOGIC;
  signal \FSM_onehot_gnt_ps[2]_i_6_n_0\ : STD_LOGIC;
  signal \FSM_onehot_gnt_ps[2]_i_7_n_0\ : STD_LOGIC;
  signal \FSM_sequential_mst_exec_state[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_mst_exec_state[1]_i_1_n_0\ : STD_LOGIC;
  signal axi_arvalid_i_1_n_0 : STD_LOGIC;
  signal axi_arvalid_i_2_n_0 : STD_LOGIC;
  signal axi_awvalid_i_1_n_0 : STD_LOGIC;
  signal axi_awvalid_i_2_n_0 : STD_LOGIC;
  signal axi_bready_i_1_n_0 : STD_LOGIC;
  signal axi_rready_i_1_n_0 : STD_LOGIC;
  signal axi_wlast_i_10_n_0 : STD_LOGIC;
  signal axi_wlast_i_11_n_0 : STD_LOGIC;
  signal axi_wlast_i_12_n_0 : STD_LOGIC;
  signal axi_wlast_i_13_n_0 : STD_LOGIC;
  signal axi_wlast_i_1_n_0 : STD_LOGIC;
  signal axi_wlast_i_2_n_0 : STD_LOGIC;
  signal axi_wlast_i_3_n_0 : STD_LOGIC;
  signal axi_wlast_i_4_n_0 : STD_LOGIC;
  signal axi_wlast_i_5_n_0 : STD_LOGIC;
  signal axi_wlast_i_6_n_0 : STD_LOGIC;
  signal axi_wlast_i_7_n_0 : STD_LOGIC;
  signal axi_wlast_i_8_n_0 : STD_LOGIC;
  signal axi_wlast_i_9_n_0 : STD_LOGIC;
  signal axi_wvalid_i_1_n_0 : STD_LOGIC;
  signal burst_read_active : STD_LOGIC;
  signal burst_read_active_i_1_n_0 : STD_LOGIC;
  signal burst_write_active : STD_LOGIC;
  signal burst_write_active_i_1_n_0 : STD_LOGIC;
  signal error_reg_i_1_n_0 : STD_LOGIC;
  signal fq_ev_sel : STD_LOGIC;
  signal fq_ev_sel_i_1_n_0 : STD_LOGIC;
  signal fq_ev_sel_reg_n_0 : STD_LOGIC;
  signal gnt_hold : STD_LOGIC;
  signal gnt_hold_i_1_n_0 : STD_LOGIC;
  signal gnt_hold_i_3_n_0 : STD_LOGIC;
  signal gnt_hold_i_4_n_0 : STD_LOGIC;
  signal \gnt_ps111_out__1\ : STD_LOGIC;
  signal \gnt_ps18_out__0\ : STD_LOGIC;
  signal gnt_sw : STD_LOGIC;
  signal gnt_sw_pre : STD_LOGIC;
  signal gnt_sw_pre_i_1_n_0 : STD_LOGIC;
  signal gnt_sw_pre_i_2_n_0 : STD_LOGIC;
  signal \^m00_axi_arvalid\ : STD_LOGIC;
  signal \^m00_axi_awlen\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal \^m00_axi_awvalid\ : STD_LOGIC;
  signal \^m00_axi_bready\ : STD_LOGIC;
  signal \^m00_axi_error\ : STD_LOGIC;
  signal \^m00_axi_rready\ : STD_LOGIC;
  signal \^m00_axi_wlast\ : STD_LOGIC;
  signal \^m00_axi_wvalid\ : STD_LOGIC;
  signal mst_exec_state : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of mst_exec_state : signal is "yes";
  signal \^out\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  attribute RTL_KEEP of \^out\ : signal is "yes";
  signal p_19_in : STD_LOGIC;
  signal p_30_in : STD_LOGIC;
  signal plusOp : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \plusOp__0\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal read_burst_counter : STD_LOGIC;
  signal \read_burst_counter[0]_i_1_n_0\ : STD_LOGIC;
  signal read_index0 : STD_LOGIC;
  signal read_index1 : STD_LOGIC;
  signal read_index1_carry_i_1_n_0 : STD_LOGIC;
  signal read_index1_carry_i_2_n_0 : STD_LOGIC;
  signal read_index1_carry_i_3_n_0 : STD_LOGIC;
  signal read_index1_carry_i_4_n_0 : STD_LOGIC;
  signal read_index1_carry_i_5_n_0 : STD_LOGIC;
  signal read_index1_carry_i_6_n_0 : STD_LOGIC;
  signal read_index1_carry_i_7_n_0 : STD_LOGIC;
  signal read_index1_carry_i_8_n_0 : STD_LOGIC;
  signal read_index1_carry_i_9_n_0 : STD_LOGIC;
  signal read_index1_carry_n_1 : STD_LOGIC;
  signal read_index1_carry_n_2 : STD_LOGIC;
  signal read_index1_carry_n_3 : STD_LOGIC;
  signal \read_index[7]_i_1_n_0\ : STD_LOGIC;
  signal \read_index[7]_i_4_n_0\ : STD_LOGIC;
  signal \read_index_reg__0\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal reads_done : STD_LOGIC;
  signal reads_done_i_1_n_0 : STD_LOGIC;
  signal reads_done_i_2_n_0 : STD_LOGIC;
  signal reads_done_i_3_n_0 : STD_LOGIC;
  signal reads_done_i_4_n_0 : STD_LOGIC;
  signal reads_done_i_5_n_0 : STD_LOGIC;
  signal reads_done_i_6_n_0 : STD_LOGIC;
  signal \^reads_done_reg_0\ : STD_LOGIC;
  signal start_single_burst_read_i_1_n_0 : STD_LOGIC;
  signal start_single_burst_read_reg_n_0 : STD_LOGIC;
  signal start_single_burst_write_i_1_n_0 : STD_LOGIC;
  signal start_single_burst_write_reg_n_0 : STD_LOGIC;
  signal write_burst_counter : STD_LOGIC;
  signal \write_burst_counter[0]_i_1_n_0\ : STD_LOGIC;
  signal write_index0 : STD_LOGIC;
  signal \write_index[7]_i_10_n_0\ : STD_LOGIC;
  signal \write_index[7]_i_1_n_0\ : STD_LOGIC;
  signal \write_index[7]_i_4_n_0\ : STD_LOGIC;
  signal \write_index[7]_i_5_n_0\ : STD_LOGIC;
  signal \write_index[7]_i_6_n_0\ : STD_LOGIC;
  signal \write_index[7]_i_8_n_0\ : STD_LOGIC;
  signal \write_index[7]_i_9_n_0\ : STD_LOGIC;
  signal \^write_index_reg[0]_0\ : STD_LOGIC;
  signal \write_index_reg__0\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal writes_done : STD_LOGIC;
  signal writes_done_i_1_n_0 : STD_LOGIC;
  signal NLW_read_index1_carry_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_onehot_gnt_ps[2]_i_3\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \FSM_onehot_gnt_ps[2]_i_4\ : label is "soft_lutpair7";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_onehot_gnt_ps_reg[0]\ : label is "fq_st:010,ev_st:100,rd_st:001";
  attribute KEEP : string;
  attribute KEEP of \FSM_onehot_gnt_ps_reg[0]\ : label is "yes";
  attribute FSM_ENCODED_STATES of \FSM_onehot_gnt_ps_reg[1]\ : label is "fq_st:010,ev_st:100,rd_st:001";
  attribute KEEP of \FSM_onehot_gnt_ps_reg[1]\ : label is "yes";
  attribute FSM_ENCODED_STATES of \FSM_onehot_gnt_ps_reg[2]\ : label is "fq_st:010,ev_st:100,rd_st:001";
  attribute KEEP of \FSM_onehot_gnt_ps_reg[2]\ : label is "yes";
  attribute FSM_ENCODED_STATES of \FSM_sequential_mst_exec_state_reg[0]\ : label is "init_write:01,init_read:10,idle:00";
  attribute KEEP of \FSM_sequential_mst_exec_state_reg[0]\ : label is "yes";
  attribute FSM_ENCODED_STATES of \FSM_sequential_mst_exec_state_reg[1]\ : label is "init_write:01,init_read:10,idle:00";
  attribute KEEP of \FSM_sequential_mst_exec_state_reg[1]\ : label is "yes";
  attribute SOFT_HLUTNM of axi_arvalid_i_2 : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of axi_awvalid_i_2 : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of axi_bready_i_1 : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of axi_rready_i_1 : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of axi_wlast_i_12 : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of axi_wlast_i_7 : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of axi_wvalid_i_1 : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of burst_write_active_i_1 : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of error_reg_i_2 : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of fifo_rd_en_INST_0 : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \m00_axi_awlen[1]_INST_0\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \read_burst_counter[0]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of read_index1_carry_i_9 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \read_index[1]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \read_index[2]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \read_index[3]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \read_index[4]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \read_index[6]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \read_index[7]_i_3\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of reads_done_i_5 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \write_burst_counter[0]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \write_index[0]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \write_index[1]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \write_index[2]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \write_index[3]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \write_index[4]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \write_index[6]_i_1\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \write_index[7]_i_10\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \write_index[7]_i_3\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \write_index[7]_i_6\ : label is "soft_lutpair15";
begin
  m00_axi_arvalid <= \^m00_axi_arvalid\;
  m00_axi_awlen(1 downto 0) <= \^m00_axi_awlen\(1 downto 0);
  m00_axi_awvalid <= \^m00_axi_awvalid\;
  m00_axi_bready <= \^m00_axi_bready\;
  m00_axi_error <= \^m00_axi_error\;
  m00_axi_rready <= \^m00_axi_rready\;
  m00_axi_wlast <= \^m00_axi_wlast\;
  m00_axi_wvalid <= \^m00_axi_wvalid\;
  \out\(2 downto 0) <= \^out\(2 downto 0);
  reads_done_reg_0 <= \^reads_done_reg_0\;
  \write_index_reg[0]_0\ <= \^write_index_reg[0]_0\;
\FSM_onehot_gnt_ps[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0E00FFFF0E000000"
    )
        port map (
      I0 => \^out\(1),
      I1 => \^out\(2),
      I2 => gnt_hold,
      I3 => axi_if_req(0),
      I4 => \FSM_onehot_gnt_ps[2]_i_5_n_0\,
      I5 => \^out\(0),
      O => \FSM_onehot_gnt_ps[0]_i_1_n_0\
    );
\FSM_onehot_gnt_ps[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4F44FFFF4F440000"
    )
        port map (
      I0 => \gnt_ps18_out__0\,
      I1 => \^out\(2),
      I2 => \gnt_ps111_out__1\,
      I3 => \^out\(0),
      I4 => \FSM_onehot_gnt_ps[2]_i_5_n_0\,
      I5 => \^out\(1),
      O => \FSM_onehot_gnt_ps[1]_i_1_n_0\
    );
\FSM_onehot_gnt_ps[2]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => m00_axi_aresetn,
      O => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
\FSM_onehot_gnt_ps[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F444FFFFF4440000"
    )
        port map (
      I0 => \gnt_ps18_out__0\,
      I1 => \^out\(1),
      I2 => \gnt_ps111_out__1\,
      I3 => \^out\(0),
      I4 => \FSM_onehot_gnt_ps[2]_i_5_n_0\,
      I5 => \^out\(2),
      O => \FSM_onehot_gnt_ps[2]_i_2_n_0\
    );
\FSM_onehot_gnt_ps[2]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => axi_if_req(0),
      I1 => gnt_hold,
      O => \gnt_ps18_out__0\
    );
\FSM_onehot_gnt_ps[2]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0444"
    )
        port map (
      I0 => gnt_hold,
      I1 => axi_if_req(2),
      I2 => fq_ev_sel_reg_n_0,
      I3 => axi_if_req(1),
      O => \gnt_ps111_out__1\
    );
\FSM_onehot_gnt_ps[2]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"000E"
    )
        port map (
      I0 => \FSM_onehot_gnt_ps[2]_i_6_n_0\,
      I1 => \FSM_onehot_gnt_ps[2]_i_7_n_0\,
      I2 => mst_exec_state(1),
      I3 => mst_exec_state(0),
      O => \FSM_onehot_gnt_ps[2]_i_5_n_0\
    );
\FSM_onehot_gnt_ps[2]_i_6\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000FAFA0000F888"
    )
        port map (
      I0 => \^out\(2),
      I1 => axi_if_req(1),
      I2 => \^out\(1),
      I3 => axi_if_req(2),
      I4 => gnt_hold,
      I5 => axi_if_req(0),
      O => \FSM_onehot_gnt_ps[2]_i_6_n_0\
    );
\FSM_onehot_gnt_ps[2]_i_7\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2220"
    )
        port map (
      I0 => \^out\(0),
      I1 => gnt_hold,
      I2 => axi_if_req(2),
      I3 => axi_if_req(1),
      O => \FSM_onehot_gnt_ps[2]_i_7_n_0\
    );
\FSM_onehot_gnt_ps_reg[0]\: unisim.vcomponents.FDSE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axi_aclk,
      CE => '1',
      D => \FSM_onehot_gnt_ps[0]_i_1_n_0\,
      Q => \^out\(0),
      S => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
\FSM_onehot_gnt_ps_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axi_aclk,
      CE => '1',
      D => \FSM_onehot_gnt_ps[1]_i_1_n_0\,
      Q => \^out\(1),
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
\FSM_onehot_gnt_ps_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axi_aclk,
      CE => '1',
      D => \FSM_onehot_gnt_ps[2]_i_2_n_0\,
      Q => \^out\(2),
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
\FSM_sequential_mst_exec_state[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"005C"
    )
        port map (
      I0 => writes_done,
      I1 => start_write,
      I2 => mst_exec_state(0),
      I3 => mst_exec_state(1),
      O => \FSM_sequential_mst_exec_state[0]_i_1_n_0\
    );
\FSM_sequential_mst_exec_state[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"10101310"
    )
        port map (
      I0 => reads_done,
      I1 => mst_exec_state(0),
      I2 => mst_exec_state(1),
      I3 => start_read,
      I4 => start_write,
      O => \FSM_sequential_mst_exec_state[1]_i_1_n_0\
    );
\FSM_sequential_mst_exec_state_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => \FSM_sequential_mst_exec_state[0]_i_1_n_0\,
      Q => mst_exec_state(0),
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
\FSM_sequential_mst_exec_state_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => \FSM_sequential_mst_exec_state[1]_i_1_n_0\,
      Q => mst_exec_state(1),
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
axi_arvalid_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => start_read,
      I1 => m00_axi_aresetn,
      O => axi_arvalid_i_1_n_0
    );
axi_arvalid_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"74"
    )
        port map (
      I0 => m00_axi_arready,
      I1 => \^m00_axi_arvalid\,
      I2 => start_single_burst_read_reg_n_0,
      O => axi_arvalid_i_2_n_0
    );
axi_arvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => axi_arvalid_i_2_n_0,
      Q => \^m00_axi_arvalid\,
      R => axi_arvalid_i_1_n_0
    );
axi_awvalid_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => start_write,
      I1 => m00_axi_aresetn,
      O => axi_awvalid_i_1_n_0
    );
axi_awvalid_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"74"
    )
        port map (
      I0 => m00_axi_awready,
      I1 => \^m00_axi_awvalid\,
      I2 => start_single_burst_write_reg_n_0,
      O => axi_awvalid_i_2_n_0
    );
axi_awvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => axi_awvalid_i_2_n_0,
      Q => \^m00_axi_awvalid\,
      R => axi_awvalid_i_1_n_0
    );
axi_bready_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"4"
    )
        port map (
      I0 => \^m00_axi_bready\,
      I1 => m00_axi_bvalid,
      O => axi_bready_i_1_n_0
    );
axi_bready_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => axi_bready_i_1_n_0,
      Q => \^m00_axi_bready\,
      R => axi_awvalid_i_1_n_0
    );
axi_rready_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"04404440"
    )
        port map (
      I0 => start_read,
      I1 => m00_axi_aresetn,
      I2 => m00_axi_rvalid,
      I3 => \^m00_axi_rready\,
      I4 => m00_axi_rlast,
      O => axi_rready_i_1_n_0
    );
axi_rready_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => axi_rready_i_1_n_0,
      Q => \^m00_axi_rready\,
      R => '0'
    );
axi_wlast_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF5575FFFF0030"
    )
        port map (
      I0 => axi_wlast_i_2_n_0,
      I1 => axi_wlast_i_3_n_0,
      I2 => axi_wlast_i_4_n_0,
      I3 => axi_wlast_i_5_n_0,
      I4 => axi_wlast_i_6_n_0,
      I5 => \^m00_axi_wlast\,
      O => axi_wlast_i_1_n_0
    );
axi_wlast_i_10: unisim.vcomponents.LUT6
    generic map(
      INIT => X"E5A5BFFFBFFFE5A5"
    )
        port map (
      I0 => write_burst_len(1),
      I1 => \write_index_reg__0\(2),
      I2 => \write_index_reg__0\(1),
      I3 => \write_index_reg__0\(3),
      I4 => \write_index_reg__0\(4),
      I5 => write_burst_len(4),
      O => axi_wlast_i_10_n_0
    );
axi_wlast_i_11: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F6666FFF6FFFF666"
    )
        port map (
      I0 => \write_index_reg__0\(0),
      I1 => write_burst_len(0),
      I2 => \write_index_reg__0\(1),
      I3 => \write_index_reg__0\(2),
      I4 => \write_index_reg__0\(3),
      I5 => write_burst_len(3),
      O => axi_wlast_i_11_n_0
    );
axi_wlast_i_12: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => write_burst_len(6),
      I1 => write_burst_len(4),
      I2 => write_burst_len(5),
      I3 => write_burst_len(7),
      O => axi_wlast_i_12_n_0
    );
axi_wlast_i_13: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => \write_index_reg__0\(5),
      I1 => \write_index_reg__0\(3),
      I2 => \write_index_reg__0\(1),
      I3 => \write_index_reg__0\(2),
      I4 => \write_index_reg__0\(4),
      O => axi_wlast_i_13_n_0
    );
axi_wlast_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF00001000"
    )
        port map (
      I0 => axi_wlast_i_7_n_0,
      I1 => write_burst_len(0),
      I2 => write_burst_len(1),
      I3 => \^m00_axi_wlast\,
      I4 => axi_wlast_i_8_n_0,
      I5 => p_30_in,
      O => axi_wlast_i_2_n_0
    );
axi_wlast_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFEEFEFFE"
    )
        port map (
      I0 => axi_wlast_i_9_n_0,
      I1 => axi_wlast_i_10_n_0,
      I2 => write_burst_len(2),
      I3 => \write_index_reg__0\(2),
      I4 => \write_index_reg__0\(1),
      I5 => axi_wlast_i_11_n_0,
      O => axi_wlast_i_3_n_0
    );
axi_wlast_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFE000000000000"
    )
        port map (
      I0 => write_burst_len(1),
      I1 => write_burst_len(2),
      I2 => write_burst_len(3),
      I3 => axi_wlast_i_12_n_0,
      I4 => m00_axi_wready,
      I5 => \^m00_axi_wvalid\,
      O => axi_wlast_i_4_n_0
    );
axi_wlast_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F66F9FF6"
    )
        port map (
      I0 => \write_index_reg__0\(7),
      I1 => write_burst_len(7),
      I2 => axi_wlast_i_13_n_0,
      I3 => \write_index_reg__0\(6),
      I4 => write_burst_len(6),
      O => axi_wlast_i_5_n_0
    );
axi_wlast_i_6: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000100000"
    )
        port map (
      I0 => axi_wlast_i_8_n_0,
      I1 => write_burst_len(1),
      I2 => write_burst_len(0),
      I3 => \^m00_axi_wlast\,
      I4 => start_single_burst_write_reg_n_0,
      I5 => axi_wlast_i_7_n_0,
      O => axi_wlast_i_6_n_0
    );
axi_wlast_i_7: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => write_burst_len(4),
      I1 => write_burst_len(5),
      I2 => write_burst_len(7),
      I3 => write_burst_len(6),
      O => axi_wlast_i_7_n_0
    );
axi_wlast_i_8: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => write_burst_len(3),
      I1 => write_burst_len(2),
      O => axi_wlast_i_8_n_0
    );
axi_wlast_i_9: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9666666666666666"
    )
        port map (
      I0 => write_burst_len(5),
      I1 => \write_index_reg__0\(5),
      I2 => \write_index_reg__0\(4),
      I3 => \write_index_reg__0\(2),
      I4 => \write_index_reg__0\(1),
      I5 => \write_index_reg__0\(3),
      O => axi_wlast_i_9_n_0
    );
axi_wlast_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => axi_wlast_i_1_n_0,
      Q => \^m00_axi_wlast\,
      R => axi_awvalid_i_1_n_0
    );
axi_wvalid_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2EEE"
    )
        port map (
      I0 => start_single_burst_write_reg_n_0,
      I1 => \^m00_axi_wvalid\,
      I2 => m00_axi_wready,
      I3 => \^m00_axi_wlast\,
      O => axi_wvalid_i_1_n_0
    );
axi_wvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => axi_wvalid_i_1_n_0,
      Q => \^m00_axi_wvalid\,
      R => axi_awvalid_i_1_n_0
    );
burst_read_active_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FF7FFF00"
    )
        port map (
      I0 => m00_axi_rlast,
      I1 => \^m00_axi_rready\,
      I2 => m00_axi_rvalid,
      I3 => start_single_burst_read_reg_n_0,
      I4 => burst_read_active,
      O => burst_read_active_i_1_n_0
    );
burst_read_active_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => burst_read_active_i_1_n_0,
      Q => burst_read_active,
      R => axi_arvalid_i_1_n_0
    );
burst_write_active_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BFAA"
    )
        port map (
      I0 => start_single_burst_write_reg_n_0,
      I1 => m00_axi_bvalid,
      I2 => \^m00_axi_bready\,
      I3 => burst_write_active,
      O => burst_write_active_i_1_n_0
    );
burst_write_active_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => burst_write_active_i_1_n_0,
      Q => burst_write_active,
      R => axi_awvalid_i_1_n_0
    );
error_reg_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFF8888888"
    )
        port map (
      I0 => m00_axi_rresp(0),
      I1 => p_19_in,
      I2 => m00_axi_bresp(0),
      I3 => m00_axi_bvalid,
      I4 => \^m00_axi_bready\,
      I5 => \^m00_axi_error\,
      O => error_reg_i_1_n_0
    );
error_reg_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^m00_axi_rready\,
      I1 => m00_axi_rvalid,
      O => p_19_in
    );
error_reg_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => error_reg_i_1_n_0,
      Q => \^m00_axi_error\,
      R => axi_arvalid_i_1_n_0
    );
fifo_rd_en_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FF40"
    )
        port map (
      I0 => \^m00_axi_wlast\,
      I1 => \^m00_axi_wvalid\,
      I2 => m00_axi_wready,
      I3 => start_single_burst_write_reg_n_0,
      O => fifo_rd_en
    );
fq_ev_sel_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"BA"
    )
        port map (
      I0 => \^out\(2),
      I1 => \^out\(1),
      I2 => fq_ev_sel_reg_n_0,
      O => fq_ev_sel_i_1_n_0
    );
fq_ev_sel_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => fq_ev_sel_i_1_n_0,
      Q => fq_ev_sel_reg_n_0,
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
gnt_hold_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000CCCEEEEE"
    )
        port map (
      I0 => gnt_hold,
      I1 => \FSM_onehot_gnt_ps[2]_i_5_n_0\,
      I2 => fq_ev_sel,
      I3 => \^out\(0),
      I4 => gnt_hold_i_3_n_0,
      I5 => gnt_hold_i_4_n_0,
      O => gnt_hold_i_1_n_0
    );
gnt_hold_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \^out\(2),
      I1 => \^out\(1),
      O => fq_ev_sel
    );
gnt_hold_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"A8"
    )
        port map (
      I0 => gnt_sw,
      I1 => mst_exec_state(1),
      I2 => mst_exec_state(0),
      O => gnt_hold_i_3_n_0
    );
gnt_hold_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"01FF"
    )
        port map (
      I0 => axi_if_req(0),
      I1 => axi_if_req(1),
      I2 => axi_if_req(2),
      I3 => m00_axi_aresetn,
      O => gnt_hold_i_4_n_0
    );
gnt_hold_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => gnt_hold_i_1_n_0,
      Q => gnt_hold,
      R => '0'
    );
gnt_sw_pre_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFBBAFFFAAAAAAAA"
    )
        port map (
      I0 => gnt_sw_pre_i_2_n_0,
      I1 => writes_done,
      I2 => reads_done,
      I3 => mst_exec_state(1),
      I4 => mst_exec_state(0),
      I5 => gnt_sw_pre,
      O => gnt_sw_pre_i_1_n_0
    );
gnt_sw_pre_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"000E"
    )
        port map (
      I0 => start_read,
      I1 => start_write,
      I2 => mst_exec_state(1),
      I3 => mst_exec_state(0),
      O => gnt_sw_pre_i_2_n_0
    );
gnt_sw_pre_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => gnt_sw_pre_i_1_n_0,
      Q => gnt_sw_pre,
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
gnt_sw_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => gnt_sw_pre,
      Q => gnt_sw,
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
\m00_axi_arlen[7]_INST_0_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
        port map (
      I0 => read_burst_len(4),
      I1 => read_burst_len(2),
      I2 => read_burst_len(0),
      I3 => read_burst_len(1),
      I4 => read_burst_len(3),
      I5 => read_burst_len(5),
      O => \^reads_done_reg_0\
    );
\m00_axi_awlen[1]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => write_burst_len(0),
      I1 => write_burst_len(1),
      O => \^m00_axi_awlen\(0)
    );
\m00_axi_awlen[6]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => \^write_index_reg[0]_0\,
      I1 => write_burst_len(6),
      O => \^m00_axi_awlen\(1)
    );
\m00_axi_awlen[7]_INST_0_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
        port map (
      I0 => write_burst_len(4),
      I1 => write_burst_len(2),
      I2 => write_burst_len(0),
      I3 => write_burst_len(1),
      I4 => write_burst_len(3),
      I5 => write_burst_len(5),
      O => \^write_index_reg[0]_0\
    );
\master_axi_state[0]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => mst_exec_state(0),
      I1 => mst_exec_state(1),
      O => \master_axi_state[2]\(0)
    );
\master_axi_state[1]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => mst_exec_state(0),
      I1 => mst_exec_state(1),
      O => \master_axi_state[2]\(1)
    );
\master_axi_state[2]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => mst_exec_state(1),
      I1 => mst_exec_state(0),
      O => \master_axi_state[2]\(2)
    );
\read_burst_counter[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"F8"
    )
        port map (
      I0 => \^m00_axi_arvalid\,
      I1 => m00_axi_arready,
      I2 => read_burst_counter,
      O => \read_burst_counter[0]_i_1_n_0\
    );
\read_burst_counter_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => \read_burst_counter[0]_i_1_n_0\,
      Q => read_burst_counter,
      R => axi_arvalid_i_1_n_0
    );
read_index1_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => read_index1,
      CO(2) => read_index1_carry_n_1,
      CO(1) => read_index1_carry_n_2,
      CO(0) => read_index1_carry_n_3,
      CYINIT => '1',
      DI(3) => read_index1_carry_i_1_n_0,
      DI(2) => read_index1_carry_i_2_n_0,
      DI(1) => read_index1_carry_i_3_n_0,
      DI(0) => read_index1_carry_i_4_n_0,
      O(3 downto 0) => NLW_read_index1_carry_O_UNCONNECTED(3 downto 0),
      S(3) => read_index1_carry_i_5_n_0,
      S(2) => read_index1_carry_i_6_n_0,
      S(1) => read_index1_carry_i_7_n_0,
      S(0) => read_index1_carry_i_8_n_0
    );
read_index1_carry_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"73311007"
    )
        port map (
      I0 => \read_index_reg__0\(6),
      I1 => \read_index_reg__0\(7),
      I2 => read_burst_len(6),
      I3 => \^reads_done_reg_0\,
      I4 => read_burst_len(7),
      O => read_index1_carry_i_1_n_0
    );
read_index1_carry_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"73311007"
    )
        port map (
      I0 => \read_index_reg__0\(4),
      I1 => \read_index_reg__0\(5),
      I2 => read_burst_len(4),
      I3 => read_index1_carry_i_9_n_0,
      I4 => read_burst_len(5),
      O => read_index1_carry_i_2_n_0
    );
read_index1_carry_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7373733110101007"
    )
        port map (
      I0 => \read_index_reg__0\(2),
      I1 => \read_index_reg__0\(3),
      I2 => read_burst_len(2),
      I3 => read_burst_len(0),
      I4 => read_burst_len(1),
      I5 => read_burst_len(3),
      O => read_index1_carry_i_3_n_0
    );
read_index1_carry_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"3107"
    )
        port map (
      I0 => \read_index_reg__0\(0),
      I1 => \read_index_reg__0\(1),
      I2 => read_burst_len(0),
      I3 => read_burst_len(1),
      O => read_index1_carry_i_4_n_0
    );
read_index1_carry_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"81422814"
    )
        port map (
      I0 => read_burst_len(7),
      I1 => \^reads_done_reg_0\,
      I2 => read_burst_len(6),
      I3 => \read_index_reg__0\(7),
      I4 => \read_index_reg__0\(6),
      O => read_index1_carry_i_5_n_0
    );
read_index1_carry_i_6: unisim.vcomponents.LUT5
    generic map(
      INIT => X"81422814"
    )
        port map (
      I0 => read_burst_len(5),
      I1 => read_index1_carry_i_9_n_0,
      I2 => read_burst_len(4),
      I3 => \read_index_reg__0\(5),
      I4 => \read_index_reg__0\(4),
      O => read_index1_carry_i_6_n_0
    );
read_index1_carry_i_7: unisim.vcomponents.LUT6
    generic map(
      INIT => X"A801540202A80154"
    )
        port map (
      I0 => read_burst_len(3),
      I1 => read_burst_len(1),
      I2 => read_burst_len(0),
      I3 => read_burst_len(2),
      I4 => \read_index_reg__0\(3),
      I5 => \read_index_reg__0\(2),
      O => read_index1_carry_i_7_n_0
    );
read_index1_carry_i_8: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1284"
    )
        port map (
      I0 => read_burst_len(1),
      I1 => read_burst_len(0),
      I2 => \read_index_reg__0\(1),
      I3 => \read_index_reg__0\(0),
      O => read_index1_carry_i_8_n_0
    );
read_index1_carry_i_9: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => read_burst_len(2),
      I1 => read_burst_len(0),
      I2 => read_burst_len(1),
      I3 => read_burst_len(3),
      O => read_index1_carry_i_9_n_0
    );
\read_index[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \read_index_reg__0\(0),
      O => plusOp(0)
    );
\read_index[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \read_index_reg__0\(0),
      I1 => \read_index_reg__0\(1),
      O => plusOp(1)
    );
\read_index[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \read_index_reg__0\(0),
      I1 => \read_index_reg__0\(1),
      I2 => \read_index_reg__0\(2),
      O => plusOp(2)
    );
\read_index[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => \read_index_reg__0\(1),
      I1 => \read_index_reg__0\(0),
      I2 => \read_index_reg__0\(2),
      I3 => \read_index_reg__0\(3),
      O => plusOp(3)
    );
\read_index[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => \read_index_reg__0\(2),
      I1 => \read_index_reg__0\(0),
      I2 => \read_index_reg__0\(1),
      I3 => \read_index_reg__0\(3),
      I4 => \read_index_reg__0\(4),
      O => plusOp(4)
    );
\read_index[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => \read_index_reg__0\(3),
      I1 => \read_index_reg__0\(1),
      I2 => \read_index_reg__0\(0),
      I3 => \read_index_reg__0\(2),
      I4 => \read_index_reg__0\(4),
      I5 => \read_index_reg__0\(5),
      O => plusOp(5)
    );
\read_index[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \read_index[7]_i_4_n_0\,
      I1 => \read_index_reg__0\(6),
      O => plusOp(6)
    );
\read_index[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FD"
    )
        port map (
      I0 => m00_axi_aresetn,
      I1 => start_read,
      I2 => start_single_burst_read_reg_n_0,
      O => \read_index[7]_i_1_n_0\
    );
\read_index[7]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => read_index1,
      I1 => m00_axi_rvalid,
      I2 => \^m00_axi_rready\,
      O => read_index0
    );
\read_index[7]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \read_index[7]_i_4_n_0\,
      I1 => \read_index_reg__0\(6),
      I2 => \read_index_reg__0\(7),
      O => plusOp(7)
    );
\read_index[7]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000000000000000"
    )
        port map (
      I0 => \read_index_reg__0\(5),
      I1 => \read_index_reg__0\(3),
      I2 => \read_index_reg__0\(1),
      I3 => \read_index_reg__0\(0),
      I4 => \read_index_reg__0\(2),
      I5 => \read_index_reg__0\(4),
      O => \read_index[7]_i_4_n_0\
    );
\read_index_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(0),
      Q => \read_index_reg__0\(0),
      R => \read_index[7]_i_1_n_0\
    );
\read_index_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(1),
      Q => \read_index_reg__0\(1),
      R => \read_index[7]_i_1_n_0\
    );
\read_index_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(2),
      Q => \read_index_reg__0\(2),
      R => \read_index[7]_i_1_n_0\
    );
\read_index_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(3),
      Q => \read_index_reg__0\(3),
      R => \read_index[7]_i_1_n_0\
    );
\read_index_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(4),
      Q => \read_index_reg__0\(4),
      R => \read_index[7]_i_1_n_0\
    );
\read_index_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(5),
      Q => \read_index_reg__0\(5),
      R => \read_index[7]_i_1_n_0\
    );
\read_index_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(6),
      Q => \read_index_reg__0\(6),
      R => \read_index[7]_i_1_n_0\
    );
\read_index_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => read_index0,
      D => plusOp(7),
      Q => \read_index_reg__0\(7),
      R => \read_index[7]_i_1_n_0\
    );
reads_done_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF00000040"
    )
        port map (
      I0 => reads_done_i_2_n_0,
      I1 => read_burst_counter,
      I2 => p_19_in,
      I3 => reads_done_i_3_n_0,
      I4 => reads_done_i_4_n_0,
      I5 => reads_done,
      O => reads_done_i_1_n_0
    );
reads_done_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"6FF6F69F"
    )
        port map (
      I0 => \read_index_reg__0\(7),
      I1 => read_burst_len(7),
      I2 => \read_index_reg__0\(6),
      I3 => \^reads_done_reg_0\,
      I4 => read_burst_len(6),
      O => reads_done_i_2_n_0
    );
reads_done_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EFEFBFFBFEFEFBBF"
    )
        port map (
      I0 => reads_done_i_5_n_0,
      I1 => \read_index_reg__0\(0),
      I2 => \read_index_reg__0\(2),
      I3 => read_burst_len(1),
      I4 => read_burst_len(0),
      I5 => read_burst_len(2),
      O => reads_done_i_3_n_0
    );
reads_done_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"DFEFEFFDFDFEFEDF"
    )
        port map (
      I0 => \read_index_reg__0\(4),
      I1 => reads_done_i_6_n_0,
      I2 => \read_index_reg__0\(5),
      I3 => read_burst_len(4),
      I4 => read_index1_carry_i_9_n_0,
      I5 => read_burst_len(5),
      O => reads_done_i_4_n_0
    );
reads_done_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"5556AAA9"
    )
        port map (
      I0 => read_burst_len(3),
      I1 => read_burst_len(1),
      I2 => read_burst_len(0),
      I3 => read_burst_len(2),
      I4 => \read_index_reg__0\(3),
      O => reads_done_i_5_n_0
    );
reads_done_i_6: unisim.vcomponents.LUT3
    generic map(
      INIT => X"69"
    )
        port map (
      I0 => read_burst_len(1),
      I1 => read_burst_len(0),
      I2 => \read_index_reg__0\(1),
      O => reads_done_i_6_n_0
    );
reads_done_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => reads_done_i_1_n_0,
      Q => reads_done,
      R => axi_arvalid_i_1_n_0
    );
start_single_burst_read_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFF0FF00000100"
    )
        port map (
      I0 => \^m00_axi_arvalid\,
      I1 => burst_read_active,
      I2 => mst_exec_state(0),
      I3 => mst_exec_state(1),
      I4 => reads_done,
      I5 => start_single_burst_read_reg_n_0,
      O => start_single_burst_read_i_1_n_0
    );
start_single_burst_read_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => start_single_burst_read_i_1_n_0,
      Q => start_single_burst_read_reg_n_0,
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
start_single_burst_write_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFF0FF00000100"
    )
        port map (
      I0 => \^m00_axi_awvalid\,
      I1 => burst_write_active,
      I2 => mst_exec_state(1),
      I3 => mst_exec_state(0),
      I4 => writes_done,
      I5 => start_single_burst_write_reg_n_0,
      O => start_single_burst_write_i_1_n_0
    );
start_single_burst_write_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => start_single_burst_write_i_1_n_0,
      Q => start_single_burst_write_reg_n_0,
      R => \FSM_onehot_gnt_ps[2]_i_1_n_0\
    );
\write_burst_counter[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"F8"
    )
        port map (
      I0 => \^m00_axi_awvalid\,
      I1 => m00_axi_awready,
      I2 => write_burst_counter,
      O => \write_burst_counter[0]_i_1_n_0\
    );
\write_burst_counter_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => \write_burst_counter[0]_i_1_n_0\,
      Q => write_burst_counter,
      R => axi_awvalid_i_1_n_0
    );
\write_index[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \write_index_reg__0\(0),
      O => \plusOp__0\(0)
    );
\write_index[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \write_index_reg__0\(0),
      I1 => \write_index_reg__0\(1),
      O => \plusOp__0\(1)
    );
\write_index[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \write_index_reg__0\(0),
      I1 => \write_index_reg__0\(1),
      I2 => \write_index_reg__0\(2),
      O => \plusOp__0\(2)
    );
\write_index[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => \write_index_reg__0\(1),
      I1 => \write_index_reg__0\(0),
      I2 => \write_index_reg__0\(2),
      I3 => \write_index_reg__0\(3),
      O => \plusOp__0\(3)
    );
\write_index[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => \write_index_reg__0\(2),
      I1 => \write_index_reg__0\(0),
      I2 => \write_index_reg__0\(1),
      I3 => \write_index_reg__0\(3),
      I4 => \write_index_reg__0\(4),
      O => \plusOp__0\(4)
    );
\write_index[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => \write_index_reg__0\(3),
      I1 => \write_index_reg__0\(1),
      I2 => \write_index_reg__0\(0),
      I3 => \write_index_reg__0\(2),
      I4 => \write_index_reg__0\(4),
      I5 => \write_index_reg__0\(5),
      O => \plusOp__0\(5)
    );
\write_index[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \write_index[7]_i_8_n_0\,
      I1 => \write_index_reg__0\(6),
      O => \plusOp__0\(6)
    );
\write_index[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FD"
    )
        port map (
      I0 => m00_axi_aresetn,
      I1 => start_write,
      I2 => start_single_burst_write_reg_n_0,
      O => \write_index[7]_i_1_n_0\
    );
\write_index[7]_i_10\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => write_burst_len(2),
      I1 => write_burst_len(0),
      I2 => write_burst_len(1),
      I3 => write_burst_len(3),
      O => \write_index[7]_i_10_n_0\
    );
\write_index[7]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EFFFFFEF00000000"
    )
        port map (
      I0 => \write_index[7]_i_4_n_0\,
      I1 => \write_index[7]_i_5_n_0\,
      I2 => \write_index[7]_i_6_n_0\,
      I3 => \^m00_axi_awlen\(1),
      I4 => \write_index_reg__0\(6),
      I5 => p_30_in,
      O => write_index0
    );
\write_index[7]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \write_index[7]_i_8_n_0\,
      I1 => \write_index_reg__0\(6),
      I2 => \write_index_reg__0\(7),
      O => \plusOp__0\(7)
    );
\write_index[7]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6F6F6FF6F6F6F66F"
    )
        port map (
      I0 => \write_index_reg__0\(1),
      I1 => \^m00_axi_awlen\(0),
      I2 => \write_index_reg__0\(7),
      I3 => write_burst_len(6),
      I4 => \^write_index_reg[0]_0\,
      I5 => write_burst_len(7),
      O => \write_index[7]_i_4_n_0\
    );
\write_index[7]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"DFEFEFFDFDFEFEDF"
    )
        port map (
      I0 => \write_index_reg__0\(4),
      I1 => \write_index[7]_i_9_n_0\,
      I2 => \write_index_reg__0\(5),
      I3 => write_burst_len(4),
      I4 => \write_index[7]_i_10_n_0\,
      I5 => write_burst_len(5),
      O => \write_index[7]_i_5_n_0\
    );
\write_index[7]_i_6\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => write_burst_len(0),
      I1 => \write_index_reg__0\(0),
      O => \write_index[7]_i_6_n_0\
    );
\write_index[7]_i_7\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^m00_axi_wvalid\,
      I1 => m00_axi_wready,
      O => p_30_in
    );
\write_index[7]_i_8\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000000000000000"
    )
        port map (
      I0 => \write_index_reg__0\(5),
      I1 => \write_index_reg__0\(3),
      I2 => \write_index_reg__0\(1),
      I3 => \write_index_reg__0\(0),
      I4 => \write_index_reg__0\(2),
      I5 => \write_index_reg__0\(4),
      O => \write_index[7]_i_8_n_0\
    );
\write_index[7]_i_9\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6F6F6FF6F6F6F69F"
    )
        port map (
      I0 => \write_index_reg__0\(3),
      I1 => write_burst_len(3),
      I2 => \write_index_reg__0\(2),
      I3 => write_burst_len(1),
      I4 => write_burst_len(0),
      I5 => write_burst_len(2),
      O => \write_index[7]_i_9_n_0\
    );
\write_index_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(0),
      Q => \write_index_reg__0\(0),
      R => \write_index[7]_i_1_n_0\
    );
\write_index_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(1),
      Q => \write_index_reg__0\(1),
      R => \write_index[7]_i_1_n_0\
    );
\write_index_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(2),
      Q => \write_index_reg__0\(2),
      R => \write_index[7]_i_1_n_0\
    );
\write_index_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(3),
      Q => \write_index_reg__0\(3),
      R => \write_index[7]_i_1_n_0\
    );
\write_index_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(4),
      Q => \write_index_reg__0\(4),
      R => \write_index[7]_i_1_n_0\
    );
\write_index_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(5),
      Q => \write_index_reg__0\(5),
      R => \write_index[7]_i_1_n_0\
    );
\write_index_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(6),
      Q => \write_index_reg__0\(6),
      R => \write_index[7]_i_1_n_0\
    );
\write_index_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => write_index0,
      D => \plusOp__0\(7),
      Q => \write_index_reg__0\(7),
      R => \write_index[7]_i_1_n_0\
    );
writes_done_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FF80"
    )
        port map (
      I0 => write_burst_counter,
      I1 => \^m00_axi_bready\,
      I2 => m00_axi_bvalid,
      I3 => writes_done,
      O => writes_done_i_1_n_0
    );
writes_done_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axi_aclk,
      CE => '1',
      D => writes_done_i_1_n_0,
      Q => writes_done,
      R => axi_awvalid_i_1_n_0
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity axi4_master_vhdl_0_axi4_master_vhdl_v1_0 is
  port (
    master_axi_state : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_awvalid : out STD_LOGIC;
    m00_axi_rready : out STD_LOGIC;
    m00_axi_arvalid : out STD_LOGIC;
    m00_axi_wlast : out STD_LOGIC;
    m00_axi_wvalid : out STD_LOGIC;
    m00_axi_error : out STD_LOGIC;
    \master_axi_state[2]\ : out STD_LOGIC_VECTOR ( 2 downto 0 );
    fifo_rd_en : out STD_LOGIC;
    m00_axi_awlen : out STD_LOGIC_VECTOR ( 1 downto 0 );
    \write_index_reg[0]\ : out STD_LOGIC;
    reads_done_reg : out STD_LOGIC;
    m00_axi_bready : out STD_LOGIC;
    m00_axi_aclk : in STD_LOGIC;
    m00_axi_aresetn : in STD_LOGIC;
    start_write : in STD_LOGIC;
    start_read : in STD_LOGIC;
    m00_axi_rvalid : in STD_LOGIC;
    m00_axi_rlast : in STD_LOGIC;
    m00_axi_wready : in STD_LOGIC;
    write_burst_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    read_burst_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi_if_req : in STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_awready : in STD_LOGIC;
    m00_axi_arready : in STD_LOGIC;
    m00_axi_bvalid : in STD_LOGIC;
    m00_axi_rresp : in STD_LOGIC_VECTOR ( 0 to 0 );
    m00_axi_bresp : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of axi4_master_vhdl_0_axi4_master_vhdl_v1_0 : entity is "axi4_master_vhdl_v1_0";
end axi4_master_vhdl_0_axi4_master_vhdl_v1_0;

architecture STRUCTURE of axi4_master_vhdl_0_axi4_master_vhdl_v1_0 is
begin
axi4_master_vhdl_v1_0_M00_AXI_inst: entity work.axi4_master_vhdl_0_axi4_master_vhdl_v1_0_M00_AXI
     port map (
      axi_if_req(2 downto 0) => axi_if_req(2 downto 0),
      fifo_rd_en => fifo_rd_en,
      m00_axi_aclk => m00_axi_aclk,
      m00_axi_aresetn => m00_axi_aresetn,
      m00_axi_arready => m00_axi_arready,
      m00_axi_arvalid => m00_axi_arvalid,
      m00_axi_awlen(1 downto 0) => m00_axi_awlen(1 downto 0),
      m00_axi_awready => m00_axi_awready,
      m00_axi_awvalid => m00_axi_awvalid,
      m00_axi_bready => m00_axi_bready,
      m00_axi_bresp(0) => m00_axi_bresp(0),
      m00_axi_bvalid => m00_axi_bvalid,
      m00_axi_error => m00_axi_error,
      m00_axi_rlast => m00_axi_rlast,
      m00_axi_rready => m00_axi_rready,
      m00_axi_rresp(0) => m00_axi_rresp(0),
      m00_axi_rvalid => m00_axi_rvalid,
      m00_axi_wlast => m00_axi_wlast,
      m00_axi_wready => m00_axi_wready,
      m00_axi_wvalid => m00_axi_wvalid,
      \master_axi_state[2]\(2 downto 0) => \master_axi_state[2]\(2 downto 0),
      \out\(2) => master_axi_state(0),
      \out\(1) => master_axi_state(1),
      \out\(0) => master_axi_state(2),
      read_burst_len(7 downto 0) => read_burst_len(7 downto 0),
      reads_done_reg_0 => reads_done_reg,
      start_read => start_read,
      start_write => start_write,
      write_burst_len(7 downto 0) => write_burst_len(7 downto 0),
      \write_index_reg[0]_0\ => \write_index_reg[0]\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity axi4_master_vhdl_0 is
  port (
    start_write : in STD_LOGIC;
    start_read : in STD_LOGIC;
    write_burst_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    read_burst_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    fifo_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    fifo_wdata_valid : in STD_LOGIC;
    waddr_offset : in STD_LOGIC_VECTOR ( 29 downto 0 );
    raddr_offset : in STD_LOGIC_VECTOR ( 29 downto 0 );
    fifo_rd_en : out STD_LOGIC;
    master_axi_state : out STD_LOGIC_VECTOR ( 7 downto 0 );
    axi_if_req : in STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_awid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_awaddr : out STD_LOGIC_VECTOR ( 29 downto 0 );
    m00_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m00_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m00_axi_awlock : out STD_LOGIC;
    m00_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_awuser : out STD_LOGIC_VECTOR ( 0 to 0 );
    m00_axi_awvalid : out STD_LOGIC;
    m00_axi_awready : in STD_LOGIC;
    m00_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_wlast : out STD_LOGIC;
    m00_axi_wuser : out STD_LOGIC_VECTOR ( 0 to 0 );
    m00_axi_wvalid : out STD_LOGIC;
    m00_axi_wready : in STD_LOGIC;
    m00_axi_bid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m00_axi_buser : in STD_LOGIC_VECTOR ( 0 to 0 );
    m00_axi_bvalid : in STD_LOGIC;
    m00_axi_bready : out STD_LOGIC;
    m00_axi_arid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_araddr : out STD_LOGIC_VECTOR ( 29 downto 0 );
    m00_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m00_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m00_axi_arlock : out STD_LOGIC;
    m00_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_aruser : out STD_LOGIC_VECTOR ( 0 to 0 );
    m00_axi_arvalid : out STD_LOGIC;
    m00_axi_arready : in STD_LOGIC;
    m00_axi_rid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m00_axi_rlast : in STD_LOGIC;
    m00_axi_ruser : in STD_LOGIC_VECTOR ( 0 to 0 );
    m00_axi_rvalid : in STD_LOGIC;
    m00_axi_rready : out STD_LOGIC;
    m00_axi_aclk : in STD_LOGIC;
    m00_axi_aresetn : in STD_LOGIC;
    m00_axi_init_axi_txn : in STD_LOGIC;
    m00_axi_txn_done : out STD_LOGIC;
    m00_axi_error : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of axi4_master_vhdl_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of axi4_master_vhdl_0 : entity is "axi4_master_vhdl_0,axi4_master_vhdl_v1_0,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of axi4_master_vhdl_0 : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of axi4_master_vhdl_0 : entity is "axi4_master_vhdl_v1_0,Vivado 2018.2";
end axi4_master_vhdl_0;

architecture STRUCTURE of axi4_master_vhdl_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \<const1>\ : STD_LOGIC;
  signal U0_n_15 : STD_LOGIC;
  signal U0_n_16 : STD_LOGIC;
  signal \^fifo_axi_wdata\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^master_axi_state\ : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal \^raddr_offset\ : STD_LOGIC_VECTOR ( 29 downto 0 );
  signal \^waddr_offset\ : STD_LOGIC_VECTOR ( 29 downto 0 );
  attribute x_interface_info : string;
  attribute x_interface_info of m00_axi_aclk : signal is "xilinx.com:signal:clock:1.0 M00_AXI_CLK CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of m00_axi_aclk : signal is "XIL_INTERFACENAME M00_AXI_CLK, ASSOCIATED_BUSIF M00_AXI, ASSOCIATED_RESET m00_axi_aresetn, FREQ_HZ 100000000, PHASE 0.000";
  attribute x_interface_info of m00_axi_aresetn : signal is "xilinx.com:signal:reset:1.0 M00_AXI_RST RST";
  attribute x_interface_parameter of m00_axi_aresetn : signal is "XIL_INTERFACENAME M00_AXI_RST, POLARITY ACTIVE_LOW";
  attribute x_interface_info of m00_axi_arlock : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARLOCK";
  attribute x_interface_info of m00_axi_arready : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARREADY";
  attribute x_interface_info of m00_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARVALID";
  attribute x_interface_info of m00_axi_awlock : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWLOCK";
  attribute x_interface_info of m00_axi_awready : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWREADY";
  attribute x_interface_info of m00_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWVALID";
  attribute x_interface_info of m00_axi_bready : signal is "xilinx.com:interface:aximm:1.0 M00_AXI BREADY";
  attribute x_interface_info of m00_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI BVALID";
  attribute x_interface_info of m00_axi_rlast : signal is "xilinx.com:interface:aximm:1.0 M00_AXI RLAST";
  attribute x_interface_info of m00_axi_rready : signal is "xilinx.com:interface:aximm:1.0 M00_AXI RREADY";
  attribute x_interface_info of m00_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI RVALID";
  attribute x_interface_info of m00_axi_wlast : signal is "xilinx.com:interface:aximm:1.0 M00_AXI WLAST";
  attribute x_interface_info of m00_axi_wready : signal is "xilinx.com:interface:aximm:1.0 M00_AXI WREADY";
  attribute x_interface_info of m00_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI WVALID";
  attribute x_interface_info of m00_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARADDR";
  attribute x_interface_info of m00_axi_arburst : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARBURST";
  attribute x_interface_info of m00_axi_arcache : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARCACHE";
  attribute x_interface_info of m00_axi_arid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARID";
  attribute x_interface_info of m00_axi_arlen : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARLEN";
  attribute x_interface_info of m00_axi_arprot : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARPROT";
  attribute x_interface_info of m00_axi_arqos : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARQOS";
  attribute x_interface_info of m00_axi_arsize : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARSIZE";
  attribute x_interface_info of m00_axi_aruser : signal is "xilinx.com:interface:aximm:1.0 M00_AXI ARUSER";
  attribute x_interface_info of m00_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWADDR";
  attribute x_interface_info of m00_axi_awburst : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWBURST";
  attribute x_interface_info of m00_axi_awcache : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWCACHE";
  attribute x_interface_info of m00_axi_awid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWID";
  attribute x_interface_parameter of m00_axi_awid : signal is "XIL_INTERFACENAME M00_AXI, WIZ_DATA_WIDTH 32, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 4, ADDR_WIDTH 30, AWUSER_WIDTH 1, ARUSER_WIDTH 1, WUSER_WIDTH 1, RUSER_WIDTH 1, BUSER_WIDTH 1, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0";
  attribute x_interface_info of m00_axi_awlen : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWLEN";
  attribute x_interface_info of m00_axi_awprot : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWPROT";
  attribute x_interface_info of m00_axi_awqos : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWQOS";
  attribute x_interface_info of m00_axi_awsize : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWSIZE";
  attribute x_interface_info of m00_axi_awuser : signal is "xilinx.com:interface:aximm:1.0 M00_AXI AWUSER";
  attribute x_interface_info of m00_axi_bid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI BID";
  attribute x_interface_info of m00_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 M00_AXI BRESP";
  attribute x_interface_info of m00_axi_buser : signal is "xilinx.com:interface:aximm:1.0 M00_AXI BUSER";
  attribute x_interface_info of m00_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 M00_AXI RDATA";
  attribute x_interface_info of m00_axi_rid : signal is "xilinx.com:interface:aximm:1.0 M00_AXI RID";
  attribute x_interface_info of m00_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 M00_AXI RRESP";
  attribute x_interface_info of m00_axi_ruser : signal is "xilinx.com:interface:aximm:1.0 M00_AXI RUSER";
  attribute x_interface_info of m00_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 M00_AXI WDATA";
  attribute x_interface_info of m00_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 M00_AXI WSTRB";
  attribute x_interface_info of m00_axi_wuser : signal is "xilinx.com:interface:aximm:1.0 M00_AXI WUSER";
begin
  \^fifo_axi_wdata\(31 downto 0) <= fifo_axi_wdata(31 downto 0);
  \^raddr_offset\(29 downto 0) <= raddr_offset(29 downto 0);
  \^waddr_offset\(29 downto 0) <= waddr_offset(29 downto 0);
  m00_axi_araddr(29 downto 0) <= \^raddr_offset\(29 downto 0);
  m00_axi_arburst(1) <= \<const0>\;
  m00_axi_arburst(0) <= \<const1>\;
  m00_axi_arcache(3) <= \<const0>\;
  m00_axi_arcache(2) <= \<const0>\;
  m00_axi_arcache(1) <= \<const0>\;
  m00_axi_arcache(0) <= \<const0>\;
  m00_axi_arid(3) <= \<const0>\;
  m00_axi_arid(2) <= \<const0>\;
  m00_axi_arid(1) <= \<const0>\;
  m00_axi_arid(0) <= \<const0>\;
  m00_axi_arlock <= \<const0>\;
  m00_axi_arprot(2) <= \<const0>\;
  m00_axi_arprot(1) <= \<const0>\;
  m00_axi_arprot(0) <= \<const0>\;
  m00_axi_arqos(3) <= \<const0>\;
  m00_axi_arqos(2) <= \<const0>\;
  m00_axi_arqos(1) <= \<const0>\;
  m00_axi_arqos(0) <= \<const0>\;
  m00_axi_arsize(2) <= \<const0>\;
  m00_axi_arsize(1) <= \<const1>\;
  m00_axi_arsize(0) <= \<const0>\;
  m00_axi_aruser(0) <= \<const1>\;
  m00_axi_awaddr(29 downto 0) <= \^waddr_offset\(29 downto 0);
  m00_axi_awburst(1) <= \<const0>\;
  m00_axi_awburst(0) <= \<const1>\;
  m00_axi_awcache(3) <= \<const0>\;
  m00_axi_awcache(2) <= \<const0>\;
  m00_axi_awcache(1) <= \<const0>\;
  m00_axi_awcache(0) <= \<const0>\;
  m00_axi_awid(3) <= \<const0>\;
  m00_axi_awid(2) <= \<const0>\;
  m00_axi_awid(1) <= \<const0>\;
  m00_axi_awid(0) <= \<const0>\;
  m00_axi_awlock <= \<const0>\;
  m00_axi_awprot(2) <= \<const0>\;
  m00_axi_awprot(1) <= \<const0>\;
  m00_axi_awprot(0) <= \<const0>\;
  m00_axi_awqos(3) <= \<const0>\;
  m00_axi_awqos(2) <= \<const0>\;
  m00_axi_awqos(1) <= \<const0>\;
  m00_axi_awqos(0) <= \<const0>\;
  m00_axi_awsize(2) <= \<const0>\;
  m00_axi_awsize(1) <= \<const1>\;
  m00_axi_awsize(0) <= \<const0>\;
  m00_axi_awuser(0) <= \<const0>\;
  m00_axi_txn_done <= \<const0>\;
  m00_axi_wdata(31 downto 0) <= \^fifo_axi_wdata\(31 downto 0);
  m00_axi_wstrb(3) <= \<const1>\;
  m00_axi_wstrb(2) <= \<const1>\;
  m00_axi_wstrb(1) <= \<const1>\;
  m00_axi_wstrb(0) <= \<const1>\;
  m00_axi_wuser(0) <= \<const0>\;
  master_axi_state(7) <= \<const0>\;
  master_axi_state(6 downto 4) <= \^master_axi_state\(6 downto 4);
  master_axi_state(3) <= \<const0>\;
  master_axi_state(2 downto 0) <= \^master_axi_state\(2 downto 0);
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
U0: entity work.axi4_master_vhdl_0_axi4_master_vhdl_v1_0
     port map (
      axi_if_req(2 downto 0) => axi_if_req(2 downto 0),
      fifo_rd_en => fifo_rd_en,
      m00_axi_aclk => m00_axi_aclk,
      m00_axi_aresetn => m00_axi_aresetn,
      m00_axi_arready => m00_axi_arready,
      m00_axi_arvalid => m00_axi_arvalid,
      m00_axi_awlen(1) => m00_axi_awlen(6),
      m00_axi_awlen(0) => m00_axi_awlen(1),
      m00_axi_awready => m00_axi_awready,
      m00_axi_awvalid => m00_axi_awvalid,
      m00_axi_bready => m00_axi_bready,
      m00_axi_bresp(0) => m00_axi_bresp(1),
      m00_axi_bvalid => m00_axi_bvalid,
      m00_axi_error => m00_axi_error,
      m00_axi_rlast => m00_axi_rlast,
      m00_axi_rready => m00_axi_rready,
      m00_axi_rresp(0) => m00_axi_rresp(1),
      m00_axi_rvalid => m00_axi_rvalid,
      m00_axi_wlast => m00_axi_wlast,
      m00_axi_wready => m00_axi_wready,
      m00_axi_wvalid => m00_axi_wvalid,
      master_axi_state(2 downto 0) => \^master_axi_state\(6 downto 4),
      \master_axi_state[2]\(2 downto 0) => \^master_axi_state\(2 downto 0),
      read_burst_len(7 downto 0) => read_burst_len(7 downto 0),
      reads_done_reg => U0_n_16,
      start_read => start_read,
      start_write => start_write,
      write_burst_len(7 downto 0) => write_burst_len(7 downto 0),
      \write_index_reg[0]\ => U0_n_15
    );
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
\m00_axi_arlen[0]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => read_burst_len(0),
      O => m00_axi_arlen(0)
    );
\m00_axi_arlen[1]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => read_burst_len(0),
      I1 => read_burst_len(1),
      O => m00_axi_arlen(1)
    );
\m00_axi_arlen[2]_INST_0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E1"
    )
        port map (
      I0 => read_burst_len(1),
      I1 => read_burst_len(0),
      I2 => read_burst_len(2),
      O => m00_axi_arlen(2)
    );
\m00_axi_arlen[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FE01"
    )
        port map (
      I0 => read_burst_len(2),
      I1 => read_burst_len(0),
      I2 => read_burst_len(1),
      I3 => read_burst_len(3),
      O => m00_axi_arlen(3)
    );
\m00_axi_arlen[4]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFE0001"
    )
        port map (
      I0 => read_burst_len(3),
      I1 => read_burst_len(1),
      I2 => read_burst_len(0),
      I3 => read_burst_len(2),
      I4 => read_burst_len(4),
      O => m00_axi_arlen(4)
    );
\m00_axi_arlen[5]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFE00000001"
    )
        port map (
      I0 => read_burst_len(4),
      I1 => read_burst_len(2),
      I2 => read_burst_len(0),
      I3 => read_burst_len(1),
      I4 => read_burst_len(3),
      I5 => read_burst_len(5),
      O => m00_axi_arlen(5)
    );
\m00_axi_arlen[6]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => U0_n_16,
      I1 => read_burst_len(6),
      O => m00_axi_arlen(6)
    );
\m00_axi_arlen[7]_INST_0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E1"
    )
        port map (
      I0 => read_burst_len(6),
      I1 => U0_n_16,
      I2 => read_burst_len(7),
      O => m00_axi_arlen(7)
    );
\m00_axi_awlen[0]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => write_burst_len(0),
      O => m00_axi_awlen(0)
    );
\m00_axi_awlen[2]_INST_0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E1"
    )
        port map (
      I0 => write_burst_len(1),
      I1 => write_burst_len(0),
      I2 => write_burst_len(2),
      O => m00_axi_awlen(2)
    );
\m00_axi_awlen[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FE01"
    )
        port map (
      I0 => write_burst_len(2),
      I1 => write_burst_len(0),
      I2 => write_burst_len(1),
      I3 => write_burst_len(3),
      O => m00_axi_awlen(3)
    );
\m00_axi_awlen[4]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFE0001"
    )
        port map (
      I0 => write_burst_len(3),
      I1 => write_burst_len(1),
      I2 => write_burst_len(0),
      I3 => write_burst_len(2),
      I4 => write_burst_len(4),
      O => m00_axi_awlen(4)
    );
\m00_axi_awlen[5]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFE00000001"
    )
        port map (
      I0 => write_burst_len(4),
      I1 => write_burst_len(2),
      I2 => write_burst_len(0),
      I3 => write_burst_len(1),
      I4 => write_burst_len(3),
      I5 => write_burst_len(5),
      O => m00_axi_awlen(5)
    );
\m00_axi_awlen[7]_INST_0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E1"
    )
        port map (
      I0 => write_burst_len(6),
      I1 => U0_n_15,
      I2 => write_burst_len(7),
      O => m00_axi_awlen(7)
    );
end STRUCTURE;
