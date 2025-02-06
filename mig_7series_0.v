//*****************************************************************************

// (c) Copyright 2009 - 2012 Xilinx, Inc. All rights reserved.

//

// This file contains confidential and proprietary information

// of Xilinx, Inc. and is protected under U.S. and

// international copyright and other intellectual property

// laws.

//

// DISCLAIMER

// This disclaimer is not a license and does not grant any

// rights to the materials distributed herewith. Except as

// otherwise provided in a valid license issued to you by

// Xilinx, and to the maximum extent permitted by applicable

// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND

// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES

// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING

// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-

// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and

// (2) Xilinx shall not be liable (whether in contract or tort,

// including negligence, or under any other theory of

// liability) for any loss or damage of any kind or nature

// related to, arising under or in connection with these

// materials, including for any direct, or any indirect,

// special, incidental, or consequential loss or damage

// (including loss of data, profits, goodwill, or any type of

// loss or damage suffered as a result of any action brought

// by a third party) even if such damage or loss was

// reasonably foreseeable or Xilinx had been advised of the

// possibility of the same.

//

// CRITICAL APPLICATIONS

// Xilinx products are not designed or intended to be fail-

// safe, or for use in any application requiring fail-safe

// performance, such as life-support or safety devices or

// systems, Class III medical devices, nuclear facilities,

// applications related to the deployment of airbags, or any

// other applications that could lead to death, personal

// injury, or severe property or environmental damage

// (individually and collectively, "Critical

// Applications"). Customer assumes the sole risk and

// liability of any use of Xilinx products in Critical

// Applications, subject only to applicable laws and

// regulations governing limitations on product liability.

//

// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS

// PART OF THIS FILE AT ALL TIMES.

//

//*****************************************************************************

//   ____  ____

//  /   /\/   /

// /___/  \  /    Vendor             : Xilinx

// \   \   \/     Version            : 4.2

//  \   \         Application        : MIG

//  /   /         Filename           : mig_7series_0.v

// /___/   /\     Date Last Modified : $Date: 2011/06/02 08:35:03 $

// \   \  /  \    Date Created       : Wed Feb 01 2012

//  \___\/\___\

//

// Device           : 7 Series

// Design Name      : DDR3 SDRAM

// Purpose          :

//   Wrapper module for the user design top level file. This module can be 

//   instantiated in the system and interconnect as shown in example design 

//   (example_top module).

// Revision History :

//*****************************************************************************

//`define SKIP_CALIB

