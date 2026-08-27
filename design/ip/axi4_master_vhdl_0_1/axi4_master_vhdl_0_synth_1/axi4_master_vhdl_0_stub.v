// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Tue Sep 13 16:40:45 2022
// Host        : YY529462 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/PR/Vivado/Spartan7_tmc/Spartan7_tmc.runs/axi4_master_vhdl_0_synth_1/axi4_master_vhdl_0_stub.v
// Design      : axi4_master_vhdl_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7s75fgga484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "axi4_master_vhdl_v1_0,Vivado 2018.2" *)
module axi4_master_vhdl_0(start_write, start_read, write_burst_len, 
  read_burst_len, fifo_axi_wdata, fifo_wdata_valid, waddr_offset, raddr_offset, fifo_rd_en, 
  master_axi_state, axi_if_req, m00_axi_awid, m00_axi_awaddr, m00_axi_awlen, m00_axi_awsize, 
  m00_axi_awburst, m00_axi_awlock, m00_axi_awcache, m00_axi_awprot, m00_axi_awqos, 
  m00_axi_awuser, m00_axi_awvalid, m00_axi_awready, m00_axi_wdata, m00_axi_wstrb, 
  m00_axi_wlast, m00_axi_wuser, m00_axi_wvalid, m00_axi_wready, m00_axi_bid, m00_axi_bresp, 
  m00_axi_buser, m00_axi_bvalid, m00_axi_bready, m00_axi_arid, m00_axi_araddr, m00_axi_arlen, 
  m00_axi_arsize, m00_axi_arburst, m00_axi_arlock, m00_axi_arcache, m00_axi_arprot, 
  m00_axi_arqos, m00_axi_aruser, m00_axi_arvalid, m00_axi_arready, m00_axi_rid, 
  m00_axi_rdata, m00_axi_rresp, m00_axi_rlast, m00_axi_ruser, m00_axi_rvalid, m00_axi_rready, 
  m00_axi_aclk, m00_axi_aresetn, m00_axi_init_axi_txn, m00_axi_txn_done, m00_axi_error)
/* synthesis syn_black_box black_box_pad_pin="start_write,start_read,write_burst_len[7:0],read_burst_len[7:0],fifo_axi_wdata[31:0],fifo_wdata_valid,waddr_offset[29:0],raddr_offset[29:0],fifo_rd_en,master_axi_state[7:0],axi_if_req[2:0],m00_axi_awid[3:0],m00_axi_awaddr[29:0],m00_axi_awlen[7:0],m00_axi_awsize[2:0],m00_axi_awburst[1:0],m00_axi_awlock,m00_axi_awcache[3:0],m00_axi_awprot[2:0],m00_axi_awqos[3:0],m00_axi_awuser[0:0],m00_axi_awvalid,m00_axi_awready,m00_axi_wdata[31:0],m00_axi_wstrb[3:0],m00_axi_wlast,m00_axi_wuser[0:0],m00_axi_wvalid,m00_axi_wready,m00_axi_bid[3:0],m00_axi_bresp[1:0],m00_axi_buser[0:0],m00_axi_bvalid,m00_axi_bready,m00_axi_arid[3:0],m00_axi_araddr[29:0],m00_axi_arlen[7:0],m00_axi_arsize[2:0],m00_axi_arburst[1:0],m00_axi_arlock,m00_axi_arcache[3:0],m00_axi_arprot[2:0],m00_axi_arqos[3:0],m00_axi_aruser[0:0],m00_axi_arvalid,m00_axi_arready,m00_axi_rid[3:0],m00_axi_rdata[31:0],m00_axi_rresp[1:0],m00_axi_rlast,m00_axi_ruser[0:0],m00_axi_rvalid,m00_axi_rready,m00_axi_aclk,m00_axi_aresetn,m00_axi_init_axi_txn,m00_axi_txn_done,m00_axi_error" */;
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
  output [3:0]m00_axi_awid;
  output [29:0]m00_axi_awaddr;
  output [7:0]m00_axi_awlen;
  output [2:0]m00_axi_awsize;
  output [1:0]m00_axi_awburst;
  output m00_axi_awlock;
  output [3:0]m00_axi_awcache;
  output [2:0]m00_axi_awprot;
  output [3:0]m00_axi_awqos;
  output [0:0]m00_axi_awuser;
  output m00_axi_awvalid;
  input m00_axi_awready;
  output [31:0]m00_axi_wdata;
  output [3:0]m00_axi_wstrb;
  output m00_axi_wlast;
  output [0:0]m00_axi_wuser;
  output m00_axi_wvalid;
  input m00_axi_wready;
  input [3:0]m00_axi_bid;
  input [1:0]m00_axi_bresp;
  input [0:0]m00_axi_buser;
  input m00_axi_bvalid;
  output m00_axi_bready;
  output [3:0]m00_axi_arid;
  output [29:0]m00_axi_araddr;
  output [7:0]m00_axi_arlen;
  output [2:0]m00_axi_arsize;
  output [1:0]m00_axi_arburst;
  output m00_axi_arlock;
  output [3:0]m00_axi_arcache;
  output [2:0]m00_axi_arprot;
  output [3:0]m00_axi_arqos;
  output [0:0]m00_axi_aruser;
  output m00_axi_arvalid;
  input m00_axi_arready;
  input [3:0]m00_axi_rid;
  input [31:0]m00_axi_rdata;
  input [1:0]m00_axi_rresp;
  input m00_axi_rlast;
  input [0:0]m00_axi_ruser;
  input m00_axi_rvalid;
  output m00_axi_rready;
  input m00_axi_aclk;
  input m00_axi_aresetn;
  input m00_axi_init_axi_txn;
  output m00_axi_txn_done;
  output m00_axi_error;
endmodule
