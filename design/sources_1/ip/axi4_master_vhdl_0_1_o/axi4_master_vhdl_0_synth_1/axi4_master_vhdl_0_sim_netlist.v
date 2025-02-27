// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Tue Sep 13 16:40:45 2022
// Host        : YY529462 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/PR/Vivado/Spartan7_tmc/Spartan7_tmc.runs/axi4_master_vhdl_0_synth_1/axi4_master_vhdl_0_sim_netlist.v
// Design      : axi4_master_vhdl_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s75fgga484-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "axi4_master_vhdl_0,axi4_master_vhdl_v1_0,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "axi4_master_vhdl_v1_0,Vivado 2018.2" *) 
(* NotValidForBitStream *)
module axi4_master_vhdl_0
   (start_write,
    start_read,
    write_burst_len,
    read_burst_len,
    fifo_axi_wdata,
    fifo_wdata_valid,
    waddr_offset,
    raddr_offset,
    fifo_rd_en,
    master_axi_state,
    axi_if_req,
    m00_axi_awid,
    m00_axi_awaddr,
    m00_axi_awlen,
    m00_axi_awsize,
    m00_axi_awburst,
    m00_axi_awlock,
    m00_axi_awcache,
    m00_axi_awprot,
    m00_axi_awqos,
    m00_axi_awuser,
    m00_axi_awvalid,
    m00_axi_awready,
    m00_axi_wdata,
    m00_axi_wstrb,
    m00_axi_wlast,
    m00_axi_wuser,
    m00_axi_wvalid,
    m00_axi_wready,
    m00_axi_bid,
    m00_axi_bresp,
    m00_axi_buser,
    m00_axi_bvalid,
    m00_axi_bready,
    m00_axi_arid,
    m00_axi_araddr,
    m00_axi_arlen,
    m00_axi_arsize,
    m00_axi_arburst,
    m00_axi_arlock,
    m00_axi_arcache,
    m00_axi_arprot,
    m00_axi_arqos,
    m00_axi_aruser,
    m00_axi_arvalid,
    m00_axi_arready,
    m00_axi_rid,
    m00_axi_rdata,
    m00_axi_rresp,
    m00_axi_rlast,
    m00_axi_ruser,
    m00_axi_rvalid,
    m00_axi_rready,
    m00_axi_aclk,
    m00_axi_aresetn,
    m00_axi_init_axi_txn,
    m00_axi_txn_done,
    m00_axi_error);
  input start_write;
  input start_read;
  input [7:0]write_burst_len;
  input [7:0]read_burst_len;
  input [31:0]fifo_axi_wdata;
  input fifo_wdata_valid;
  input [29:0]waddr_offset;
  input [29:0]raddr_offset;
  output fifo_rd_en;
  output [7:0]master_axi_state;
  input [2:0]axi_if_req;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWID" *) (* x_interface_parameter = "XIL_INTERFACENAME M00_AXI, WIZ_DATA_WIDTH 32, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 4, ADDR_WIDTH 30, AWUSER_WIDTH 1, ARUSER_WIDTH 1, WUSER_WIDTH 1, RUSER_WIDTH 1, BUSER_WIDTH 1, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *) output [3:0]m00_axi_awid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWADDR" *) output [29:0]m00_axi_awaddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWLEN" *) output [7:0]m00_axi_awlen;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWSIZE" *) output [2:0]m00_axi_awsize;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWBURST" *) output [1:0]m00_axi_awburst;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWLOCK" *) output m00_axi_awlock;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWCACHE" *) output [3:0]m00_axi_awcache;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWPROT" *) output [2:0]m00_axi_awprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWQOS" *) output [3:0]m00_axi_awqos;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWUSER" *) output [0:0]m00_axi_awuser;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWVALID" *) output m00_axi_awvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI AWREADY" *) input m00_axi_awready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI WDATA" *) output [31:0]m00_axi_wdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI WSTRB" *) output [3:0]m00_axi_wstrb;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI WLAST" *) output m00_axi_wlast;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI WUSER" *) output [0:0]m00_axi_wuser;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI WVALID" *) output m00_axi_wvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI WREADY" *) input m00_axi_wready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI BID" *) input [3:0]m00_axi_bid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI BRESP" *) input [1:0]m00_axi_bresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI BUSER" *) input [0:0]m00_axi_buser;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI BVALID" *) input m00_axi_bvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI BREADY" *) output m00_axi_bready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARID" *) output [3:0]m00_axi_arid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARADDR" *) output [29:0]m00_axi_araddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARLEN" *) output [7:0]m00_axi_arlen;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARSIZE" *) output [2:0]m00_axi_arsize;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARBURST" *) output [1:0]m00_axi_arburst;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARLOCK" *) output m00_axi_arlock;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARCACHE" *) output [3:0]m00_axi_arcache;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARPROT" *) output [2:0]m00_axi_arprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARQOS" *) output [3:0]m00_axi_arqos;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARUSER" *) output [0:0]m00_axi_aruser;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARVALID" *) output m00_axi_arvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI ARREADY" *) input m00_axi_arready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI RID" *) input [3:0]m00_axi_rid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI RDATA" *) input [31:0]m00_axi_rdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI RRESP" *) input [1:0]m00_axi_rresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI RLAST" *) input m00_axi_rlast;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI RUSER" *) input [0:0]m00_axi_ruser;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI RVALID" *) input m00_axi_rvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M00_AXI RREADY" *) output m00_axi_rready;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 M00_AXI_CLK CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME M00_AXI_CLK, ASSOCIATED_BUSIF M00_AXI, ASSOCIATED_RESET m00_axi_aresetn, FREQ_HZ 100000000, PHASE 0.000" *) input m00_axi_aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 M00_AXI_RST RST" *) (* x_interface_parameter = "XIL_INTERFACENAME M00_AXI_RST, POLARITY ACTIVE_LOW" *) input m00_axi_aresetn;
  input m00_axi_init_axi_txn;
  output m00_axi_txn_done;
  output m00_axi_error;

  wire \<const0> ;
  wire \<const1> ;
  wire U0_n_15;
  wire U0_n_16;
  wire [2:0]axi_if_req;
  wire [31:0]fifo_axi_wdata;
  wire fifo_rd_en;
  wire m00_axi_aclk;
  wire m00_axi_aresetn;
  wire [7:0]m00_axi_arlen;
  wire m00_axi_arready;
  wire m00_axi_arvalid;
  wire [7:0]m00_axi_awlen;
  wire m00_axi_awready;
  wire m00_axi_awvalid;
  wire m00_axi_bready;
  wire [1:0]m00_axi_bresp;
  wire m00_axi_bvalid;
  wire m00_axi_error;
  wire m00_axi_rlast;
  wire m00_axi_rready;
  wire [1:0]m00_axi_rresp;
  wire m00_axi_rvalid;
  wire m00_axi_wlast;
  wire m00_axi_wready;
  wire m00_axi_wvalid;
  wire [6:0]\^master_axi_state ;
  wire [29:0]raddr_offset;
  wire [7:0]read_burst_len;
  wire start_read;
  wire start_write;
  wire [29:0]waddr_offset;
  wire [7:0]write_burst_len;

  assign m00_axi_araddr[29:0] = raddr_offset;
  assign m00_axi_arburst[1] = \<const0> ;
  assign m00_axi_arburst[0] = \<const1> ;
  assign m00_axi_arcache[3] = \<const0> ;
  assign m00_axi_arcache[2] = \<const0> ;
  assign m00_axi_arcache[1] = \<const0> ;
  assign m00_axi_arcache[0] = \<const0> ;
  assign m00_axi_arid[3] = \<const0> ;
  assign m00_axi_arid[2] = \<const0> ;
  assign m00_axi_arid[1] = \<const0> ;
  assign m00_axi_arid[0] = \<const0> ;
  assign m00_axi_arlock = \<const0> ;
  assign m00_axi_arprot[2] = \<const0> ;
  assign m00_axi_arprot[1] = \<const0> ;
  assign m00_axi_arprot[0] = \<const0> ;
  assign m00_axi_arqos[3] = \<const0> ;
  assign m00_axi_arqos[2] = \<const0> ;
  assign m00_axi_arqos[1] = \<const0> ;
  assign m00_axi_arqos[0] = \<const0> ;
  assign m00_axi_arsize[2] = \<const0> ;
  assign m00_axi_arsize[1] = \<const1> ;
  assign m00_axi_arsize[0] = \<const0> ;
  assign m00_axi_aruser[0] = \<const1> ;
  assign m00_axi_awaddr[29:0] = waddr_offset;
  assign m00_axi_awburst[1] = \<const0> ;
  assign m00_axi_awburst[0] = \<const1> ;
  assign m00_axi_awcache[3] = \<const0> ;
  assign m00_axi_awcache[2] = \<const0> ;
  assign m00_axi_awcache[1] = \<const0> ;
  assign m00_axi_awcache[0] = \<const0> ;
  assign m00_axi_awid[3] = \<const0> ;
  assign m00_axi_awid[2] = \<const0> ;
  assign m00_axi_awid[1] = \<const0> ;
  assign m00_axi_awid[0] = \<const0> ;
  assign m00_axi_awlock = \<const0> ;
  assign m00_axi_awprot[2] = \<const0> ;
  assign m00_axi_awprot[1] = \<const0> ;
  assign m00_axi_awprot[0] = \<const0> ;
  assign m00_axi_awqos[3] = \<const0> ;
  assign m00_axi_awqos[2] = \<const0> ;
  assign m00_axi_awqos[1] = \<const0> ;
  assign m00_axi_awqos[0] = \<const0> ;
  assign m00_axi_awsize[2] = \<const0> ;
  assign m00_axi_awsize[1] = \<const1> ;
  assign m00_axi_awsize[0] = \<const0> ;
  assign m00_axi_awuser[0] = \<const0> ;
  assign m00_axi_txn_done = \<const0> ;
  assign m00_axi_wdata[31:0] = fifo_axi_wdata;
  assign m00_axi_wstrb[3] = \<const1> ;
  assign m00_axi_wstrb[2] = \<const1> ;
  assign m00_axi_wstrb[1] = \<const1> ;
  assign m00_axi_wstrb[0] = \<const1> ;
  assign m00_axi_wuser[0] = \<const0> ;
  assign master_axi_state[7] = \<const0> ;
  assign master_axi_state[6:4] = \^master_axi_state [6:4];
  assign master_axi_state[3] = \<const0> ;
  assign master_axi_state[2:0] = \^master_axi_state [2:0];
  GND GND
       (.G(\<const0> ));
  axi4_master_vhdl_0_axi4_master_vhdl_v1_0 U0
       (.axi_if_req(axi_if_req),
        .fifo_rd_en(fifo_rd_en),
        .m00_axi_aclk(m00_axi_aclk),
        .m00_axi_aresetn(m00_axi_aresetn),
        .m00_axi_arready(m00_axi_arready),
        .m00_axi_arvalid(m00_axi_arvalid),
        .m00_axi_awlen({m00_axi_awlen[6],m00_axi_awlen[1]}),
        .m00_axi_awready(m00_axi_awready),
        .m00_axi_awvalid(m00_axi_awvalid),
        .m00_axi_bready(m00_axi_bready),
        .m00_axi_bresp(m00_axi_bresp[1]),
        .m00_axi_bvalid(m00_axi_bvalid),
        .m00_axi_error(m00_axi_error),
        .m00_axi_rlast(m00_axi_rlast),
        .m00_axi_rready(m00_axi_rready),
        .m00_axi_rresp(m00_axi_rresp[1]),
        .m00_axi_rvalid(m00_axi_rvalid),
        .m00_axi_wlast(m00_axi_wlast),
        .m00_axi_wready(m00_axi_wready),
        .m00_axi_wvalid(m00_axi_wvalid),
        .master_axi_state(\^master_axi_state [6:4]),
        .\master_axi_state[2] (\^master_axi_state [2:0]),
        .read_burst_len(read_burst_len),
        .reads_done_reg(U0_n_16),
        .start_read(start_read),
        .start_write(start_write),
        .write_burst_len(write_burst_len),
        .\write_index_reg[0] (U0_n_15));
  VCC VCC
       (.P(\<const1> ));
  LUT1 #(
    .INIT(2'h1)) 
    \m00_axi_arlen[0]_INST_0 
       (.I0(read_burst_len[0]),
        .O(m00_axi_arlen[0]));
  LUT2 #(
    .INIT(4'h9)) 
    \m00_axi_arlen[1]_INST_0 
       (.I0(read_burst_len[0]),
        .I1(read_burst_len[1]),
        .O(m00_axi_arlen[1]));
  LUT3 #(
    .INIT(8'hE1)) 
    \m00_axi_arlen[2]_INST_0 
       (.I0(read_burst_len[1]),
        .I1(read_burst_len[0]),
        .I2(read_burst_len[2]),
        .O(m00_axi_arlen[2]));
  LUT4 #(
    .INIT(16'hFE01)) 
    \m00_axi_arlen[3]_INST_0 
       (.I0(read_burst_len[2]),
        .I1(read_burst_len[0]),
        .I2(read_burst_len[1]),
        .I3(read_burst_len[3]),
        .O(m00_axi_arlen[3]));
  LUT5 #(
    .INIT(32'hFFFE0001)) 
    \m00_axi_arlen[4]_INST_0 
       (.I0(read_burst_len[3]),
        .I1(read_burst_len[1]),
        .I2(read_burst_len[0]),
        .I3(read_burst_len[2]),
        .I4(read_burst_len[4]),
        .O(m00_axi_arlen[4]));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000001)) 
    \m00_axi_arlen[5]_INST_0 
       (.I0(read_burst_len[4]),
        .I1(read_burst_len[2]),
        .I2(read_burst_len[0]),
        .I3(read_burst_len[1]),
        .I4(read_burst_len[3]),
        .I5(read_burst_len[5]),
        .O(m00_axi_arlen[5]));
  LUT2 #(
    .INIT(4'h9)) 
    \m00_axi_arlen[6]_INST_0 
       (.I0(U0_n_16),
        .I1(read_burst_len[6]),
        .O(m00_axi_arlen[6]));
  LUT3 #(
    .INIT(8'hE1)) 
    \m00_axi_arlen[7]_INST_0 
       (.I0(read_burst_len[6]),
        .I1(U0_n_16),
        .I2(read_burst_len[7]),
        .O(m00_axi_arlen[7]));
  LUT1 #(
    .INIT(2'h1)) 
    \m00_axi_awlen[0]_INST_0 
       (.I0(write_burst_len[0]),
        .O(m00_axi_awlen[0]));
  LUT3 #(
    .INIT(8'hE1)) 
    \m00_axi_awlen[2]_INST_0 
       (.I0(write_burst_len[1]),
        .I1(write_burst_len[0]),
        .I2(write_burst_len[2]),
        .O(m00_axi_awlen[2]));
  LUT4 #(
    .INIT(16'hFE01)) 
    \m00_axi_awlen[3]_INST_0 
       (.I0(write_burst_len[2]),
        .I1(write_burst_len[0]),
        .I2(write_burst_len[1]),
        .I3(write_burst_len[3]),
        .O(m00_axi_awlen[3]));
  LUT5 #(
    .INIT(32'hFFFE0001)) 
    \m00_axi_awlen[4]_INST_0 
       (.I0(write_burst_len[3]),
        .I1(write_burst_len[1]),
        .I2(write_burst_len[0]),
        .I3(write_burst_len[2]),
        .I4(write_burst_len[4]),
        .O(m00_axi_awlen[4]));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000001)) 
    \m00_axi_awlen[5]_INST_0 
       (.I0(write_burst_len[4]),
        .I1(write_burst_len[2]),
        .I2(write_burst_len[0]),
        .I3(write_burst_len[1]),
        .I4(write_burst_len[3]),
        .I5(write_burst_len[5]),
        .O(m00_axi_awlen[5]));
  LUT3 #(
    .INIT(8'hE1)) 
    \m00_axi_awlen[7]_INST_0 
       (.I0(write_burst_len[6]),
        .I1(U0_n_15),
        .I2(write_burst_len[7]),
        .O(m00_axi_awlen[7]));
endmodule

(* ORIG_REF_NAME = "axi4_master_vhdl_v1_0" *) 
module axi4_master_vhdl_0_axi4_master_vhdl_v1_0
   (master_axi_state,
    m00_axi_awvalid,
    m00_axi_rready,
    m00_axi_arvalid,
    m00_axi_wlast,
    m00_axi_wvalid,
    m00_axi_error,
    \master_axi_state[2] ,
    fifo_rd_en,
    m00_axi_awlen,
    \write_index_reg[0] ,
    reads_done_reg,
    m00_axi_bready,
    m00_axi_aclk,
    m00_axi_aresetn,
    start_write,
    start_read,
    m00_axi_rvalid,
    m00_axi_rlast,
    m00_axi_wready,
    write_burst_len,
    read_burst_len,
    axi_if_req,
    m00_axi_awready,
    m00_axi_arready,
    m00_axi_bvalid,
    m00_axi_rresp,
    m00_axi_bresp);
  output [2:0]master_axi_state;
  output m00_axi_awvalid;
  output m00_axi_rready;
  output m00_axi_arvalid;
  output m00_axi_wlast;
  output m00_axi_wvalid;
  output m00_axi_error;
  output [2:0]\master_axi_state[2] ;
  output fifo_rd_en;
  output [1:0]m00_axi_awlen;
  output \write_index_reg[0] ;
  output reads_done_reg;
  output m00_axi_bready;
  input m00_axi_aclk;
  input m00_axi_aresetn;
  input start_write;
  input start_read;
  input m00_axi_rvalid;
  input m00_axi_rlast;
  input m00_axi_wready;
  input [7:0]write_burst_len;
  input [7:0]read_burst_len;
  input [2:0]axi_if_req;
  input m00_axi_awready;
  input m00_axi_arready;
  input m00_axi_bvalid;
  input [0:0]m00_axi_rresp;
  input [0:0]m00_axi_bresp;

  wire [2:0]axi_if_req;
  wire fifo_rd_en;
  wire m00_axi_aclk;
  wire m00_axi_aresetn;
  wire m00_axi_arready;
  wire m00_axi_arvalid;
  wire [1:0]m00_axi_awlen;
  wire m00_axi_awready;
  wire m00_axi_awvalid;
  wire m00_axi_bready;
  wire [0:0]m00_axi_bresp;
  wire m00_axi_bvalid;
  wire m00_axi_error;
  wire m00_axi_rlast;
  wire m00_axi_rready;
  wire [0:0]m00_axi_rresp;
  wire m00_axi_rvalid;
  wire m00_axi_wlast;
  wire m00_axi_wready;
  wire m00_axi_wvalid;
  wire [2:0]master_axi_state;
  wire [2:0]\master_axi_state[2] ;
  wire [7:0]read_burst_len;
  wire reads_done_reg;
  wire start_read;
  wire start_write;
  wire [7:0]write_burst_len;
  wire \write_index_reg[0] ;

  axi4_master_vhdl_0_axi4_master_vhdl_v1_0_M00_AXI axi4_master_vhdl_v1_0_M00_AXI_inst
       (.axi_if_req(axi_if_req),
        .fifo_rd_en(fifo_rd_en),
        .m00_axi_aclk(m00_axi_aclk),
        .m00_axi_aresetn(m00_axi_aresetn),
        .m00_axi_arready(m00_axi_arready),
        .m00_axi_arvalid(m00_axi_arvalid),
        .m00_axi_awlen(m00_axi_awlen),
        .m00_axi_awready(m00_axi_awready),
        .m00_axi_awvalid(m00_axi_awvalid),
        .m00_axi_bready(m00_axi_bready),
        .m00_axi_bresp(m00_axi_bresp),
        .m00_axi_bvalid(m00_axi_bvalid),
        .m00_axi_error(m00_axi_error),
        .m00_axi_rlast(m00_axi_rlast),
        .m00_axi_rready(m00_axi_rready),
        .m00_axi_rresp(m00_axi_rresp),
        .m00_axi_rvalid(m00_axi_rvalid),
        .m00_axi_wlast(m00_axi_wlast),
        .m00_axi_wready(m00_axi_wready),
        .m00_axi_wvalid(m00_axi_wvalid),
        .\master_axi_state[2] (\master_axi_state[2] ),
        .out({master_axi_state[0],master_axi_state[1],master_axi_state[2]}),
        .read_burst_len(read_burst_len),
        .reads_done_reg_0(reads_done_reg),
        .start_read(start_read),
        .start_write(start_write),
        .write_burst_len(write_burst_len),
        .\write_index_reg[0]_0 (\write_index_reg[0] ));
endmodule

(* ORIG_REF_NAME = "axi4_master_vhdl_v1_0_M00_AXI" *) 
module axi4_master_vhdl_0_axi4_master_vhdl_v1_0_M00_AXI
   (out,
    m00_axi_awvalid,
    m00_axi_rready,
    m00_axi_arvalid,
    m00_axi_wlast,
    m00_axi_wvalid,
    m00_axi_error,
    \master_axi_state[2] ,
    fifo_rd_en,
    m00_axi_awlen,
    \write_index_reg[0]_0 ,
    reads_done_reg_0,
    m00_axi_bready,
    m00_axi_aclk,
    m00_axi_aresetn,
    start_write,
    start_read,
    m00_axi_rvalid,
    m00_axi_rlast,
    m00_axi_wready,
    write_burst_len,
    read_burst_len,
    axi_if_req,
    m00_axi_awready,
    m00_axi_arready,
    m00_axi_bvalid,
    m00_axi_rresp,
    m00_axi_bresp);
  output [2:0]out;
  output m00_axi_awvalid;
  output m00_axi_rready;
  output m00_axi_arvalid;
  output m00_axi_wlast;
  output m00_axi_wvalid;
  output m00_axi_error;
  output [2:0]\master_axi_state[2] ;
  output fifo_rd_en;
  output [1:0]m00_axi_awlen;
  output \write_index_reg[0]_0 ;
  output reads_done_reg_0;
  output m00_axi_bready;
  input m00_axi_aclk;
  input m00_axi_aresetn;
  input start_write;
  input start_read;
  input m00_axi_rvalid;
  input m00_axi_rlast;
  input m00_axi_wready;
  input [7:0]write_burst_len;
  input [7:0]read_burst_len;
  input [2:0]axi_if_req;
  input m00_axi_awready;
  input m00_axi_arready;
  input m00_axi_bvalid;
  input [0:0]m00_axi_rresp;
  input [0:0]m00_axi_bresp;

  wire \FSM_onehot_gnt_ps[0]_i_1_n_0 ;
  wire \FSM_onehot_gnt_ps[1]_i_1_n_0 ;
  wire \FSM_onehot_gnt_ps[2]_i_1_n_0 ;
  wire \FSM_onehot_gnt_ps[2]_i_2_n_0 ;
  wire \FSM_onehot_gnt_ps[2]_i_5_n_0 ;
  wire \FSM_onehot_gnt_ps[2]_i_6_n_0 ;
  wire \FSM_onehot_gnt_ps[2]_i_7_n_0 ;
  wire \FSM_sequential_mst_exec_state[0]_i_1_n_0 ;
  wire \FSM_sequential_mst_exec_state[1]_i_1_n_0 ;
  wire axi_arvalid_i_1_n_0;
  wire axi_arvalid_i_2_n_0;
  wire axi_awvalid_i_1_n_0;
  wire axi_awvalid_i_2_n_0;
  wire axi_bready_i_1_n_0;
  wire [2:0]axi_if_req;
  wire axi_rready_i_1_n_0;
  wire axi_wlast_i_10_n_0;
  wire axi_wlast_i_11_n_0;
  wire axi_wlast_i_12_n_0;
  wire axi_wlast_i_13_n_0;
  wire axi_wlast_i_1_n_0;
  wire axi_wlast_i_2_n_0;
  wire axi_wlast_i_3_n_0;
  wire axi_wlast_i_4_n_0;
  wire axi_wlast_i_5_n_0;
  wire axi_wlast_i_6_n_0;
  wire axi_wlast_i_7_n_0;
  wire axi_wlast_i_8_n_0;
  wire axi_wlast_i_9_n_0;
  wire axi_wvalid_i_1_n_0;
  wire burst_read_active;
  wire burst_read_active_i_1_n_0;
  wire burst_write_active;
  wire burst_write_active_i_1_n_0;
  wire error_reg_i_1_n_0;
  wire fifo_rd_en;
  wire fq_ev_sel;
  wire fq_ev_sel_i_1_n_0;
  wire fq_ev_sel_reg_n_0;
  wire gnt_hold;
  wire gnt_hold_i_1_n_0;
  wire gnt_hold_i_3_n_0;
  wire gnt_hold_i_4_n_0;
  wire gnt_ps111_out__1;
  wire gnt_ps18_out__0;
  wire gnt_sw;
  wire gnt_sw_pre;
  wire gnt_sw_pre_i_1_n_0;
  wire gnt_sw_pre_i_2_n_0;
  wire m00_axi_aclk;
  wire m00_axi_aresetn;
  wire m00_axi_arready;
  wire m00_axi_arvalid;
  wire [1:0]m00_axi_awlen;
  wire m00_axi_awready;
  wire m00_axi_awvalid;
  wire m00_axi_bready;
  wire [0:0]m00_axi_bresp;
  wire m00_axi_bvalid;
  wire m00_axi_error;
  wire m00_axi_rlast;
  wire m00_axi_rready;
  wire [0:0]m00_axi_rresp;
  wire m00_axi_rvalid;
  wire m00_axi_wlast;
  wire m00_axi_wready;
  wire m00_axi_wvalid;
  wire [2:0]\master_axi_state[2] ;
  (* RTL_KEEP = "yes" *) wire [1:0]mst_exec_state;
  (* RTL_KEEP = "yes" *) wire [2:0]out;
  wire p_19_in;
  wire p_30_in;
  wire [7:0]plusOp;
  wire [7:0]plusOp__0;
  wire read_burst_counter;
  wire \read_burst_counter[0]_i_1_n_0 ;
  wire [7:0]read_burst_len;
  wire read_index0;
  wire read_index1;
  wire read_index1_carry_i_1_n_0;
  wire read_index1_carry_i_2_n_0;
  wire read_index1_carry_i_3_n_0;
  wire read_index1_carry_i_4_n_0;
  wire read_index1_carry_i_5_n_0;
  wire read_index1_carry_i_6_n_0;
  wire read_index1_carry_i_7_n_0;
  wire read_index1_carry_i_8_n_0;
  wire read_index1_carry_i_9_n_0;
  wire read_index1_carry_n_1;
  wire read_index1_carry_n_2;
  wire read_index1_carry_n_3;
  wire \read_index[7]_i_1_n_0 ;
  wire \read_index[7]_i_4_n_0 ;
  wire [7:0]read_index_reg__0;
  wire reads_done;
  wire reads_done_i_1_n_0;
  wire reads_done_i_2_n_0;
  wire reads_done_i_3_n_0;
  wire reads_done_i_4_n_0;
  wire reads_done_i_5_n_0;
  wire reads_done_i_6_n_0;
  wire reads_done_reg_0;
  wire start_read;
  wire start_single_burst_read_i_1_n_0;
  wire start_single_burst_read_reg_n_0;
  wire start_single_burst_write_i_1_n_0;
  wire start_single_burst_write_reg_n_0;
  wire start_write;
  wire write_burst_counter;
  wire \write_burst_counter[0]_i_1_n_0 ;
  wire [7:0]write_burst_len;
  wire write_index0;
  wire \write_index[7]_i_10_n_0 ;
  wire \write_index[7]_i_1_n_0 ;
  wire \write_index[7]_i_4_n_0 ;
  wire \write_index[7]_i_5_n_0 ;
  wire \write_index[7]_i_6_n_0 ;
  wire \write_index[7]_i_8_n_0 ;
  wire \write_index[7]_i_9_n_0 ;
  wire \write_index_reg[0]_0 ;
  wire [7:0]write_index_reg__0;
  wire writes_done;
  wire writes_done_i_1_n_0;
  wire [3:0]NLW_read_index1_carry_O_UNCONNECTED;

  LUT6 #(
    .INIT(64'h0E00FFFF0E000000)) 
    \FSM_onehot_gnt_ps[0]_i_1 
       (.I0(out[1]),
        .I1(out[2]),
        .I2(gnt_hold),
        .I3(axi_if_req[0]),
        .I4(\FSM_onehot_gnt_ps[2]_i_5_n_0 ),
        .I5(out[0]),
        .O(\FSM_onehot_gnt_ps[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4F44FFFF4F440000)) 
    \FSM_onehot_gnt_ps[1]_i_1 
       (.I0(gnt_ps18_out__0),
        .I1(out[2]),
        .I2(gnt_ps111_out__1),
        .I3(out[0]),
        .I4(\FSM_onehot_gnt_ps[2]_i_5_n_0 ),
        .I5(out[1]),
        .O(\FSM_onehot_gnt_ps[1]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \FSM_onehot_gnt_ps[2]_i_1 
       (.I0(m00_axi_aresetn),
        .O(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF444FFFFF4440000)) 
    \FSM_onehot_gnt_ps[2]_i_2 
       (.I0(gnt_ps18_out__0),
        .I1(out[1]),
        .I2(gnt_ps111_out__1),
        .I3(out[0]),
        .I4(\FSM_onehot_gnt_ps[2]_i_5_n_0 ),
        .I5(out[2]),
        .O(\FSM_onehot_gnt_ps[2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \FSM_onehot_gnt_ps[2]_i_3 
       (.I0(axi_if_req[0]),
        .I1(gnt_hold),
        .O(gnt_ps18_out__0));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h0444)) 
    \FSM_onehot_gnt_ps[2]_i_4 
       (.I0(gnt_hold),
        .I1(axi_if_req[2]),
        .I2(fq_ev_sel_reg_n_0),
        .I3(axi_if_req[1]),
        .O(gnt_ps111_out__1));
  LUT4 #(
    .INIT(16'h000E)) 
    \FSM_onehot_gnt_ps[2]_i_5 
       (.I0(\FSM_onehot_gnt_ps[2]_i_6_n_0 ),
        .I1(\FSM_onehot_gnt_ps[2]_i_7_n_0 ),
        .I2(mst_exec_state[1]),
        .I3(mst_exec_state[0]),
        .O(\FSM_onehot_gnt_ps[2]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h0000FAFA0000F888)) 
    \FSM_onehot_gnt_ps[2]_i_6 
       (.I0(out[2]),
        .I1(axi_if_req[1]),
        .I2(out[1]),
        .I3(axi_if_req[2]),
        .I4(gnt_hold),
        .I5(axi_if_req[0]),
        .O(\FSM_onehot_gnt_ps[2]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'h2220)) 
    \FSM_onehot_gnt_ps[2]_i_7 
       (.I0(out[0]),
        .I1(gnt_hold),
        .I2(axi_if_req[2]),
        .I3(axi_if_req[1]),
        .O(\FSM_onehot_gnt_ps[2]_i_7_n_0 ));
  (* FSM_ENCODED_STATES = "fq_st:010,ev_st:100,rd_st:001" *) 
  (* KEEP = "yes" *) 
  FDSE #(
    .INIT(1'b1)) 
    \FSM_onehot_gnt_ps_reg[0] 
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(\FSM_onehot_gnt_ps[0]_i_1_n_0 ),
        .Q(out[0]),
        .S(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "fq_st:010,ev_st:100,rd_st:001" *) 
  (* KEEP = "yes" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_gnt_ps_reg[1] 
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(\FSM_onehot_gnt_ps[1]_i_1_n_0 ),
        .Q(out[1]),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "fq_st:010,ev_st:100,rd_st:001" *) 
  (* KEEP = "yes" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_gnt_ps_reg[2] 
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(\FSM_onehot_gnt_ps[2]_i_2_n_0 ),
        .Q(out[2]),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h005C)) 
    \FSM_sequential_mst_exec_state[0]_i_1 
       (.I0(writes_done),
        .I1(start_write),
        .I2(mst_exec_state[0]),
        .I3(mst_exec_state[1]),
        .O(\FSM_sequential_mst_exec_state[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h10101310)) 
    \FSM_sequential_mst_exec_state[1]_i_1 
       (.I0(reads_done),
        .I1(mst_exec_state[0]),
        .I2(mst_exec_state[1]),
        .I3(start_read),
        .I4(start_write),
        .O(\FSM_sequential_mst_exec_state[1]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "init_write:01,init_read:10,idle:00" *) 
  (* KEEP = "yes" *) 
  FDRE \FSM_sequential_mst_exec_state_reg[0] 
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_mst_exec_state[0]_i_1_n_0 ),
        .Q(mst_exec_state[0]),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "init_write:01,init_read:10,idle:00" *) 
  (* KEEP = "yes" *) 
  FDRE \FSM_sequential_mst_exec_state_reg[1] 
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_mst_exec_state[1]_i_1_n_0 ),
        .Q(mst_exec_state[1]),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hB)) 
    axi_arvalid_i_1
       (.I0(start_read),
        .I1(m00_axi_aresetn),
        .O(axi_arvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h74)) 
    axi_arvalid_i_2
       (.I0(m00_axi_arready),
        .I1(m00_axi_arvalid),
        .I2(start_single_burst_read_reg_n_0),
        .O(axi_arvalid_i_2_n_0));
  FDRE axi_arvalid_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(axi_arvalid_i_2_n_0),
        .Q(m00_axi_arvalid),
        .R(axi_arvalid_i_1_n_0));
  LUT2 #(
    .INIT(4'hB)) 
    axi_awvalid_i_1
       (.I0(start_write),
        .I1(m00_axi_aresetn),
        .O(axi_awvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'h74)) 
    axi_awvalid_i_2
       (.I0(m00_axi_awready),
        .I1(m00_axi_awvalid),
        .I2(start_single_burst_write_reg_n_0),
        .O(axi_awvalid_i_2_n_0));
  FDRE axi_awvalid_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(axi_awvalid_i_2_n_0),
        .Q(m00_axi_awvalid),
        .R(axi_awvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h4)) 
    axi_bready_i_1
       (.I0(m00_axi_bready),
        .I1(m00_axi_bvalid),
        .O(axi_bready_i_1_n_0));
  FDRE axi_bready_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(axi_bready_i_1_n_0),
        .Q(m00_axi_bready),
        .R(axi_awvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h04404440)) 
    axi_rready_i_1
       (.I0(start_read),
        .I1(m00_axi_aresetn),
        .I2(m00_axi_rvalid),
        .I3(m00_axi_rready),
        .I4(m00_axi_rlast),
        .O(axi_rready_i_1_n_0));
  FDRE axi_rready_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(axi_rready_i_1_n_0),
        .Q(m00_axi_rready),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFFFF5575FFFF0030)) 
    axi_wlast_i_1
       (.I0(axi_wlast_i_2_n_0),
        .I1(axi_wlast_i_3_n_0),
        .I2(axi_wlast_i_4_n_0),
        .I3(axi_wlast_i_5_n_0),
        .I4(axi_wlast_i_6_n_0),
        .I5(m00_axi_wlast),
        .O(axi_wlast_i_1_n_0));
  LUT6 #(
    .INIT(64'hE5A5BFFFBFFFE5A5)) 
    axi_wlast_i_10
       (.I0(write_burst_len[1]),
        .I1(write_index_reg__0[2]),
        .I2(write_index_reg__0[1]),
        .I3(write_index_reg__0[3]),
        .I4(write_index_reg__0[4]),
        .I5(write_burst_len[4]),
        .O(axi_wlast_i_10_n_0));
  LUT6 #(
    .INIT(64'hF6666FFF6FFFF666)) 
    axi_wlast_i_11
       (.I0(write_index_reg__0[0]),
        .I1(write_burst_len[0]),
        .I2(write_index_reg__0[1]),
        .I3(write_index_reg__0[2]),
        .I4(write_index_reg__0[3]),
        .I5(write_burst_len[3]),
        .O(axi_wlast_i_11_n_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    axi_wlast_i_12
       (.I0(write_burst_len[6]),
        .I1(write_burst_len[4]),
        .I2(write_burst_len[5]),
        .I3(write_burst_len[7]),
        .O(axi_wlast_i_12_n_0));
  LUT5 #(
    .INIT(32'h80000000)) 
    axi_wlast_i_13
       (.I0(write_index_reg__0[5]),
        .I1(write_index_reg__0[3]),
        .I2(write_index_reg__0[1]),
        .I3(write_index_reg__0[2]),
        .I4(write_index_reg__0[4]),
        .O(axi_wlast_i_13_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFF00001000)) 
    axi_wlast_i_2
       (.I0(axi_wlast_i_7_n_0),
        .I1(write_burst_len[0]),
        .I2(write_burst_len[1]),
        .I3(m00_axi_wlast),
        .I4(axi_wlast_i_8_n_0),
        .I5(p_30_in),
        .O(axi_wlast_i_2_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFEEFEFFE)) 
    axi_wlast_i_3
       (.I0(axi_wlast_i_9_n_0),
        .I1(axi_wlast_i_10_n_0),
        .I2(write_burst_len[2]),
        .I3(write_index_reg__0[2]),
        .I4(write_index_reg__0[1]),
        .I5(axi_wlast_i_11_n_0),
        .O(axi_wlast_i_3_n_0));
  LUT6 #(
    .INIT(64'hFFFE000000000000)) 
    axi_wlast_i_4
       (.I0(write_burst_len[1]),
        .I1(write_burst_len[2]),
        .I2(write_burst_len[3]),
        .I3(axi_wlast_i_12_n_0),
        .I4(m00_axi_wready),
        .I5(m00_axi_wvalid),
        .O(axi_wlast_i_4_n_0));
  LUT5 #(
    .INIT(32'hF66F9FF6)) 
    axi_wlast_i_5
       (.I0(write_index_reg__0[7]),
        .I1(write_burst_len[7]),
        .I2(axi_wlast_i_13_n_0),
        .I3(write_index_reg__0[6]),
        .I4(write_burst_len[6]),
        .O(axi_wlast_i_5_n_0));
  LUT6 #(
    .INIT(64'h0000000000100000)) 
    axi_wlast_i_6
       (.I0(axi_wlast_i_8_n_0),
        .I1(write_burst_len[1]),
        .I2(write_burst_len[0]),
        .I3(m00_axi_wlast),
        .I4(start_single_burst_write_reg_n_0),
        .I5(axi_wlast_i_7_n_0),
        .O(axi_wlast_i_6_n_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    axi_wlast_i_7
       (.I0(write_burst_len[4]),
        .I1(write_burst_len[5]),
        .I2(write_burst_len[7]),
        .I3(write_burst_len[6]),
        .O(axi_wlast_i_7_n_0));
  LUT2 #(
    .INIT(4'hE)) 
    axi_wlast_i_8
       (.I0(write_burst_len[3]),
        .I1(write_burst_len[2]),
        .O(axi_wlast_i_8_n_0));
  LUT6 #(
    .INIT(64'h9666666666666666)) 
    axi_wlast_i_9
       (.I0(write_burst_len[5]),
        .I1(write_index_reg__0[5]),
        .I2(write_index_reg__0[4]),
        .I3(write_index_reg__0[2]),
        .I4(write_index_reg__0[1]),
        .I5(write_index_reg__0[3]),
        .O(axi_wlast_i_9_n_0));
  FDRE axi_wlast_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(axi_wlast_i_1_n_0),
        .Q(m00_axi_wlast),
        .R(axi_awvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h2EEE)) 
    axi_wvalid_i_1
       (.I0(start_single_burst_write_reg_n_0),
        .I1(m00_axi_wvalid),
        .I2(m00_axi_wready),
        .I3(m00_axi_wlast),
        .O(axi_wvalid_i_1_n_0));
  FDRE axi_wvalid_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(axi_wvalid_i_1_n_0),
        .Q(m00_axi_wvalid),
        .R(axi_awvalid_i_1_n_0));
  LUT5 #(
    .INIT(32'hFF7FFF00)) 
    burst_read_active_i_1
       (.I0(m00_axi_rlast),
        .I1(m00_axi_rready),
        .I2(m00_axi_rvalid),
        .I3(start_single_burst_read_reg_n_0),
        .I4(burst_read_active),
        .O(burst_read_active_i_1_n_0));
  FDRE burst_read_active_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(burst_read_active_i_1_n_0),
        .Q(burst_read_active),
        .R(axi_arvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hBFAA)) 
    burst_write_active_i_1
       (.I0(start_single_burst_write_reg_n_0),
        .I1(m00_axi_bvalid),
        .I2(m00_axi_bready),
        .I3(burst_write_active),
        .O(burst_write_active_i_1_n_0));
  FDRE burst_write_active_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(burst_write_active_i_1_n_0),
        .Q(burst_write_active),
        .R(axi_awvalid_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFF8888888)) 
    error_reg_i_1
       (.I0(m00_axi_rresp),
        .I1(p_19_in),
        .I2(m00_axi_bresp),
        .I3(m00_axi_bvalid),
        .I4(m00_axi_bready),
        .I5(m00_axi_error),
        .O(error_reg_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h8)) 
    error_reg_i_2
       (.I0(m00_axi_rready),
        .I1(m00_axi_rvalid),
        .O(p_19_in));
  FDRE error_reg_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(error_reg_i_1_n_0),
        .Q(m00_axi_error),
        .R(axi_arvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'hFF40)) 
    fifo_rd_en_INST_0
       (.I0(m00_axi_wlast),
        .I1(m00_axi_wvalid),
        .I2(m00_axi_wready),
        .I3(start_single_burst_write_reg_n_0),
        .O(fifo_rd_en));
  LUT3 #(
    .INIT(8'hBA)) 
    fq_ev_sel_i_1
       (.I0(out[2]),
        .I1(out[1]),
        .I2(fq_ev_sel_reg_n_0),
        .O(fq_ev_sel_i_1_n_0));
  FDRE fq_ev_sel_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(fq_ev_sel_i_1_n_0),
        .Q(fq_ev_sel_reg_n_0),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000000CCCEEEEE)) 
    gnt_hold_i_1
       (.I0(gnt_hold),
        .I1(\FSM_onehot_gnt_ps[2]_i_5_n_0 ),
        .I2(fq_ev_sel),
        .I3(out[0]),
        .I4(gnt_hold_i_3_n_0),
        .I5(gnt_hold_i_4_n_0),
        .O(gnt_hold_i_1_n_0));
  LUT2 #(
    .INIT(4'hE)) 
    gnt_hold_i_2
       (.I0(out[2]),
        .I1(out[1]),
        .O(fq_ev_sel));
  LUT3 #(
    .INIT(8'hA8)) 
    gnt_hold_i_3
       (.I0(gnt_sw),
        .I1(mst_exec_state[1]),
        .I2(mst_exec_state[0]),
        .O(gnt_hold_i_3_n_0));
  LUT4 #(
    .INIT(16'h01FF)) 
    gnt_hold_i_4
       (.I0(axi_if_req[0]),
        .I1(axi_if_req[1]),
        .I2(axi_if_req[2]),
        .I3(m00_axi_aresetn),
        .O(gnt_hold_i_4_n_0));
  FDRE gnt_hold_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(gnt_hold_i_1_n_0),
        .Q(gnt_hold),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFFBBAFFFAAAAAAAA)) 
    gnt_sw_pre_i_1
       (.I0(gnt_sw_pre_i_2_n_0),
        .I1(writes_done),
        .I2(reads_done),
        .I3(mst_exec_state[1]),
        .I4(mst_exec_state[0]),
        .I5(gnt_sw_pre),
        .O(gnt_sw_pre_i_1_n_0));
  LUT4 #(
    .INIT(16'h000E)) 
    gnt_sw_pre_i_2
       (.I0(start_read),
        .I1(start_write),
        .I2(mst_exec_state[1]),
        .I3(mst_exec_state[0]),
        .O(gnt_sw_pre_i_2_n_0));
  FDRE gnt_sw_pre_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(gnt_sw_pre_i_1_n_0),
        .Q(gnt_sw_pre),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  FDRE gnt_sw_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(gnt_sw_pre),
        .Q(gnt_sw),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \m00_axi_arlen[7]_INST_0_i_1 
       (.I0(read_burst_len[4]),
        .I1(read_burst_len[2]),
        .I2(read_burst_len[0]),
        .I3(read_burst_len[1]),
        .I4(read_burst_len[3]),
        .I5(read_burst_len[5]),
        .O(reads_done_reg_0));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'h9)) 
    \m00_axi_awlen[1]_INST_0 
       (.I0(write_burst_len[0]),
        .I1(write_burst_len[1]),
        .O(m00_axi_awlen[0]));
  LUT2 #(
    .INIT(4'h9)) 
    \m00_axi_awlen[6]_INST_0 
       (.I0(\write_index_reg[0]_0 ),
        .I1(write_burst_len[6]),
        .O(m00_axi_awlen[1]));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \m00_axi_awlen[7]_INST_0_i_1 
       (.I0(write_burst_len[4]),
        .I1(write_burst_len[2]),
        .I2(write_burst_len[0]),
        .I3(write_burst_len[1]),
        .I4(write_burst_len[3]),
        .I5(write_burst_len[5]),
        .O(\write_index_reg[0]_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \master_axi_state[0]_INST_0 
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .O(\master_axi_state[2] [0]));
  LUT2 #(
    .INIT(4'h2)) 
    \master_axi_state[1]_INST_0 
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .O(\master_axi_state[2] [1]));
  LUT2 #(
    .INIT(4'h2)) 
    \master_axi_state[2]_INST_0 
       (.I0(mst_exec_state[1]),
        .I1(mst_exec_state[0]),
        .O(\master_axi_state[2] [2]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hF8)) 
    \read_burst_counter[0]_i_1 
       (.I0(m00_axi_arvalid),
        .I1(m00_axi_arready),
        .I2(read_burst_counter),
        .O(\read_burst_counter[0]_i_1_n_0 ));
  FDRE \read_burst_counter_reg[0] 
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(\read_burst_counter[0]_i_1_n_0 ),
        .Q(read_burst_counter),
        .R(axi_arvalid_i_1_n_0));
  CARRY4 read_index1_carry
       (.CI(1'b0),
        .CO({read_index1,read_index1_carry_n_1,read_index1_carry_n_2,read_index1_carry_n_3}),
        .CYINIT(1'b1),
        .DI({read_index1_carry_i_1_n_0,read_index1_carry_i_2_n_0,read_index1_carry_i_3_n_0,read_index1_carry_i_4_n_0}),
        .O(NLW_read_index1_carry_O_UNCONNECTED[3:0]),
        .S({read_index1_carry_i_5_n_0,read_index1_carry_i_6_n_0,read_index1_carry_i_7_n_0,read_index1_carry_i_8_n_0}));
  LUT5 #(
    .INIT(32'h73311007)) 
    read_index1_carry_i_1
       (.I0(read_index_reg__0[6]),
        .I1(read_index_reg__0[7]),
        .I2(read_burst_len[6]),
        .I3(reads_done_reg_0),
        .I4(read_burst_len[7]),
        .O(read_index1_carry_i_1_n_0));
  LUT5 #(
    .INIT(32'h73311007)) 
    read_index1_carry_i_2
       (.I0(read_index_reg__0[4]),
        .I1(read_index_reg__0[5]),
        .I2(read_burst_len[4]),
        .I3(read_index1_carry_i_9_n_0),
        .I4(read_burst_len[5]),
        .O(read_index1_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h7373733110101007)) 
    read_index1_carry_i_3
       (.I0(read_index_reg__0[2]),
        .I1(read_index_reg__0[3]),
        .I2(read_burst_len[2]),
        .I3(read_burst_len[0]),
        .I4(read_burst_len[1]),
        .I5(read_burst_len[3]),
        .O(read_index1_carry_i_3_n_0));
  LUT4 #(
    .INIT(16'h3107)) 
    read_index1_carry_i_4
       (.I0(read_index_reg__0[0]),
        .I1(read_index_reg__0[1]),
        .I2(read_burst_len[0]),
        .I3(read_burst_len[1]),
        .O(read_index1_carry_i_4_n_0));
  LUT5 #(
    .INIT(32'h81422814)) 
    read_index1_carry_i_5
       (.I0(read_burst_len[7]),
        .I1(reads_done_reg_0),
        .I2(read_burst_len[6]),
        .I3(read_index_reg__0[7]),
        .I4(read_index_reg__0[6]),
        .O(read_index1_carry_i_5_n_0));
  LUT5 #(
    .INIT(32'h81422814)) 
    read_index1_carry_i_6
       (.I0(read_burst_len[5]),
        .I1(read_index1_carry_i_9_n_0),
        .I2(read_burst_len[4]),
        .I3(read_index_reg__0[5]),
        .I4(read_index_reg__0[4]),
        .O(read_index1_carry_i_6_n_0));
  LUT6 #(
    .INIT(64'hA801540202A80154)) 
    read_index1_carry_i_7
       (.I0(read_burst_len[3]),
        .I1(read_burst_len[1]),
        .I2(read_burst_len[0]),
        .I3(read_burst_len[2]),
        .I4(read_index_reg__0[3]),
        .I5(read_index_reg__0[2]),
        .O(read_index1_carry_i_7_n_0));
  LUT4 #(
    .INIT(16'h1284)) 
    read_index1_carry_i_8
       (.I0(read_burst_len[1]),
        .I1(read_burst_len[0]),
        .I2(read_index_reg__0[1]),
        .I3(read_index_reg__0[0]),
        .O(read_index1_carry_i_8_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    read_index1_carry_i_9
       (.I0(read_burst_len[2]),
        .I1(read_burst_len[0]),
        .I2(read_burst_len[1]),
        .I3(read_burst_len[3]),
        .O(read_index1_carry_i_9_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    \read_index[0]_i_1 
       (.I0(read_index_reg__0[0]),
        .O(plusOp[0]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \read_index[1]_i_1 
       (.I0(read_index_reg__0[0]),
        .I1(read_index_reg__0[1]),
        .O(plusOp[1]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \read_index[2]_i_1 
       (.I0(read_index_reg__0[0]),
        .I1(read_index_reg__0[1]),
        .I2(read_index_reg__0[2]),
        .O(plusOp[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \read_index[3]_i_1 
       (.I0(read_index_reg__0[1]),
        .I1(read_index_reg__0[0]),
        .I2(read_index_reg__0[2]),
        .I3(read_index_reg__0[3]),
        .O(plusOp[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \read_index[4]_i_1 
       (.I0(read_index_reg__0[2]),
        .I1(read_index_reg__0[0]),
        .I2(read_index_reg__0[1]),
        .I3(read_index_reg__0[3]),
        .I4(read_index_reg__0[4]),
        .O(plusOp[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \read_index[5]_i_1 
       (.I0(read_index_reg__0[3]),
        .I1(read_index_reg__0[1]),
        .I2(read_index_reg__0[0]),
        .I3(read_index_reg__0[2]),
        .I4(read_index_reg__0[4]),
        .I5(read_index_reg__0[5]),
        .O(plusOp[5]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \read_index[6]_i_1 
       (.I0(\read_index[7]_i_4_n_0 ),
        .I1(read_index_reg__0[6]),
        .O(plusOp[6]));
  LUT3 #(
    .INIT(8'hFD)) 
    \read_index[7]_i_1 
       (.I0(m00_axi_aresetn),
        .I1(start_read),
        .I2(start_single_burst_read_reg_n_0),
        .O(\read_index[7]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \read_index[7]_i_2 
       (.I0(read_index1),
        .I1(m00_axi_rvalid),
        .I2(m00_axi_rready),
        .O(read_index0));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \read_index[7]_i_3 
       (.I0(\read_index[7]_i_4_n_0 ),
        .I1(read_index_reg__0[6]),
        .I2(read_index_reg__0[7]),
        .O(plusOp[7]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \read_index[7]_i_4 
       (.I0(read_index_reg__0[5]),
        .I1(read_index_reg__0[3]),
        .I2(read_index_reg__0[1]),
        .I3(read_index_reg__0[0]),
        .I4(read_index_reg__0[2]),
        .I5(read_index_reg__0[4]),
        .O(\read_index[7]_i_4_n_0 ));
  FDRE \read_index_reg[0] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[0]),
        .Q(read_index_reg__0[0]),
        .R(\read_index[7]_i_1_n_0 ));
  FDRE \read_index_reg[1] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[1]),
        .Q(read_index_reg__0[1]),
        .R(\read_index[7]_i_1_n_0 ));
  FDRE \read_index_reg[2] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[2]),
        .Q(read_index_reg__0[2]),
        .R(\read_index[7]_i_1_n_0 ));
  FDRE \read_index_reg[3] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[3]),
        .Q(read_index_reg__0[3]),
        .R(\read_index[7]_i_1_n_0 ));
  FDRE \read_index_reg[4] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[4]),
        .Q(read_index_reg__0[4]),
        .R(\read_index[7]_i_1_n_0 ));
  FDRE \read_index_reg[5] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[5]),
        .Q(read_index_reg__0[5]),
        .R(\read_index[7]_i_1_n_0 ));
  FDRE \read_index_reg[6] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[6]),
        .Q(read_index_reg__0[6]),
        .R(\read_index[7]_i_1_n_0 ));
  FDRE \read_index_reg[7] 
       (.C(m00_axi_aclk),
        .CE(read_index0),
        .D(plusOp[7]),
        .Q(read_index_reg__0[7]),
        .R(\read_index[7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000040)) 
    reads_done_i_1
       (.I0(reads_done_i_2_n_0),
        .I1(read_burst_counter),
        .I2(p_19_in),
        .I3(reads_done_i_3_n_0),
        .I4(reads_done_i_4_n_0),
        .I5(reads_done),
        .O(reads_done_i_1_n_0));
  LUT5 #(
    .INIT(32'h6FF6F69F)) 
    reads_done_i_2
       (.I0(read_index_reg__0[7]),
        .I1(read_burst_len[7]),
        .I2(read_index_reg__0[6]),
        .I3(reads_done_reg_0),
        .I4(read_burst_len[6]),
        .O(reads_done_i_2_n_0));
  LUT6 #(
    .INIT(64'hEFEFBFFBFEFEFBBF)) 
    reads_done_i_3
       (.I0(reads_done_i_5_n_0),
        .I1(read_index_reg__0[0]),
        .I2(read_index_reg__0[2]),
        .I3(read_burst_len[1]),
        .I4(read_burst_len[0]),
        .I5(read_burst_len[2]),
        .O(reads_done_i_3_n_0));
  LUT6 #(
    .INIT(64'hDFEFEFFDFDFEFEDF)) 
    reads_done_i_4
       (.I0(read_index_reg__0[4]),
        .I1(reads_done_i_6_n_0),
        .I2(read_index_reg__0[5]),
        .I3(read_burst_len[4]),
        .I4(read_index1_carry_i_9_n_0),
        .I5(read_burst_len[5]),
        .O(reads_done_i_4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h5556AAA9)) 
    reads_done_i_5
       (.I0(read_burst_len[3]),
        .I1(read_burst_len[1]),
        .I2(read_burst_len[0]),
        .I3(read_burst_len[2]),
        .I4(read_index_reg__0[3]),
        .O(reads_done_i_5_n_0));
  LUT3 #(
    .INIT(8'h69)) 
    reads_done_i_6
       (.I0(read_burst_len[1]),
        .I1(read_burst_len[0]),
        .I2(read_index_reg__0[1]),
        .O(reads_done_i_6_n_0));
  FDRE reads_done_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(reads_done_i_1_n_0),
        .Q(reads_done),
        .R(axi_arvalid_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFFFF0FF00000100)) 
    start_single_burst_read_i_1
       (.I0(m00_axi_arvalid),
        .I1(burst_read_active),
        .I2(mst_exec_state[0]),
        .I3(mst_exec_state[1]),
        .I4(reads_done),
        .I5(start_single_burst_read_reg_n_0),
        .O(start_single_burst_read_i_1_n_0));
  FDRE start_single_burst_read_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(start_single_burst_read_i_1_n_0),
        .Q(start_single_burst_read_reg_n_0),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFF0FF00000100)) 
    start_single_burst_write_i_1
       (.I0(m00_axi_awvalid),
        .I1(burst_write_active),
        .I2(mst_exec_state[1]),
        .I3(mst_exec_state[0]),
        .I4(writes_done),
        .I5(start_single_burst_write_reg_n_0),
        .O(start_single_burst_write_i_1_n_0));
  FDRE start_single_burst_write_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(start_single_burst_write_i_1_n_0),
        .Q(start_single_burst_write_reg_n_0),
        .R(\FSM_onehot_gnt_ps[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hF8)) 
    \write_burst_counter[0]_i_1 
       (.I0(m00_axi_awvalid),
        .I1(m00_axi_awready),
        .I2(write_burst_counter),
        .O(\write_burst_counter[0]_i_1_n_0 ));
  FDRE \write_burst_counter_reg[0] 
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(\write_burst_counter[0]_i_1_n_0 ),
        .Q(write_burst_counter),
        .R(axi_awvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \write_index[0]_i_1 
       (.I0(write_index_reg__0[0]),
        .O(plusOp__0[0]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \write_index[1]_i_1 
       (.I0(write_index_reg__0[0]),
        .I1(write_index_reg__0[1]),
        .O(plusOp__0[1]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \write_index[2]_i_1 
       (.I0(write_index_reg__0[0]),
        .I1(write_index_reg__0[1]),
        .I2(write_index_reg__0[2]),
        .O(plusOp__0[2]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \write_index[3]_i_1 
       (.I0(write_index_reg__0[1]),
        .I1(write_index_reg__0[0]),
        .I2(write_index_reg__0[2]),
        .I3(write_index_reg__0[3]),
        .O(plusOp__0[3]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \write_index[4]_i_1 
       (.I0(write_index_reg__0[2]),
        .I1(write_index_reg__0[0]),
        .I2(write_index_reg__0[1]),
        .I3(write_index_reg__0[3]),
        .I4(write_index_reg__0[4]),
        .O(plusOp__0[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \write_index[5]_i_1 
       (.I0(write_index_reg__0[3]),
        .I1(write_index_reg__0[1]),
        .I2(write_index_reg__0[0]),
        .I3(write_index_reg__0[2]),
        .I4(write_index_reg__0[4]),
        .I5(write_index_reg__0[5]),
        .O(plusOp__0[5]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \write_index[6]_i_1 
       (.I0(\write_index[7]_i_8_n_0 ),
        .I1(write_index_reg__0[6]),
        .O(plusOp__0[6]));
  LUT3 #(
    .INIT(8'hFD)) 
    \write_index[7]_i_1 
       (.I0(m00_axi_aresetn),
        .I1(start_write),
        .I2(start_single_burst_write_reg_n_0),
        .O(\write_index[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    \write_index[7]_i_10 
       (.I0(write_burst_len[2]),
        .I1(write_burst_len[0]),
        .I2(write_burst_len[1]),
        .I3(write_burst_len[3]),
        .O(\write_index[7]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hEFFFFFEF00000000)) 
    \write_index[7]_i_2 
       (.I0(\write_index[7]_i_4_n_0 ),
        .I1(\write_index[7]_i_5_n_0 ),
        .I2(\write_index[7]_i_6_n_0 ),
        .I3(m00_axi_awlen[1]),
        .I4(write_index_reg__0[6]),
        .I5(p_30_in),
        .O(write_index0));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \write_index[7]_i_3 
       (.I0(\write_index[7]_i_8_n_0 ),
        .I1(write_index_reg__0[6]),
        .I2(write_index_reg__0[7]),
        .O(plusOp__0[7]));
  LUT6 #(
    .INIT(64'h6F6F6FF6F6F6F66F)) 
    \write_index[7]_i_4 
       (.I0(write_index_reg__0[1]),
        .I1(m00_axi_awlen[0]),
        .I2(write_index_reg__0[7]),
        .I3(write_burst_len[6]),
        .I4(\write_index_reg[0]_0 ),
        .I5(write_burst_len[7]),
        .O(\write_index[7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hDFEFEFFDFDFEFEDF)) 
    \write_index[7]_i_5 
       (.I0(write_index_reg__0[4]),
        .I1(\write_index[7]_i_9_n_0 ),
        .I2(write_index_reg__0[5]),
        .I3(write_burst_len[4]),
        .I4(\write_index[7]_i_10_n_0 ),
        .I5(write_burst_len[5]),
        .O(\write_index[7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \write_index[7]_i_6 
       (.I0(write_burst_len[0]),
        .I1(write_index_reg__0[0]),
        .O(\write_index[7]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \write_index[7]_i_7 
       (.I0(m00_axi_wvalid),
        .I1(m00_axi_wready),
        .O(p_30_in));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \write_index[7]_i_8 
       (.I0(write_index_reg__0[5]),
        .I1(write_index_reg__0[3]),
        .I2(write_index_reg__0[1]),
        .I3(write_index_reg__0[0]),
        .I4(write_index_reg__0[2]),
        .I5(write_index_reg__0[4]),
        .O(\write_index[7]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'h6F6F6FF6F6F6F69F)) 
    \write_index[7]_i_9 
       (.I0(write_index_reg__0[3]),
        .I1(write_burst_len[3]),
        .I2(write_index_reg__0[2]),
        .I3(write_burst_len[1]),
        .I4(write_burst_len[0]),
        .I5(write_burst_len[2]),
        .O(\write_index[7]_i_9_n_0 ));
  FDRE \write_index_reg[0] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[0]),
        .Q(write_index_reg__0[0]),
        .R(\write_index[7]_i_1_n_0 ));
  FDRE \write_index_reg[1] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[1]),
        .Q(write_index_reg__0[1]),
        .R(\write_index[7]_i_1_n_0 ));
  FDRE \write_index_reg[2] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[2]),
        .Q(write_index_reg__0[2]),
        .R(\write_index[7]_i_1_n_0 ));
  FDRE \write_index_reg[3] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[3]),
        .Q(write_index_reg__0[3]),
        .R(\write_index[7]_i_1_n_0 ));
  FDRE \write_index_reg[4] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[4]),
        .Q(write_index_reg__0[4]),
        .R(\write_index[7]_i_1_n_0 ));
  FDRE \write_index_reg[5] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[5]),
        .Q(write_index_reg__0[5]),
        .R(\write_index[7]_i_1_n_0 ));
  FDRE \write_index_reg[6] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[6]),
        .Q(write_index_reg__0[6]),
        .R(\write_index[7]_i_1_n_0 ));
  FDRE \write_index_reg[7] 
       (.C(m00_axi_aclk),
        .CE(write_index0),
        .D(plusOp__0[7]),
        .Q(write_index_reg__0[7]),
        .R(\write_index[7]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFF80)) 
    writes_done_i_1
       (.I0(write_burst_counter),
        .I1(m00_axi_bready),
        .I2(m00_axi_bvalid),
        .I3(writes_done),
        .O(writes_done_i_1_n_0));
  FDRE writes_done_reg
       (.C(m00_axi_aclk),
        .CE(1'b1),
        .D(writes_done_i_1_n_0),
        .Q(writes_done),
        .R(axi_awvalid_i_1_n_0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