`timescale 1ps/1ps



module mig_7series_0 (

  // Inouts

  inout [7:0]       c0_ddr3_dq,

  inout [0:0]        c0_ddr3_dqs_n,

  inout [0:0]        c0_ddr3_dqs_p,

  // Outputs

  output [13:0]     c0_ddr3_addr,

  output [2:0]        c0_ddr3_ba,

  output            c0_ddr3_ras_n,

  output            c0_ddr3_cas_n,

  output            c0_ddr3_we_n,

  output            c0_ddr3_reset_n,

  output [0:0]       c0_ddr3_ck_p,

  output [0:0]       c0_ddr3_ck_n,

  output [0:0]       c0_ddr3_cke,

  output [0:0]        c0_ddr3_cs_n,

  output [0:0]     c0_ddr3_dm,

  output [0:0]       c0_ddr3_odt,

  // Inputs

  // Differential system clocks

  input             c0_sys_clk_p,

  input             c0_sys_clk_n,

  // differential iodelayctrl clk (reference clock)

  input             clk_ref_p,

  input             clk_ref_n,

  // user interface signals

  input [27:0]       c0_app_addr,

  input [2:0]       c0_app_cmd,

  input             c0_app_en,

  input [63:0]        c0_app_wdf_data,

  input             c0_app_wdf_end,

  input [7:0]        c0_app_wdf_mask,

  input             c0_app_wdf_wren,

  output [63:0]       c0_app_rd_data,

  output            c0_app_rd_data_end,

  output            c0_app_rd_data_valid,

  output            c0_app_rdy,

  output            c0_app_wdf_rdy,

  input         c0_app_sr_req,

  input         c0_app_ref_req,

  input         c0_app_zq_req,

  output            c0_app_sr_active,

  output            c0_app_ref_ack,

  output            c0_app_zq_ack,

  output            c0_ui_clk,

  output            c0_ui_clk_sync_rst,

  // debug signals

  output [390:0]                               c0_ddr3_ila_wrpath,

  output [1023:0]                              c0_ddr3_ila_rdpath,

  output [119:0]                               c0_ddr3_ila_basic,

  input [13:0]                                 c0_ddr3_vio_sync_out, // input from VIO

  input [1:0]          c0_dbg_byte_sel,

  input         c0_dbg_sel_pi_incdec,

  input         c0_dbg_pi_f_inc,

  input         c0_dbg_pi_f_dec,

  input         c0_dbg_sel_po_incdec,

  input         c0_dbg_po_f_inc,

  input         c0_dbg_po_f_dec,

  input         c0_dbg_po_f_stg23_sel,

  output [5:0]          c0_dbg_pi_counter_read_val,

  output [8:0]          c0_dbg_po_counter_read_val,

  output [107:0]                    c0_dbg_prbs_final_dqs_tap_cnt_r,

  output [107:0]                    c0_dbg_prbs_first_edge_taps,

  output [107:0]                    c0_dbg_prbs_second_edge_taps,

  output            c0_init_calib_complete,

  output [11:0]                                c0_device_temp,

`ifdef SKIP_CALIB

   output                                      c0_calib_tap_req,

   input                                       c0_calib_tap_load,

   input [6:0]                                 c0_calib_tap_addr,

   input [7:0]                                 c0_calib_tap_val,

   input                                       c0_calib_tap_load_done,

`endif

    // Inouts

  inout [7:0]       c1_ddr3_dq,

  inout [0:0]        c1_ddr3_dqs_n,

  inout [0:0]        c1_ddr3_dqs_p,

  // Outputs

  output [13:0]     c1_ddr3_addr,

  output [2:0]        c1_ddr3_ba,

  output            c1_ddr3_ras_n,

  output            c1_ddr3_cas_n,

  output            c1_ddr3_we_n,

  output            c1_ddr3_reset_n,

  output [0:0]       c1_ddr3_ck_p,

  output [0:0]       c1_ddr3_ck_n,

  output [0:0]       c1_ddr3_cke,

  output [0:0]        c1_ddr3_cs_n,

  output [0:0]     c1_ddr3_dm,

  output [0:0]       c1_ddr3_odt,

  // Inputs

  // Differential system clocks

  input             c1_sys_clk_p,

  input             c1_sys_clk_n,

  // user interface signals

  input [27:0]       c1_app_addr,

  input [2:0]       c1_app_cmd,

  input             c1_app_en,

  input [63:0]        c1_app_wdf_data,

  input             c1_app_wdf_end,

  input [7:0]        c1_app_wdf_mask,

  input             c1_app_wdf_wren,

  output [63:0]       c1_app_rd_data,

  output            c1_app_rd_data_end,

  output            c1_app_rd_data_valid,

  output            c1_app_rdy,

  output            c1_app_wdf_rdy,

  input         c1_app_sr_req,

  input         c1_app_ref_req,

  input         c1_app_zq_req,

  output            c1_app_sr_active,

  output            c1_app_ref_ack,

  output            c1_app_zq_ack,

  output            c1_ui_clk,

  output            c1_ui_clk_sync_rst,

  output            c1_init_calib_complete,

  output [11:0]                                c1_device_temp,

`ifdef SKIP_CALIB

   output                                      c1_calib_tap_req,

   input                                       c1_calib_tap_load,

   input [6:0]                                 c1_calib_tap_addr,

   input [7:0]                                 c1_calib_tap_val,

   input                                       c1_calib_tap_load_done,

`endif

  

  input			sys_rst

  );



// Start of IP top instance

  mig_7series_0_mig u_mig_7series_0_mig (



    // Memory interface ports

    .c0_ddr3_addr                      (c0_ddr3_addr),

    .c0_ddr3_ba                        (c0_ddr3_ba),

    .c0_ddr3_cas_n                     (c0_ddr3_cas_n),

    .c0_ddr3_ck_n                      (c0_ddr3_ck_n),

    .c0_ddr3_ck_p                      (c0_ddr3_ck_p),

    .c0_ddr3_cke                       (c0_ddr3_cke),

    .c0_ddr3_ras_n                     (c0_ddr3_ras_n),

    .c0_ddr3_reset_n                   (c0_ddr3_reset_n),

    .c0_ddr3_we_n                      (c0_ddr3_we_n),

    .c0_ddr3_dq                        (c0_ddr3_dq),

    .c0_ddr3_dqs_n                     (c0_ddr3_dqs_n),

    .c0_ddr3_dqs_p                     (c0_ddr3_dqs_p),

    .c0_init_calib_complete            (c0_init_calib_complete),

      

    .c0_ddr3_cs_n                      (c0_ddr3_cs_n),

    .c0_ddr3_dm                        (c0_ddr3_dm),

    .c0_ddr3_odt                       (c0_ddr3_odt),

    // Application interface ports

    .c0_app_addr                       (c0_app_addr),

    .c0_app_cmd                        (c0_app_cmd),

    .c0_app_en                         (c0_app_en),

    .c0_app_wdf_data                   (c0_app_wdf_data),

    .c0_app_wdf_end                    (c0_app_wdf_end),

    .c0_app_wdf_wren                   (c0_app_wdf_wren),

    .c0_app_rd_data                    (c0_app_rd_data),

    .c0_app_rd_data_end                (c0_app_rd_data_end),

    .c0_app_rd_data_valid              (c0_app_rd_data_valid),

    .c0_app_rdy                        (c0_app_rdy),

    .c0_app_wdf_rdy                    (c0_app_wdf_rdy),

    .c0_app_sr_req                     (c0_app_sr_req),

    .c0_app_ref_req                    (c0_app_ref_req),

    .c0_app_zq_req                     (c0_app_zq_req),

    .c0_app_sr_active                  (c0_app_sr_active),

    .c0_app_ref_ack                    (c0_app_ref_ack),

    .c0_app_zq_ack                     (c0_app_zq_ack),

    .c0_ui_clk                         (c0_ui_clk),

    .c0_ui_clk_sync_rst                (c0_ui_clk_sync_rst),

    .c0_app_wdf_mask                   (c0_app_wdf_mask),

    // Debug Ports

    .c0_ddr3_ila_basic                 (c0_ddr3_ila_basic),

    .c0_ddr3_ila_wrpath                (c0_ddr3_ila_wrpath),

    .c0_ddr3_ila_rdpath                (c0_ddr3_ila_rdpath),

    .c0_ddr3_vio_sync_out              (c0_ddr3_vio_sync_out),

    .c0_dbg_pi_counter_read_val        (c0_dbg_pi_counter_read_val),

    .c0_dbg_sel_pi_incdec              (c0_dbg_sel_pi_incdec),

    .c0_dbg_po_counter_read_val        (c0_dbg_po_counter_read_val),

    .c0_dbg_sel_po_incdec              (c0_dbg_sel_po_incdec),

    .c0_dbg_byte_sel                   (c0_dbg_byte_sel),

    .c0_dbg_pi_f_inc                   (c0_dbg_pi_f_inc),

    .c0_dbg_pi_f_dec                   (c0_dbg_pi_f_dec),

    .c0_dbg_po_f_inc                   (c0_dbg_po_f_inc),

    .c0_dbg_po_f_stg23_sel             (c0_dbg_po_f_stg23_sel),

    .c0_dbg_po_f_dec                   (c0_dbg_po_f_dec),

    .c0_dbg_prbs_final_dqs_tap_cnt_r   (c0_dbg_prbs_final_dqs_tap_cnt_r),

    .c0_dbg_prbs_first_edge_taps       (c0_dbg_prbs_first_edge_taps),

    .c0_dbg_prbs_second_edge_taps      (c0_dbg_prbs_second_edge_taps),

    // System Clock Ports

    .c0_sys_clk_p                       (c0_sys_clk_p),

    .c0_sys_clk_n                       (c0_sys_clk_n),

    // Reference Clock Ports

    .clk_ref_p                      (clk_ref_p),

    .clk_ref_n                      (clk_ref_n),

       .c0_device_temp            (c0_device_temp),

       `ifdef SKIP_CALIB

       .c0_calib_tap_req                    (c0_calib_tap_req),

       .c0_calib_tap_load                   (c0_calib_tap_load),

       .c0_calib_tap_addr                   (c0_calib_tap_addr),

       .c0_calib_tap_val                    (c0_calib_tap_val),

       .c0_calib_tap_load_done              (c0_calib_tap_load_done),

       `endif

    // Memory interface ports

    .c1_ddr3_addr                      (c1_ddr3_addr),

    .c1_ddr3_ba                        (c1_ddr3_ba),

    .c1_ddr3_cas_n                     (c1_ddr3_cas_n),

    .c1_ddr3_ck_n                      (c1_ddr3_ck_n),

    .c1_ddr3_ck_p                      (c1_ddr3_ck_p),

    .c1_ddr3_cke                       (c1_ddr3_cke),

    .c1_ddr3_ras_n                     (c1_ddr3_ras_n),

    .c1_ddr3_reset_n                   (c1_ddr3_reset_n),

    .c1_ddr3_we_n                      (c1_ddr3_we_n),

    .c1_ddr3_dq                        (c1_ddr3_dq),

    .c1_ddr3_dqs_n                     (c1_ddr3_dqs_n),

    .c1_ddr3_dqs_p                     (c1_ddr3_dqs_p),

    .c1_init_calib_complete            (c1_init_calib_complete),

      

    .c1_ddr3_cs_n                      (c1_ddr3_cs_n),

    .c1_ddr3_dm                        (c1_ddr3_dm),

    .c1_ddr3_odt                       (c1_ddr3_odt),

    // Application interface ports

    .c1_app_addr                       (c1_app_addr),

    .c1_app_cmd                        (c1_app_cmd),

    .c1_app_en                         (c1_app_en),

    .c1_app_wdf_data                   (c1_app_wdf_data),

    .c1_app_wdf_end                    (c1_app_wdf_end),

    .c1_app_wdf_wren                   (c1_app_wdf_wren),

    .c1_app_rd_data                    (c1_app_rd_data),

    .c1_app_rd_data_end                (c1_app_rd_data_end),

    .c1_app_rd_data_valid              (c1_app_rd_data_valid),

    .c1_app_rdy                        (c1_app_rdy),

    .c1_app_wdf_rdy                    (c1_app_wdf_rdy),

    .c1_app_sr_req                     (c1_app_sr_req),

    .c1_app_ref_req                    (c1_app_ref_req),

    .c1_app_zq_req                     (c1_app_zq_req),

    .c1_app_sr_active                  (c1_app_sr_active),

    .c1_app_ref_ack                    (c1_app_ref_ack),

    .c1_app_zq_ack                     (c1_app_zq_ack),

    .c1_ui_clk                         (c1_ui_clk),

    .c1_ui_clk_sync_rst                (c1_ui_clk_sync_rst),

    .c1_app_wdf_mask                   (c1_app_wdf_mask),

    // System Clock Ports

    .c1_sys_clk_p                       (c1_sys_clk_p),

    .c1_sys_clk_n                       (c1_sys_clk_n),

       .c1_device_temp            (c1_device_temp),

       `ifdef SKIP_CALIB

       .c1_calib_tap_req                    (c1_calib_tap_req),

       .c1_calib_tap_load                   (c1_calib_tap_load),

       .c1_calib_tap_addr                   (c1_calib_tap_addr),

       .c1_calib_tap_val                    (c1_calib_tap_val),

       .c1_calib_tap_load_done              (c1_calib_tap_load_done),

       `endif

    .sys_rst                        (sys_rst)

    );

// End of IP top instance



endmodule




