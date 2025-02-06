//*****************************************************************************

// (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.

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

//  /   /         Filename           : mig_7series_0_mig.v

// /___/   /\     Date Last Modified : $Date: 2011/06/02 08:35:03 $

// \   \  /  \    Date Created       : Tue Sept 21 2010

//  \___\/\___\

//

// Device           : 7 Series

// Design Name      : DDR3 SDRAM

// Purpose          :

//   Top-level  module. This module can be instantiated in the

//   system and interconnect as shown in user design wrapper file (user top module).

//   In addition to the memory controller, the module instantiates:

//     1. Clock generation/distribution, reset logic

//     2. IDELAY control block

//     3. Debug logic

// Reference        :

// Revision History :

//*****************************************************************************



//`define SKIP_CALIB

`timescale 1ps/1ps



module mig_7series_0_mig #

  (



   //***************************************************************************

   // The following parameters refer to width of various ports

   //***************************************************************************

   parameter C0_BANK_WIDTH            = 3,

                                     // # of memory Bank Address bits.

   parameter C0_CK_WIDTH              = 1,

                                     // # of CK/CK# outputs to memory.

   parameter C0_COL_WIDTH             = 10,

                                     // # of memory Column Address bits.

   parameter C0_CS_WIDTH              = 1,

                                     // # of unique CS outputs to memory.

   parameter C0_nCS_PER_RANK          = 1,

                                     // # of unique CS outputs per rank for phy

   parameter C0_CKE_WIDTH             = 1,

                                     // # of CKE outputs to memory.

   parameter C0_DATA_BUF_ADDR_WIDTH   = 5,

   parameter C0_DQ_CNT_WIDTH          = 3,

                                     // = ceil(log2(DQ_WIDTH))

   parameter C0_DQ_PER_DM             = 8,

   parameter C0_DM_WIDTH              = 1,

                                     // # of DM (data mask)

   parameter C0_DQ_WIDTH              = 8,

                                     // # of DQ (data)

   parameter C0_DQS_WIDTH             = 1,

   parameter C0_DQS_CNT_WIDTH         = 1,

                                     // = ceil(log2(DQS_WIDTH))

   parameter C0_DRAM_WIDTH            = 8,

                                     // # of DQ per DQS

   parameter C0_ECC                   = "OFF",

   parameter C0_DATA_WIDTH            = 8,

   parameter C0_ECC_TEST              = "OFF",

   parameter C0_PAYLOAD_WIDTH         = (C0_ECC_TEST == "OFF") ? C0_DATA_WIDTH : C0_DQ_WIDTH,

   parameter C0_MEM_ADDR_ORDER        = "BANK_ROW_COLUMN",

                                      //Possible Parameters

                                      //1.BANK_ROW_COLUMN : Address mapping is

                                      //                    in form of Bank Row Column.

                                      //2.ROW_BANK_COLUMN : Address mapping is

                                      //                    in the form of Row Bank Column.

                                      //3.TG_TEST : Scrambles Address bits

                                      //            for distributed Addressing.

      

   //parameter C0_nBANK_MACHS           = 4,

   parameter C0_nBANK_MACHS           = 8,

   parameter C0_RANKS                 = 1,

                                     // # of Ranks.

   parameter C0_ODT_WIDTH             = 1,

                                     // # of ODT outputs to memory.

   parameter C0_ROW_WIDTH             = 14,

                                     // # of memory Row Address bits.

   parameter C0_ADDR_WIDTH            = 28,

                                     // # = RANK_WIDTH + BANK_WIDTH

                                     //     + ROW_WIDTH + COL_WIDTH;

                                     // Chip Select is always tied to low for

                                     // single rank devices

   parameter C0_USE_CS_PORT          = 1,

                                     // # = 1, When Chip Select (CS#) output is enabled

                                     //   = 0, When Chip Select (CS#) output is disabled

                                     // If CS_N disabled, user must connect

                                     // DRAM CS_N input(s) to ground

   parameter C0_USE_DM_PORT           = 1,

                                     // # = 1, When Data Mask option is enabled

                                     //   = 0, When Data Mask option is disbaled

                                     // When Data Mask option is disabled in

                                     // MIG Controller Options page, the logic

                                     // related to Data Mask should not get

                                     // synthesized

   parameter C0_USE_ODT_PORT          = 1,

                                     // # = 1, When ODT output is enabled

                                     //   = 0, When ODT output is disabled

                                     // Parameter configuration for Dynamic ODT support:

                                     // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".

                                     // This configuration allows to save ODT pin mapping from FPGA.

                                     // The user can tie the ODT input of DRAM to HIGH.

   parameter C0_IS_CLK_SHARED          = "FALSE",

                                      // # = "true" when clock is shared

                                      //   = "false" when clock is not shared



   parameter C0_PHY_CONTROL_MASTER_BANK = 0,

                                     // The bank index where master PHY_CONTROL resides,

                                     // equal to the PLL residing bank

   parameter C0_MEM_DENSITY           = "1Gb",

                                     // Indicates the density of the Memory part

                                     // Added for the sake of Vivado simulations

   parameter C0_MEM_SPEEDGRADE        = "125",

                                     // Indicates the Speed grade of Memory Part

                                     // Added for the sake of Vivado simulations

   parameter C0_MEM_DEVICE_WIDTH      = 8,

                                     // Indicates the device width of the Memory Part

                                     // Added for the sake of Vivado simulations



   //***************************************************************************

   // The following parameters are mode register settings

   //***************************************************************************

   parameter C0_AL                    = "0",

                                     // DDR3 SDRAM:

                                     // Additive Latency (Mode Register 1).

                                     // # = "0", "CL-1", "CL-2".

                                     // DDR2 SDRAM:

                                     // Additive Latency (Extended Mode Register).

   parameter C0_nAL                   = 0,

                                     // # Additive Latency in number of clock

                                     // cycles.

   parameter C0_BURST_MODE            = "8",

                                     // DDR3 SDRAM:

                                     // Burst Length (Mode Register 0).

                                     // # = "8", "4", "OTF".

                                     // DDR2 SDRAM:

                                     // Burst Length (Mode Register).

                                     // # = "8", "4".

   parameter C0_BURST_TYPE            = "SEQ",

                                     // DDR3 SDRAM: Burst Type (Mode Register 0).

                                     // DDR2 SDRAM: Burst Type (Mode Register).

                                     // # = "SEQ" - (Sequential),

                                     //   = "INT" - (Interleaved).

   parameter C0_CL                    = 5,

                                     // in number of clock cycles

                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).

                                     // DDR2 SDRAM: CAS Latency (Mode Register).

   parameter C0_CWL                   = 5,

                                     // in number of clock cycles

                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).

                                     // DDR2 SDRAM: Can be ignored

   parameter C0_OUTPUT_DRV            = "LOW",

                                     // Output Driver Impedance Control (Mode Register 1).

                                     // # = "HIGH" - RZQ/7,

                                     //   = "LOW" - RZQ/6.

   parameter C0_RTT_NOM               = "40",

                                     // RTT_NOM (ODT) (Mode Register 1).

                                     //   = "120" - RZQ/2,

                                     //   = "60"  - RZQ/4,

                                     //   = "40"  - RZQ/6.

   parameter C0_RTT_WR                = "OFF",

                                     // RTT_WR (ODT) (Mode Register 2).

                                     // # = "OFF" - Dynamic ODT off,

                                     //   = "120" - RZQ/2,

                                     //   = "60"  - RZQ/4,

   parameter C0_ADDR_CMD_MODE         = "1T" ,

                                     // # = "1T", "2T".

   parameter C0_REG_CTRL              = "OFF",

                                     // # = "ON" - RDIMMs,

                                     //   = "OFF" - Components, SODIMMs, UDIMMs.

   parameter C0_CA_MIRROR             = "OFF",

                                     // C/A mirror opt for DDR3 dual rank



   parameter C0_VDD_OP_VOLT           = "150",

                                     // # = "150" - 1.5V Vdd Memory part

                                     //   = "135" - 1.35V Vdd Memory part



   

   //***************************************************************************

   // The following parameters are multiplier and divisor factors for PLLE2.

   // Based on the selected design frequency these parameters vary.

   //***************************************************************************

   parameter C0_CLKIN_PERIOD          = 1290,

                                     // Input Clock Period

   parameter C0_CLKFBOUT_MULT         = 8,

                                     // write PLL VCO multiplier

   parameter C0_DIVCLK_DIVIDE         = 5,

                                     // write PLL VCO divisor

   parameter C0_CLKOUT0_PHASE         = 0.0,

                                     // Phase for PLL output clock (CLKOUT0)

   parameter C0_CLKOUT0_DIVIDE        = 2,

                                     // VCO output divisor for PLL output clock (CLKOUT0)

   parameter C0_CLKOUT1_DIVIDE        = 4,

                                     // VCO output divisor for PLL output clock (CLKOUT1)

   parameter C0_CLKOUT2_DIVIDE        = 64,

                                     // VCO output divisor for PLL output clock (CLKOUT2)

   parameter C0_CLKOUT3_DIVIDE        = 16,

                                     // VCO output divisor for PLL output clock (CLKOUT3)

   parameter C0_MMCM_VCO              = 620,

                                     // Max Freq (MHz) of MMCM VCO

   parameter C0_MMCM_MULT_F           = 8,

                                     // write MMCM VCO multiplier

   parameter C0_MMCM_DIVCLK_DIVIDE    = 1,

                                     // write MMCM VCO divisor



   //***************************************************************************

   // Memory Timing Parameters. These parameters varies based on the selected

   // memory part.

   //***************************************************************************

   parameter C0_tCKE                  = 5000,

                                     // memory tCKE paramter in pS

   parameter C0_tFAW                  = 30000,

                                     // memory tRAW paramter in pS.

   parameter C0_tPRDI                 = 1_000_000,

                                     // memory tPRDI paramter in pS.

   parameter C0_tRAS                  = 35000,

                                     // memory tRAS paramter in pS.

   parameter C0_tRCD                  = 13750,

                                     // memory tRCD paramter in pS.

   parameter C0_tREFI                 = 7800000,

                                     // memory tREFI paramter in pS.

   parameter C0_tRFC                  = 110000,

                                     // memory tRFC paramter in pS.

   parameter C0_tRP                   = 13750,

                                     // memory tRP paramter in pS.

   parameter C0_tRRD                  = 6000,

                                     // memory tRRD paramter in pS.

   parameter C0_tRTP                  = 7500,

                                     // memory tRTP paramter in pS.

   parameter C0_tWTR                  = 7500,

                                     // memory tWTR paramter in pS.

   parameter C0_tZQI                  = 128_000_000,

                                     // memory tZQI paramter in nS.

   parameter C0_tZQCS                 = 64,//64,

                                     // memory tZQCS paramter in clock cycles.



   //***************************************************************************

   // Simulation parameters

   //***************************************************************************

   parameter C0_SIM_BYPASS_INIT_CAL   = "OFF",

                                     // # = "OFF" -  Complete memory init &

                                     //              calibration sequence

                                     // # = "SKIP" - Not supported

                                     // # = "FAST" - Complete memory init & use

                                     //              abbreviated calib sequence



   parameter C0_SIMULATION            = "FALSE",

                                     // Should be TRUE during design simulations and

                                     // FALSE during implementations



   //***************************************************************************

   // The following parameters varies based on the pin out entered in MIG GUI.

   // Do not change any of these parameters directly by editing the RTL.

   // Any changes required should be done through GUI and the design regenerated.

   //***************************************************************************

   parameter C0_BYTE_LANES_B0         = 4'b1111,

                                     // Byte lanes used in an IO column.

   parameter C0_BYTE_LANES_B1         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C0_BYTE_LANES_B2         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C0_BYTE_LANES_B3         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C0_BYTE_LANES_B4         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C0_DATA_CTL_B0           = 4'b0001,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C0_DATA_CTL_B1           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C0_DATA_CTL_B2           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C0_DATA_CTL_B3           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C0_DATA_CTL_B4           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C0_PHY_0_BITLANES        = 48'h3FE_FFF_C00_2FF,

   parameter C0_PHY_1_BITLANES        = 48'h000_000_000_000,

   parameter C0_PHY_2_BITLANES        = 48'h000_000_000_000,



   // control/address/data pin mapping parameters

   parameter C0_CK_BYTE_MAP

     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_03,

   parameter C0_ADDR_MAP

     = 192'h000_000_039_038_037_036_035_034_033_032_031_029_028_027_026_02B,

   parameter C0_BANK_MAP   = 36'h02A_025_024,

   parameter C0_CAS_MAP    = 12'h022,

   parameter C0_CKE_ODT_BYTE_MAP = 8'h00,

   parameter C0_CKE_MAP    = 96'h000_000_000_000_000_000_000_01B,

   parameter C0_ODT_MAP    = 96'h000_000_000_000_000_000_000_01A,

   parameter C0_CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_020,

   parameter C0_PARITY_MAP = 12'h000,

   parameter C0_RAS_MAP    = 12'h023,

   parameter C0_WE_MAP     = 12'h021,

   parameter C0_DQS_BYTE_MAP

     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00,

   parameter C0_DATA0_MAP  = 96'h000_001_002_003_004_005_006_007,

   parameter C0_DATA1_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA2_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA3_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA4_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA5_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA6_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA7_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA8_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA9_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA10_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA11_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA12_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA13_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA14_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA15_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA16_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_DATA17_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C0_MASK0_MAP  = 108'h000_000_000_000_000_000_000_000_009,

   parameter C0_MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000,



   parameter C0_SLOT_0_CONFIG         = 8'b0000_0001,

                                     // Mapping of Ranks.

   parameter C0_SLOT_1_CONFIG         = 8'b0000_0000,

                                     // Mapping of Ranks.



   //***************************************************************************

   // IODELAY and PHY related parameters

   //***************************************************************************

   parameter C0_IBUF_LPWR_MODE        = "OFF",

                                     // to phy_top

   parameter C0_DATA_IO_IDLE_PWRDWN   = "ON",

                                     // # = "ON", "OFF"

   parameter C0_BANK_TYPE             = "HR_IO",

                                     // # = "HP_IO", "HPL_IO", "HR_IO", "HRL_IO"

   parameter C0_DATA_IO_PRIM_TYPE     = "HR_LP",

                                     // # = "HP_LP", "HR_LP", "DEFAULT"

   parameter C0_CKE_ODT_AUX           = "FALSE",

   parameter C0_USER_REFRESH          = "OFF",

   parameter C0_WRLVL                 = "ON",

                                     // # = "ON" - DDR3 SDRAM

                                     //   = "OFF" - DDR2 SDRAM.

   parameter C0_ORDERING              = "STRICT",

                                     // # = "NORM", "STRICT", "RELAXED".

   parameter C0_CALIB_ROW_ADD         = 16'h0000,

                                     // Calibration row address will be used for

                                     // calibration read and write operations

   parameter C0_CALIB_COL_ADD         = 12'h000,

                                     // Calibration column address will be used for

                                     // calibration read and write operations

   parameter C0_CALIB_BA_ADD          = 3'h0,

                                     // Calibration bank address will be used for

                                     // calibration read and write operations

   parameter C0_TCQ                   = 100,

   parameter C0_IDELAY_ADJ            = "OFF",

   parameter C0_FINE_PER_BIT          = "OFF",

   parameter C0_CENTER_COMP_MODE      = "OFF",

   parameter C0_PI_VAL_ADJ            = "OFF",

   parameter IODELAY_GRP0          = "MIG_7SERIES_0_IODELAY_MIG0",

                                     // It is associated to a set of IODELAYs with

                                     // an IDELAYCTRL that have same IODELAY CONTROLLER

                                     // clock frequency (200MHz).

   parameter IODELAY_GRP1          = "MIG_7SERIES_0_IODELAY_MIG1",

                                     // It is associated to a set of IODELAYs with

                                     // an IDELAYCTRL that have same IODELAY CONTROLLER

                                     // clock frequency (300MHz/400MHz).

   parameter SYSCLK_TYPE           = "DIFFERENTIAL",

                                     // System clock type DIFFERENTIAL, SINGLE_ENDED,

                                     // NO_BUFFER

   parameter REFCLK_TYPE           = "DIFFERENTIAL",

                                     // Reference clock type DIFFERENTIAL, SINGLE_ENDED,

                                     // NO_BUFFER, USE_SYSTEM_CLOCK

   parameter SYS_RST_PORT          = "TRUE",

                                     // "TRUE" - if pin is selected for sys_rst

                                     //          and IBUF will be instantiated.

                                     // "FALSE" - if pin is not selected for sys_rst

   parameter FPGA_SPEED_GRADE      = 1,

                                     // FPGA speed grade

      

   parameter C0_CMD_PIPE_PLUS1        = "ON",

                                     // add pipeline stage between MC and PHY

   parameter DRAM_TYPE             = "DDR3",

   parameter CAL_WIDTH             = "HALF",

   parameter STARVE_LIMIT          = 2,

                                     // # = 2,3,4.

   parameter REF_CLK_MMCM_IODELAY_CTRL    = "FALSE",

      



   //***************************************************************************

   // Referece clock frequency parameters

   //***************************************************************************

   parameter REFCLK_FREQ           = 200.0,

                                     // IODELAYCTRL reference clock frequency

   parameter DIFF_TERM_REFCLK      = "TRUE",

                                     // Differential Termination for idelay

                                     // reference clock input pins

   //***************************************************************************

   // System clock frequency parameters

   //***************************************************************************

   parameter C0_tCK                   = 3225,

                                     // memory tCK paramter.

                                     // # = Clock Period in pS.

   parameter C0_nCK_PER_CLK           = 4,

   // # of memory CKs per fabric CLK

   

   parameter C0_DIFF_TERM_SYSCLK      = "FALSE",

                                     // Differential Termination for System

                                     // clock input pins

      



   



   //***************************************************************************

   // Debug parameters

   //***************************************************************************

   parameter C0_DEBUG_PORT            = "ON",

                                     // # = "ON" Enable debug signals/controls.

                                     //   = "OFF" Disable debug signals/controls.



   //***************************************************************************

   // Temparature monitor parameter

   //***************************************************************************

   parameter C0_TEMP_MON_CONTROL      = "INTERNAL",

                                     // # = "INTERNAL", "EXTERNAL"

   //***************************************************************************

   // FPGA Voltage Type parameter

   //***************************************************************************

   parameter C0_FPGA_VOLT_TYPE        = "N",

                                     // # = "L", "N". When FPGA VccINT is 0.9v,

                                     // the value is "L", else it is "N"

      

   //***************************************************************************

   // The following parameters refer to width of various ports

   //***************************************************************************

   parameter C1_BANK_WIDTH            = 3,

                                     // # of memory Bank Address bits.

   parameter C1_CK_WIDTH              = 1,

                                     // # of CK/CK# outputs to memory.

   parameter C1_COL_WIDTH             = 10,

                                     // # of memory Column Address bits.

   parameter C1_CS_WIDTH              = 1,

                                     // # of unique CS outputs to memory.

   parameter C1_nCS_PER_RANK          = 1,

                                     // # of unique CS outputs per rank for phy

   parameter C1_CKE_WIDTH             = 1,

                                     // # of CKE outputs to memory.

   parameter C1_DATA_BUF_ADDR_WIDTH   = 5,

   parameter C1_DQ_CNT_WIDTH          = 3,

                                     // = ceil(log2(DQ_WIDTH))

   parameter C1_DQ_PER_DM             = 8,

   parameter C1_DM_WIDTH              = 1,

                                     // # of DM (data mask)

   parameter C1_DQ_WIDTH              = 8,

                                     // # of DQ (data)

   parameter C1_DQS_WIDTH             = 1,

   parameter C1_DQS_CNT_WIDTH         = 1,

                                     // = ceil(log2(DQS_WIDTH))

   parameter C1_DRAM_WIDTH            = 8,

                                     // # of DQ per DQS

   parameter C1_ECC                   = "OFF",

   parameter C1_DATA_WIDTH            = 8,

   parameter C1_ECC_TEST              = "OFF",

   parameter C1_PAYLOAD_WIDTH         = (C1_ECC_TEST == "OFF") ? C1_DATA_WIDTH : C1_DQ_WIDTH,

   parameter C1_MEM_ADDR_ORDER        = "BANK_ROW_COLUMN",

                                      //Possible Parameters

                                      //1.BANK_ROW_COLUMN : Address mapping is

                                      //                    in form of Bank Row Column.

                                      //2.ROW_BANK_COLUMN : Address mapping is

                                      //                    in the form of Row Bank Column.

                                      //3.TG_TEST : Scrambles Address bits

                                      //            for distributed Addressing.

      

   //parameter C1_nBANK_MACHS           = 4,

   parameter C1_nBANK_MACHS           = 4,

   parameter C1_RANKS                 = 1,

                                     // # of Ranks.

   parameter C1_ODT_WIDTH             = 1,

                                     // # of ODT outputs to memory.

   parameter C1_ROW_WIDTH             = 14,

                                     // # of memory Row Address bits.

   parameter C1_ADDR_WIDTH            = 28,

                                     // # = RANK_WIDTH + BANK_WIDTH

                                     //     + ROW_WIDTH + COL_WIDTH;

                                     // Chip Select is always tied to low for

                                     // single rank devices

   parameter C1_USE_CS_PORT          = 1,

                                     // # = 1, When Chip Select (CS#) output is enabled

                                     //   = 0, When Chip Select (CS#) output is disabled

                                     // If CS_N disabled, user must connect

                                     // DRAM CS_N input(s) to ground

   parameter C1_USE_DM_PORT           = 1,

                                     // # = 1, When Data Mask option is enabled

                                     //   = 0, When Data Mask option is disbaled

                                     // When Data Mask option is disabled in

                                     // MIG Controller Options page, the logic

                                     // related to Data Mask should not get

                                     // synthesized

   parameter C1_USE_ODT_PORT          = 1,

                                     // # = 1, When ODT output is enabled

                                     //   = 0, When ODT output is disabled

                                     // Parameter configuration for Dynamic ODT support:

                                     // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".

                                     // This configuration allows to save ODT pin mapping from FPGA.

                                     // The user can tie the ODT input of DRAM to HIGH.

   parameter C1_IS_CLK_SHARED          = "FALSE",

                                      // # = "true" when clock is shared

                                      //   = "false" when clock is not shared



   parameter C1_PHY_CONTROL_MASTER_BANK = 0,

                                     // The bank index where master PHY_CONTROL resides,

                                     // equal to the PLL residing bank

   parameter C1_MEM_DENSITY           = "1Gb",

                                     // Indicates the density of the Memory part

                                     // Added for the sake of Vivado simulations

   parameter C1_MEM_SPEEDGRADE        = "125",

                                     // Indicates the Speed grade of Memory Part

                                     // Added for the sake of Vivado simulations

   parameter C1_MEM_DEVICE_WIDTH      = 8,

                                     // Indicates the device width of the Memory Part

                                     // Added for the sake of Vivado simulations



   //***************************************************************************

   // The following parameters are mode register settings

   //***************************************************************************

   parameter C1_AL                    = "0",

                                     // DDR3 SDRAM:

                                     // Additive Latency (Mode Register 1).

                                     // # = "0", "CL-1", "CL-2".

                                     // DDR2 SDRAM:

                                     // Additive Latency (Extended Mode Register).

   parameter C1_nAL                   = 0,

                                     // # Additive Latency in number of clock

                                     // cycles.

   parameter C1_BURST_MODE            = "8",

                                     // DDR3 SDRAM:

                                     // Burst Length (Mode Register 0).

                                     // # = "8", "4", "OTF".

                                     // DDR2 SDRAM:

                                     // Burst Length (Mode Register).

                                     // # = "8", "4".

   parameter C1_BURST_TYPE            = "SEQ",

                                     // DDR3 SDRAM: Burst Type (Mode Register 0).

                                     // DDR2 SDRAM: Burst Type (Mode Register).

                                     // # = "SEQ" - (Sequential),

                                     //   = "INT" - (Interleaved).

   parameter C1_CL                    = 6,

                                     // in number of clock cycles

                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).

                                     // DDR2 SDRAM: CAS Latency (Mode Register).

   parameter C1_CWL                   = 5,

                                     // in number of clock cycles

                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).

                                     // DDR2 SDRAM: Can be ignored

   parameter C1_OUTPUT_DRV            = "HIGH",

                                     // Output Driver Impedance Control (Mode Register 1).

                                     // # = "HIGH" - RZQ/7,

                                     //   = "LOW" - RZQ/6.

   parameter C1_RTT_NOM               = "60",

                                     // RTT_NOM (ODT) (Mode Register 1).

                                     //   = "120" - RZQ/2,

                                     //   = "60"  - RZQ/4,

                                     //   = "40"  - RZQ/6.

   parameter C1_RTT_WR                = "OFF",

                                     // RTT_WR (ODT) (Mode Register 2).

                                     // # = "OFF" - Dynamic ODT off,

                                     //   = "120" - RZQ/2,

                                     //   = "60"  - RZQ/4,

   parameter C1_ADDR_CMD_MODE         = "1T" ,

                                     // # = "1T", "2T".

   parameter C1_REG_CTRL              = "OFF",

                                     // # = "ON" - RDIMMs,

                                     //   = "OFF" - Components, SODIMMs, UDIMMs.

   parameter C1_CA_MIRROR             = "OFF",

                                     // C/A mirror opt for DDR3 dual rank



   parameter C1_VDD_OP_VOLT           = "150",

                                     // # = "150" - 1.5V Vdd Memory part

                                     //   = "135" - 1.35V Vdd Memory part



   

   //***************************************************************************

   // The following parameters are multiplier and divisor factors for PLLE2.

   // Based on the selected design frequency these parameters vary.

   //***************************************************************************

   parameter C1_CLKIN_PERIOD          = 1935,

                                     // Input Clock Period

   parameter C1_CLKFBOUT_MULT         = 13,

                                     // write PLL VCO multiplier

   parameter C1_DIVCLK_DIVIDE         = 5,

                                     // write PLL VCO divisor

   parameter C1_CLKOUT0_PHASE         = 0.0,

                                     // Phase for PLL output clock (CLKOUT0)

   parameter C1_CLKOUT0_DIVIDE        = 2,

                                     // VCO output divisor for PLL output clock (CLKOUT0)

   parameter C1_CLKOUT1_DIVIDE        = 4,

                                     // VCO output divisor for PLL output clock (CLKOUT1)

   parameter C1_CLKOUT2_DIVIDE        = 64,

                                     // VCO output divisor for PLL output clock (CLKOUT2)

   parameter C1_CLKOUT3_DIVIDE        = 16,

                                     // VCO output divisor for PLL output clock (CLKOUT3)

   parameter C1_MMCM_VCO              = 671,

                                     // Max Freq (MHz) of MMCM VCO

   parameter C1_MMCM_MULT_F           = 8,

                                     // write MMCM VCO multiplier

   parameter C1_MMCM_DIVCLK_DIVIDE    = 1,

                                     // write MMCM VCO divisor



   //***************************************************************************

   // Memory Timing Parameters. These parameters varies based on the selected

   // memory part.

   //***************************************************************************

   parameter C1_tCKE                  = 5000,

                                     // memory tCKE paramter in pS

   parameter C1_tFAW                  = 30000,

                                     // memory tRAW paramter in pS.

   parameter C1_tPRDI                 = 1_000_000,

                                     // memory tPRDI paramter in pS.

   parameter C1_tRAS                  = 35000,

                                     // memory tRAS paramter in pS.

   parameter C1_tRCD                  = 13750,

                                     // memory tRCD paramter in pS.

   parameter C1_tREFI                 = 7800000,

                                     // memory tREFI paramter in pS.

   parameter C1_tRFC                  = 110000,

                                     // memory tRFC paramter in pS.

   parameter C1_tRP                   = 13750,

                                     // memory tRP paramter in pS.

   parameter C1_tRRD                  = 6000,

                                     // memory tRRD paramter in pS.

   parameter C1_tRTP                  = 7500,

                                     // memory tRTP paramter in pS.

   parameter C1_tWTR                  = 7500,

                                     // memory tWTR paramter in pS.

   parameter C1_tZQI                  = 128_000_000,

                                     // memory tZQI paramter in nS.

   parameter C1_tZQCS                 = 64,//64,

                                     // memory tZQCS paramter in clock cycles.



   //***************************************************************************

   // Simulation parameters

   //***************************************************************************

   parameter C1_SIM_BYPASS_INIT_CAL   = "OFF",

                                     // # = "OFF" -  Complete memory init &

                                     //              calibration sequence

                                     // # = "SKIP" - Not supported

                                     // # = "FAST" - Complete memory init & use

                                     //              abbreviated calib sequence



   parameter C1_SIMULATION            = "FALSE",

                                     // Should be TRUE during design simulations and

                                     // FALSE during implementations



   //***************************************************************************

   // The following parameters varies based on the pin out entered in MIG GUI.

   // Do not change any of these parameters directly by editing the RTL.

   // Any changes required should be done through GUI and the design regenerated.

   //***************************************************************************

   parameter C1_BYTE_LANES_B0         = 4'b1111,

                                     // Byte lanes used in an IO column.

   parameter C1_BYTE_LANES_B1         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C1_BYTE_LANES_B2         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C1_BYTE_LANES_B3         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C1_BYTE_LANES_B4         = 4'b0000,

                                     // Byte lanes used in an IO column.

   parameter C1_DATA_CTL_B0           = 4'b0001,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C1_DATA_CTL_B1           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C1_DATA_CTL_B2           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C1_DATA_CTL_B3           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C1_DATA_CTL_B4           = 4'b0000,

                                     // Indicates Byte lane is data byte lane

                                     // or control Byte lane. '1' in a bit

                                     // position indicates a data byte lane and

                                     // a '0' indicates a control byte lane

   parameter C1_PHY_0_BITLANES        = 48'h3FE_FFF_C00_2FF,

   parameter C1_PHY_1_BITLANES        = 48'h000_000_000_000,

   parameter C1_PHY_2_BITLANES        = 48'h000_000_000_000,



   // control/address/data pin mapping parameters

   parameter C1_CK_BYTE_MAP

     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_03,

   parameter C1_ADDR_MAP

     = 192'h000_000_039_038_037_036_035_034_033_032_031_029_028_027_026_02B,

   parameter C1_BANK_MAP   = 36'h02A_025_024,

   parameter C1_CAS_MAP    = 12'h022,

   parameter C1_CKE_ODT_BYTE_MAP = 8'h00,

   parameter C1_CKE_MAP    = 96'h000_000_000_000_000_000_000_01B,

   parameter C1_ODT_MAP    = 96'h000_000_000_000_000_000_000_01A,

   parameter C1_CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_020,

   parameter C1_PARITY_MAP = 12'h000,

   parameter C1_RAS_MAP    = 12'h023,

   parameter C1_WE_MAP     = 12'h021,

   parameter C1_DQS_BYTE_MAP

     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00,

   parameter C1_DATA0_MAP  = 96'h000_001_002_003_004_005_006_007,

   parameter C1_DATA1_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA2_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA3_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA4_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA5_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA6_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA7_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA8_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA9_MAP  = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA10_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA11_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA12_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA13_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA14_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA15_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA16_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_DATA17_MAP = 96'h000_000_000_000_000_000_000_000,

   parameter C1_MASK0_MAP  = 108'h000_000_000_000_000_000_000_000_009,

   parameter C1_MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000,



   parameter C1_SLOT_0_CONFIG         = 8'b0000_0001,

                                     // Mapping of Ranks.

   parameter C1_SLOT_1_CONFIG         = 8'b0000_0000,

                                     // Mapping of Ranks.



   //***************************************************************************

   // IODELAY and PHY related parameters

   //***************************************************************************

   parameter C1_IBUF_LPWR_MODE        = "OFF",

                                     // to phy_top

   parameter C1_DATA_IO_IDLE_PWRDWN   = "ON",

                                     // # = "ON", "OFF"

   parameter C1_BANK_TYPE             = "HR_IO",

                                     // # = "HP_IO", "HPL_IO", "HR_IO", "HRL_IO"

   parameter C1_DATA_IO_PRIM_TYPE     = "HR_LP",

                                     // # = "HP_LP", "HR_LP", "DEFAULT"

   parameter C1_CKE_ODT_AUX           = "FALSE",

   parameter C1_USER_REFRESH          = "OFF",

   parameter C1_WRLVL                 = "ON",

                                     // # = "ON" - DDR3 SDRAM

                                     //   = "OFF" - DDR2 SDRAM.

   parameter C1_ORDERING              = "STRICT",

                                     // # = "NORM", "STRICT", "RELAXED".

   parameter C1_CALIB_ROW_ADD         = 16'h0000,

                                     // Calibration row address will be used for

                                     // calibration read and write operations

   parameter C1_CALIB_COL_ADD         = 12'h000,

                                     // Calibration column address will be used for

                                     // calibration read and write operations

   parameter C1_CALIB_BA_ADD          = 3'h0,

                                     // Calibration bank address will be used for

                                     // calibration read and write operations

   parameter C1_TCQ                   = 100,

   parameter C1_IDELAY_ADJ            = "OFF",

   parameter C1_FINE_PER_BIT          = "OFF",

   parameter C1_CENTER_COMP_MODE      = "OFF",

   parameter C1_PI_VAL_ADJ            = "OFF",

   

   parameter C1_CMD_PIPE_PLUS1        = "ON",

                                     // add pipeline stage between MC and PHY



   

   //***************************************************************************

   // System clock frequency parameters

   //***************************************************************************

   parameter C1_tCK                   = 2977,

                                     // memory tCK paramter.

                                     // # = Clock Period in pS.

   parameter C1_nCK_PER_CLK           = 4,

   // # of memory CKs per fabric CLK

   

   parameter C1_DIFF_TERM_SYSCLK      = "FALSE",

                                     // Differential Termination for System

                                     // clock input pins

      



   



   //***************************************************************************

   // Debug parameters

   //***************************************************************************

   parameter C1_DEBUG_PORT            = "OFF",

                                     // # = "ON" Enable debug signals/controls.

                                     //   = "OFF" Disable debug signals/controls.



   //***************************************************************************

   // Temparature monitor parameter

   //***************************************************************************

   parameter C1_TEMP_MON_CONTROL      = "EXTERNAL",

                                     // # = "INTERNAL", "EXTERNAL"

   //***************************************************************************

   // FPGA Voltage Type parameter

   //***************************************************************************

   parameter C1_FPGA_VOLT_TYPE        = "N",

                                     // # = "L", "N". When FPGA VccINT is 0.9v,

                                     // the value is "L", else it is "N"

      

   parameter RST_ACT_LOW           = 1

                                     // =1 for active low reset,

                                     // =0 for active high.

   )

  (



   // Inouts

   inout [C0_DQ_WIDTH-1:0]                         c0_ddr3_dq,

   inout [C0_DQS_WIDTH-1:0]                        c0_ddr3_dqs_n,

   inout [C0_DQS_WIDTH-1:0]                        c0_ddr3_dqs_p,



   // Outputs

   output [C0_ROW_WIDTH-1:0]                       c0_ddr3_addr,

   output [C0_BANK_WIDTH-1:0]                      c0_ddr3_ba,

   output                                       c0_ddr3_ras_n,

   output                                       c0_ddr3_cas_n,

   output                                       c0_ddr3_we_n,

   output                                       c0_ddr3_reset_n,

   output [C0_CK_WIDTH-1:0]                        c0_ddr3_ck_p,

   output [C0_CK_WIDTH-1:0]                        c0_ddr3_ck_n,

   output [C0_CKE_WIDTH-1:0]                       c0_ddr3_cke,

   

   output [(C0_CS_WIDTH*C0_nCS_PER_RANK)-1:0]           c0_ddr3_cs_n,

   

   output [C0_DM_WIDTH-1:0]                        c0_ddr3_dm,

   

   output [C0_ODT_WIDTH-1:0]                       c0_ddr3_odt,

   



   // Inputs

   

   // Differential system clocks

   input                                        c0_sys_clk_p,

   input                                        c0_sys_clk_n,

   

   // differential iodelayctrl clk (reference clock)

   input                                        clk_ref_p,

   input                                        clk_ref_n,

   

   // user interface signals

   input [C0_ADDR_WIDTH-1:0]                       c0_app_addr,

   input [2:0]                                  c0_app_cmd,

   input                                        c0_app_en,

   input [(C0_nCK_PER_CLK*2*C0_PAYLOAD_WIDTH)-1:0]    c0_app_wdf_data,

   input                                        c0_app_wdf_end,

   input [((C0_nCK_PER_CLK*2*C0_PAYLOAD_WIDTH)/8)-1:0]  c0_app_wdf_mask,

   input                                        c0_app_wdf_wren,

   output [(C0_nCK_PER_CLK*2*C0_PAYLOAD_WIDTH)-1:0]   c0_app_rd_data,

   output                                       c0_app_rd_data_end,

   output                                       c0_app_rd_data_valid,

   output                                       c0_app_rdy,

   output                                       c0_app_wdf_rdy,

   input                                        c0_app_sr_req,

   input                                        c0_app_ref_req,

   input                                        c0_app_zq_req,

   output                                       c0_app_sr_active,

   output                                       c0_app_ref_ack,

   output                                       c0_app_zq_ack,

   output                                       c0_ui_clk,

   output                                       c0_ui_clk_sync_rst,

   

   

   // debug signals

   output reg [390:0]                               c0_ddr3_ila_wrpath,

   output reg [1023:0]                              c0_ddr3_ila_rdpath,

   output reg [119:0]                               c0_ddr3_ila_basic,

   input [13:0]                                 c0_ddr3_vio_sync_out, // input from VIO



   input [C0_DQS_CNT_WIDTH:0]                      c0_dbg_byte_sel,

   input                                        c0_dbg_sel_pi_incdec,

   input                                        c0_dbg_pi_f_inc,

   input                                        c0_dbg_pi_f_dec,

   input                                        c0_dbg_sel_po_incdec,

   input                                        c0_dbg_po_f_inc,

   input                                        c0_dbg_po_f_dec,

   input                                        c0_dbg_po_f_stg23_sel,

   output [5:0]                                 c0_dbg_pi_counter_read_val,

   output [8:0]                                 c0_dbg_po_counter_read_val,

   output reg [107:0]                           c0_dbg_prbs_final_dqs_tap_cnt_r,

   output reg [107:0]                           c0_dbg_prbs_first_edge_taps,

   output reg [107:0]                           c0_dbg_prbs_second_edge_taps,

      

   

   output                                       c0_init_calib_complete,

   

   output [11:0]                                 c0_device_temp,

`ifdef SKIP_CALIB

   output                                      c0_calib_tap_req,

   input                                       c0_calib_tap_load,

   input [6:0]                                 c0_calib_tap_addr,

   input [7:0]                                 c0_calib_tap_val,

   input                                       c0_calib_tap_load_done,

`endif

      

   // Inouts

   inout [C1_DQ_WIDTH-1:0]                         c1_ddr3_dq,

   inout [C1_DQS_WIDTH-1:0]                        c1_ddr3_dqs_n,

   inout [C1_DQS_WIDTH-1:0]                        c1_ddr3_dqs_p,



   // Outputs

   output [C1_ROW_WIDTH-1:0]                       c1_ddr3_addr,

   output [C1_BANK_WIDTH-1:0]                      c1_ddr3_ba,

   output                                       c1_ddr3_ras_n,

   output                                       c1_ddr3_cas_n,

   output                                       c1_ddr3_we_n,

   output                                       c1_ddr3_reset_n,

   output [C1_CK_WIDTH-1:0]                        c1_ddr3_ck_p,

   output [C1_CK_WIDTH-1:0]                        c1_ddr3_ck_n,

   output [C1_CKE_WIDTH-1:0]                       c1_ddr3_cke,

   

   output [(C1_CS_WIDTH*C1_nCS_PER_RANK)-1:0]           c1_ddr3_cs_n,

   

   output [C1_DM_WIDTH-1:0]                        c1_ddr3_dm,

   

   output [C1_ODT_WIDTH-1:0]                       c1_ddr3_odt,

   



   // Inputs

   

   // Differential system clocks

   input                                        c1_sys_clk_p,

   input                                        c1_sys_clk_n,

   

   

   // user interface signals

   input [C1_ADDR_WIDTH-1:0]                       c1_app_addr,

   input [2:0]                                  c1_app_cmd,

   input                                        c1_app_en,

   input [(C1_nCK_PER_CLK*2*C1_PAYLOAD_WIDTH)-1:0]    c1_app_wdf_data,

   input                                        c1_app_wdf_end,

   input [((C1_nCK_PER_CLK*2*C1_PAYLOAD_WIDTH)/8)-1:0]  c1_app_wdf_mask,

   input                                        c1_app_wdf_wren,

   output [(C1_nCK_PER_CLK*2*C1_PAYLOAD_WIDTH)-1:0]   c1_app_rd_data,

   output                                       c1_app_rd_data_end,

   output                                       c1_app_rd_data_valid,

   output                                       c1_app_rdy,

   output                                       c1_app_wdf_rdy,

   input                                        c1_app_sr_req,

   input                                        c1_app_ref_req,

   input                                        c1_app_zq_req,

   output                                       c1_app_sr_active,

   output                                       c1_app_ref_ack,

   output                                       c1_app_zq_ack,

   output                                       c1_ui_clk,

   output                                       c1_ui_clk_sync_rst,

   

   

      

   

   output                                       c1_init_calib_complete,

   

   output [11:0]                                 c1_device_temp,

`ifdef SKIP_CALIB

   output                                      c1_calib_tap_req,

   input                                       c1_calib_tap_load,

   input [6:0]                                 c1_calib_tap_addr,

   input [7:0]                                 c1_calib_tap_val,

   input                                       c1_calib_tap_load_done,

`endif

      



   // System reset - Default polarity of sys_rst pin is Active Low.

   // System reset polarity will change based on the option 

   // selected in GUI.

   input                                        sys_rst

   );



  function integer clogb2 (input integer size);

    begin

      size = size - 1;

      for (clogb2=1; size>1; clogb2=clogb2+1)

        size = size >> 1;

    end

  endfunction // clogb2





  localparam C0_BM_CNT_WIDTH = clogb2(C0_nBANK_MACHS);

  localparam C0_RANK_WIDTH = clogb2(C0_RANKS);



  localparam C0_ECC_WIDTH = (C0_ECC == "OFF")?

                           0 : (C0_DATA_WIDTH <= 4)?

                            4 : (C0_DATA_WIDTH <= 10)?

                             5 : (C0_DATA_WIDTH <= 26)?

                              6 : (C0_DATA_WIDTH <= 57)?

                               7 : (C0_DATA_WIDTH <= 120)?

                                8 : (C0_DATA_WIDTH <= 247)?

                                 9 : 10;

  localparam C0_DATA_BUF_OFFSET_WIDTH = 1;

  localparam C0_MC_ERR_ADDR_WIDTH = ((C0_CS_WIDTH == 1) ? 0 : C0_RANK_WIDTH)

                                 + C0_BANK_WIDTH + C0_ROW_WIDTH + C0_COL_WIDTH

                                 + C0_DATA_BUF_OFFSET_WIDTH;



  localparam C0_APP_DATA_WIDTH        = 2 * C0_nCK_PER_CLK * C0_PAYLOAD_WIDTH;

  localparam C0_APP_MASK_WIDTH        = C0_APP_DATA_WIDTH / 8;

  localparam TEMP_MON_EN           = (C0_SIMULATION == "FALSE") ? "ON" : "OFF";

                                                 // Enable or disable the temp monitor module

  localparam tTEMPSAMPLE           = 10000000;   // sample every 10 us

  localparam XADC_CLK_PERIOD       = 5000;       // Use 200 MHz IODELAYCTRL clock

  `ifdef SKIP_CALIB

  localparam SKIP_CALIB = "TRUE";

  `else

  localparam SKIP_CALIB = "FALSE";

  `endif

      



  localparam C0_TAPSPERKCLK = (56*C0_MMCM_MULT_F)/C0_nCK_PER_CLK;

  

  localparam C1_BM_CNT_WIDTH = clogb2(C1_nBANK_MACHS);

  localparam C1_RANK_WIDTH = clogb2(C1_RANKS);



  localparam C1_ECC_WIDTH = (C1_ECC == "OFF")?

                           0 : (C1_DATA_WIDTH <= 4)?

                            4 : (C1_DATA_WIDTH <= 10)?

                             5 : (C1_DATA_WIDTH <= 26)?

                              6 : (C1_DATA_WIDTH <= 57)?

                               7 : (C1_DATA_WIDTH <= 120)?

                                8 : (C1_DATA_WIDTH <= 247)?

                                 9 : 10;

  localparam C1_DATA_BUF_OFFSET_WIDTH = 1;

  localparam C1_MC_ERR_ADDR_WIDTH = ((C1_CS_WIDTH == 1) ? 0 : C1_RANK_WIDTH)

                                 + C1_BANK_WIDTH + C1_ROW_WIDTH + C1_COL_WIDTH

                                 + C1_DATA_BUF_OFFSET_WIDTH;



  localparam C1_APP_DATA_WIDTH        = 2 * C1_nCK_PER_CLK * C1_PAYLOAD_WIDTH;

  localparam C1_APP_MASK_WIDTH        = C1_APP_DATA_WIDTH / 8;



  localparam C1_TAPSPERKCLK = (56*C1_MMCM_MULT_F)/C1_nCK_PER_CLK;

  



  // Wire declarations

      

  wire [C0_BM_CNT_WIDTH-1:0]           c0_bank_mach_next;

  wire                              c0_clk;

  wire [1:0]                        clk_ref;

  wire [1:0]                        iodelay_ctrl_rdy;

  wire                              clk_ref_in;

  wire                              sys_rst_o;

  wire                              c0_clk_div2;

  wire                              c0_rst_div2;

  wire                              c0_freq_refclk ;

  wire                              c0_mem_refclk ;

  wire                              c0_pll_lock ;

  wire                              c0_sync_pulse;

  wire                              c0_mmcm_ps_clk;

  wire                              c0_poc_sample_pd;

  wire                              c0_psen;

  wire                              c0_psincdec;

  wire                              c0_psdone;

  wire                              c0_iddr_rst;

  wire                              c0_ref_dll_lock;

  wire                              c0_rst_phaser_ref;

  wire                              c0_pll_locked;



  wire                              c0_rst;

  

  wire [(2*C0_nCK_PER_CLK)-1:0]            c0_app_ecc_multiple_err;

  wire [(2*C0_nCK_PER_CLK)-1:0]            c0_app_ecc_single_err;

  wire                                c0_ddr3_parity;

      



  wire                              c0_sys_clk_i;

  wire                              c0_mmcm_clk;

  wire                              clk_ref_i;

  wire [11:0]                       c0_device_temp_s;

  wire [11:0]                       device_temp_i;



  // Debug port signals

  wire                              c0_dbg_idel_down_all;

  wire                              c0_dbg_idel_down_cpt;

  wire                              c0_dbg_idel_up_all;

  wire                              c0_dbg_idel_up_cpt;

  wire                              c0_dbg_sel_all_idel_cpt;

  wire [C0_DQS_CNT_WIDTH-1:0]          c0_dbg_sel_idel_cpt;

  wire [(6*C0_DQS_WIDTH*C0_RANKS)-1:0]      c0_dbg_cpt_tap_cnt;

  wire [(5*C0_DQS_WIDTH*C0_RANKS)-1:0]      c0_dbg_dq_idelay_tap_cnt;

  wire [255:0]                      c0_dbg_calib_top;

  wire [(6*C0_DQS_WIDTH*C0_RANKS)-1:0]      c0_dbg_cpt_first_edge_cnt;

  wire [(6*C0_DQS_WIDTH*C0_RANKS)-1:0]      c0_dbg_cpt_second_edge_cnt;

  wire [(6*C0_RANKS)-1:0]                c0_dbg_rd_data_offset;

  wire [255:0]                      c0_dbg_phy_rdlvl;

  wire [99:0]                       c0_dbg_phy_wrcal;

  wire [(6*C0_DQS_WIDTH)-1:0]            c0_dbg_final_po_fine_tap_cnt;

  wire [(3*C0_DQS_WIDTH)-1:0]            c0_dbg_final_po_coarse_tap_cnt;

  wire [255:0]                      c0_dbg_phy_wrlvl;

  wire [255:0]                      c0_dbg_phy_init;

  wire [255:0]                      c0_dbg_prbs_rdlvl;

  wire [255:0]                      c0_dbg_dqs_found_cal;

  wire                              c0_dbg_pi_phaselock_start;

  wire                              c0_dbg_pi_phaselocked_done;

  wire                              c0_dbg_pi_phaselock_err;

  wire                              c0_dbg_pi_dqsfound_start;

  wire                              c0_dbg_pi_dqsfound_done;

  wire                              c0_dbg_pi_dqsfound_err;

  wire                              c0_dbg_wrcal_start;

  wire                              c0_dbg_wrcal_done;

  wire                              c0_dbg_wrcal_err;

  wire [11:0]                       c0_dbg_pi_dqs_found_lanes_phy4lanes;

  wire [11:0]                       c0_dbg_pi_phase_locked_phy4lanes;

  wire                              c0_dbg_oclkdelay_calib_start;

  wire                              c0_dbg_oclkdelay_calib_done;

  wire [255:0]                      c0_dbg_phy_oclkdelay_cal;

  wire [(C0_DRAM_WIDTH*16)-1:0]         c0_dbg_oclkdelay_rd_data;

  wire [C0_DQS_WIDTH-1:0]              c0_dbg_rd_data_edge_detect;

  wire [(2*C0_nCK_PER_CLK*C0_DQ_WIDTH)-1:0] c0_dbg_rddata;

  wire                              c0_dbg_rddata_valid;

  wire [1:0]                        c0_dbg_rdlvl_done;

  wire [1:0]                        c0_dbg_rdlvl_err;

  wire [1:0]                        c0_dbg_rdlvl_start;

  wire [(6*C0_DQS_WIDTH)-1:0]            c0_dbg_wrlvl_fine_tap_cnt;

  wire [(3*C0_DQS_WIDTH)-1:0]            c0_dbg_wrlvl_coarse_tap_cnt;

  wire [5:0]                        c0_dbg_tap_cnt_during_wrlvl;

  wire                              c0_dbg_wl_edge_detect_valid;

  wire                              c0_dbg_wrlvl_done;

  wire                              c0_dbg_wrlvl_err;

  wire                              c0_dbg_wrlvl_start;

  reg [63:0]                        c0_dbg_rddata_r;

  reg                               c0_dbg_rddata_valid_r;

  wire [53:0]                       c0_ocal_tap_cnt;

  wire [4:0]                        c0_dbg_dqs;

  wire [8:0]                        c0_dbg_bit;

  wire [8:0]                        c0_rd_data_edge_detect_r;

  wire [53:0]                       c0_wl_po_fine_cnt;

  wire [26:0]                       c0_wl_po_coarse_cnt;

  wire [(6*C0_RANKS)-1:0]                c0_dbg_calib_rd_data_offset_1;

  wire [(6*C0_RANKS)-1:0]                c0_dbg_calib_rd_data_offset_2;

  wire [5:0]                        c0_dbg_data_offset;

  wire [5:0]                        c0_dbg_data_offset_1;

  wire [5:0]                        c0_dbg_data_offset_2;



  wire [390:0]                      c0_ddr3_ila_wrpath_int;

  wire [1023:0]                     c0_ddr3_ila_rdpath_int;

  wire [119:0]                      c0_ddr3_ila_basic_int;

  wire [(6*C0_DQS_WIDTH*C0_RANKS)-1:0] c0_dbg_prbs_final_dqs_tap_cnt_r_int;

  wire [(6*C0_DQS_WIDTH*C0_RANKS)-1:0] c0_dbg_prbs_first_edge_taps_int;

  wire [(6*C0_DQS_WIDTH*C0_RANKS)-1:0] c0_dbg_prbs_second_edge_taps_int;

        // Wire declarations

      

  wire [C1_BM_CNT_WIDTH-1:0]           c1_bank_mach_next;

  wire                              c1_clk;

  wire                              c1_clk_div2;

  wire                              c1_rst_div2;

  wire                              c1_freq_refclk ;

  wire                              c1_mem_refclk ;

  wire                              c1_pll_lock ;

  wire                              c1_sync_pulse;

  wire                              c1_mmcm_ps_clk;

  wire                              c1_poc_sample_pd;

  wire                              c1_psen;

  wire                              c1_psincdec;

  wire                              c1_psdone;

  wire                              c1_iddr_rst;

  wire                              c1_ref_dll_lock;

  wire                              c1_rst_phaser_ref;

  wire                              c1_pll_locked;



  wire                              c1_rst;

  

  wire [(2*C1_nCK_PER_CLK)-1:0]            c1_app_ecc_multiple_err;

  wire [(2*C1_nCK_PER_CLK)-1:0]            c1_app_ecc_single_err;

  wire                                c1_ddr3_parity;

      



  wire                              c1_sys_clk_i;

  wire                              c1_mmcm_clk;

  wire [11:0]                       c1_device_temp_s;



  // Debug port signals

  wire                              c1_dbg_idel_down_all;

  wire                              c1_dbg_idel_down_cpt;

  wire                              c1_dbg_idel_up_all;

  wire                              c1_dbg_idel_up_cpt;

  wire                              c1_dbg_sel_all_idel_cpt;

  wire [C1_DQS_CNT_WIDTH-1:0]          c1_dbg_sel_idel_cpt;

  wire                              c1_dbg_sel_pi_incdec;

  wire [C1_DQS_CNT_WIDTH:0]            c1_dbg_byte_sel;

  wire                              c1_dbg_pi_f_inc;

  wire                              c1_dbg_pi_f_dec;

  wire [5:0]                        c1_dbg_pi_counter_read_val;

  wire [8:0]                        c1_dbg_po_counter_read_val;



  wire [(6*C1_DQS_WIDTH*C1_RANKS)-1:0]      c1_dbg_cpt_tap_cnt;

  wire [(5*C1_DQS_WIDTH*C1_RANKS)-1:0]      c1_dbg_dq_idelay_tap_cnt;

  wire [255:0]                      c1_dbg_calib_top;

  wire [(6*C1_DQS_WIDTH*C1_RANKS)-1:0]      c1_dbg_cpt_first_edge_cnt;

  wire [(6*C1_DQS_WIDTH*C1_RANKS)-1:0]      c1_dbg_cpt_second_edge_cnt;

  wire [(6*C1_RANKS)-1:0]                c1_dbg_rd_data_offset;

  wire [255:0]                      c1_dbg_phy_rdlvl;

  wire [99:0]                       c1_dbg_phy_wrcal;

  wire [(6*C1_DQS_WIDTH)-1:0]            c1_dbg_final_po_fine_tap_cnt;

  wire [(3*C1_DQS_WIDTH)-1:0]            c1_dbg_final_po_coarse_tap_cnt;

  wire [255:0]                      c1_dbg_phy_wrlvl;

  wire [255:0]                      c1_dbg_phy_init;

  wire [255:0]                      c1_dbg_prbs_rdlvl;

  wire [255:0]                      c1_dbg_dqs_found_cal;

  wire                              c1_dbg_pi_phaselock_start;

  wire                              c1_dbg_pi_phaselocked_done;

  wire                              c1_dbg_pi_phaselock_err;

  wire                              c1_dbg_pi_dqsfound_start;

  wire                              c1_dbg_pi_dqsfound_done;

  wire                              c1_dbg_pi_dqsfound_err;

  wire                              c1_dbg_wrcal_start;

  wire                              c1_dbg_wrcal_done;

  wire                              c1_dbg_wrcal_err;

  wire [11:0]                       c1_dbg_pi_dqs_found_lanes_phy4lanes;

  wire [11:0]                       c1_dbg_pi_phase_locked_phy4lanes;

  wire                              c1_dbg_oclkdelay_calib_start;

  wire                              c1_dbg_oclkdelay_calib_done;

  wire [255:0]                      c1_dbg_phy_oclkdelay_cal;

  wire [(C1_DRAM_WIDTH*16)-1:0]         c1_dbg_oclkdelay_rd_data;

  wire [C1_DQS_WIDTH-1:0]              c1_dbg_rd_data_edge_detect;

  wire [(2*C1_nCK_PER_CLK*C1_DQ_WIDTH)-1:0] c1_dbg_rddata;

  wire                              c1_dbg_rddata_valid;

  wire [1:0]                        c1_dbg_rdlvl_done;

  wire [1:0]                        c1_dbg_rdlvl_err;

  wire [1:0]                        c1_dbg_rdlvl_start;

  wire [(6*C1_DQS_WIDTH)-1:0]            c1_dbg_wrlvl_fine_tap_cnt;

  wire [(3*C1_DQS_WIDTH)-1:0]            c1_dbg_wrlvl_coarse_tap_cnt;

  wire [5:0]                        c1_dbg_tap_cnt_during_wrlvl;

  wire                              c1_dbg_wl_edge_detect_valid;

  wire                              c1_dbg_wrlvl_done;

  wire                              c1_dbg_wrlvl_err;

  wire                              c1_dbg_wrlvl_start;

  reg [63:0]                        c1_dbg_rddata_r;

  reg                               c1_dbg_rddata_valid_r;

  wire [53:0]                       c1_ocal_tap_cnt;

  wire [4:0]                        c1_dbg_dqs;

  wire [8:0]                        c1_dbg_bit;

  wire [8:0]                        c1_rd_data_edge_detect_r;

  wire [53:0]                       c1_wl_po_fine_cnt;

  wire [26:0]                       c1_wl_po_coarse_cnt;

  wire [(6*C1_RANKS)-1:0]                c1_dbg_calib_rd_data_offset_1;

  wire [(6*C1_RANKS)-1:0]                c1_dbg_calib_rd_data_offset_2;

  wire [5:0]                        c1_dbg_data_offset;

  wire [5:0]                        c1_dbg_data_offset_1;

  wire [5:0]                        c1_dbg_data_offset_2;



  wire [390:0]                      c1_ddr3_ila_wrpath_int;

  wire [1023:0]                     c1_ddr3_ila_rdpath_int;

  wire [119:0]                      c1_ddr3_ila_basic_int;

  wire [(6*C1_DQS_WIDTH*C1_RANKS)-1:0] c1_dbg_prbs_final_dqs_tap_cnt_r_int;

  wire [(6*C1_DQS_WIDTH*C1_RANKS)-1:0] c1_dbg_prbs_first_edge_taps_int;

  wire [(6*C1_DQS_WIDTH*C1_RANKS)-1:0] c1_dbg_prbs_second_edge_taps_int;

      



//***************************************************************************







  assign c0_ui_clk = c0_clk;

  assign c0_ui_clk_sync_rst = c0_rst;

  

  assign c0_sys_clk_i = 1'b0;

  assign clk_ref_i = 1'b0;

  assign c0_device_temp = c0_device_temp_s;

        assign c1_ui_clk = c1_clk;

  assign c1_ui_clk_sync_rst = c1_rst;

  

  assign c1_sys_clk_i = 1'b0;

  assign c1_device_temp = c1_device_temp_s;

      



  generate

    if (REFCLK_TYPE == "USE_SYSTEM_CLOCK")

      assign clk_ref_in = c0_mmcm_clk;

    else

      assign clk_ref_in = clk_ref_i;

  endgenerate



  mig_7series_v4_2_iodelay_ctrl #

    (

     .TCQ                       (C0_TCQ),

     .IODELAY_GRP0              (IODELAY_GRP0),

     .IODELAY_GRP1              (IODELAY_GRP1),

     .REFCLK_TYPE               (REFCLK_TYPE),

     .SYSCLK_TYPE               (SYSCLK_TYPE),

     .SYS_RST_PORT              (SYS_RST_PORT),

     .RST_ACT_LOW               (RST_ACT_LOW),

     .DIFF_TERM_REFCLK          (DIFF_TERM_REFCLK),

     .FPGA_SPEED_GRADE          (FPGA_SPEED_GRADE),

     .REF_CLK_MMCM_IODELAY_CTRL (REF_CLK_MMCM_IODELAY_CTRL)

     )

    u_iodelay_ctrl

      (

       // Outputs

       .iodelay_ctrl_rdy (iodelay_ctrl_rdy),

       .sys_rst_o        (sys_rst_o),

       .clk_ref          (clk_ref),

       // Inputs

       .clk_ref_p        (clk_ref_p),

       .clk_ref_n        (clk_ref_n),

       .clk_ref_i        (clk_ref_in),

       .sys_rst          (sys_rst)

       );

  mig_7series_v4_2_clk_ibuf #

    (

     .SYSCLK_TYPE      (SYSCLK_TYPE),

     .DIFF_TERM_SYSCLK (C0_DIFF_TERM_SYSCLK)

     )

    c0_u_ddr3_clk_ibuf

      (

       .sys_clk_p        (c0_sys_clk_p),

       .sys_clk_n        (c0_sys_clk_n),

       .sys_clk_i        (c0_sys_clk_i),

       .mmcm_clk         (c0_mmcm_clk)

       );

  // Temperature monitoring logic



  generate

    if (TEMP_MON_EN == "ON") begin: c0_temp_mon_enabled



      mig_7series_v4_2_tempmon #

        (

         .TCQ              (C0_TCQ),

         .TEMP_MON_CONTROL (C0_TEMP_MON_CONTROL),

         .XADC_CLK_PERIOD  (XADC_CLK_PERIOD),

         .tTEMPSAMPLE      (tTEMPSAMPLE)

         )

        u_tempmon

          (

           .clk            (c0_clk),

           .xadc_clk       (clk_ref[0]),

           .rst            (c0_rst),

           .device_temp_i  (device_temp_i),

           .device_temp    (c0_device_temp_s)

          );

    end else begin: c0_temp_mon_disabled



      assign c0_device_temp_s = 'b0;



    end

  endgenerate

         

  mig_7series_v4_2_infrastructure #

    (

     .TCQ                (C0_TCQ),

     .nCK_PER_CLK        (C0_nCK_PER_CLK),

     .CLKIN_PERIOD       (C0_CLKIN_PERIOD),

     .SYSCLK_TYPE        (SYSCLK_TYPE),

     .CLKFBOUT_MULT      (C0_CLKFBOUT_MULT),

     .DIVCLK_DIVIDE      (C0_DIVCLK_DIVIDE),

     .CLKOUT0_PHASE      (C0_CLKOUT0_PHASE),

     .CLKOUT0_DIVIDE     (C0_CLKOUT0_DIVIDE),

     .CLKOUT1_DIVIDE     (C0_CLKOUT1_DIVIDE),

     .CLKOUT2_DIVIDE     (C0_CLKOUT2_DIVIDE),

     .CLKOUT3_DIVIDE     (C0_CLKOUT3_DIVIDE),

     .MMCM_VCO           (C0_MMCM_VCO),

     .MMCM_MULT_F        (C0_MMCM_MULT_F),

     .MMCM_DIVCLK_DIVIDE (C0_MMCM_DIVCLK_DIVIDE),

     .RST_ACT_LOW        (RST_ACT_LOW),

     .tCK                (C0_tCK),

     .MEM_TYPE           (DRAM_TYPE)

     )

    c0_u_ddr3_infrastructure

      (

       // Outputs

       .rstdiv0          (c0_rst),

       .clk              (c0_clk),

       .clk_div2         (c0_clk_div2),

       .rst_div2         (c0_rst_div2),

       .mem_refclk       (c0_mem_refclk),

       .freq_refclk      (c0_freq_refclk),

       .sync_pulse       (c0_sync_pulse),

       .mmcm_ps_clk      (c0_mmcm_ps_clk),

       .poc_sample_pd    (c0_poc_sample_pd),

       .psdone           (c0_psdone),

       .iddr_rst         (c0_iddr_rst),

//       .auxout_clk       (),

       .ui_addn_clk_0    (),

       .ui_addn_clk_1    (),

       .ui_addn_clk_2    (),

       .ui_addn_clk_3    (),

       .ui_addn_clk_4    (),

       .pll_locked       (c0_pll_locked),

       .mmcm_locked      (),

       .rst_phaser_ref   (c0_rst_phaser_ref),

       // Inputs

       .psen             (c0_psen),

       .psincdec         (c0_psincdec),

       .mmcm_clk         (c0_mmcm_clk),

       .sys_rst          (sys_rst_o),

       .iodelay_ctrl_rdy (iodelay_ctrl_rdy),

       .ref_dll_lock     (c0_ref_dll_lock)

       );

      

  mig_7series_v4_2_clk_ibuf #

    (

     .SYSCLK_TYPE      (SYSCLK_TYPE),

     .DIFF_TERM_SYSCLK (C1_DIFF_TERM_SYSCLK)

     )

    c1_u_ddr3_clk_ibuf

      (

       .sys_clk_p        (c1_sys_clk_p),

       .sys_clk_n        (c1_sys_clk_n),

       .sys_clk_i        (c1_sys_clk_i),

       .mmcm_clk         (c1_mmcm_clk)

       );

  // Temperature monitoring logic



  generate

    if (TEMP_MON_EN == "ON") begin: c1_temp_mon_enabled



      mig_7series_v4_2_tempmon #

        (

         .TCQ              (C1_TCQ),

         .TEMP_MON_CONTROL (C1_TEMP_MON_CONTROL),

         .XADC_CLK_PERIOD  (XADC_CLK_PERIOD),

         .tTEMPSAMPLE      (tTEMPSAMPLE)

         )

        u_tempmon

          (

           .clk            (c1_clk),

           .xadc_clk       (clk_ref[0]),

           .rst            (c1_rst),

           .device_temp_i  (c0_device_temp_s),

           .device_temp    (c1_device_temp_s)

          );

    end else begin: c1_temp_mon_disabled



      assign c1_device_temp_s = 'b0;



    end

  endgenerate

         

  mig_7series_v4_2_infrastructure #

    (

     .TCQ                (C1_TCQ),

     .nCK_PER_CLK        (C1_nCK_PER_CLK),

     .CLKIN_PERIOD       (C1_CLKIN_PERIOD),

     .SYSCLK_TYPE        (SYSCLK_TYPE),

     .CLKFBOUT_MULT      (C1_CLKFBOUT_MULT),

     .DIVCLK_DIVIDE      (C1_DIVCLK_DIVIDE),

     .CLKOUT0_PHASE      (C1_CLKOUT0_PHASE),

     .CLKOUT0_DIVIDE     (C1_CLKOUT0_DIVIDE),

     .CLKOUT1_DIVIDE     (C1_CLKOUT1_DIVIDE),

     .CLKOUT2_DIVIDE     (C1_CLKOUT2_DIVIDE),

     .CLKOUT3_DIVIDE     (C1_CLKOUT3_DIVIDE),

     .MMCM_VCO           (C1_MMCM_VCO),

     .MMCM_MULT_F        (C1_MMCM_MULT_F),

     .MMCM_DIVCLK_DIVIDE (C1_MMCM_DIVCLK_DIVIDE),

     .RST_ACT_LOW        (RST_ACT_LOW),

     .tCK                (C1_tCK),

     .MEM_TYPE           (DRAM_TYPE)

     )

    c1_u_ddr3_infrastructure

      (

       // Outputs

       .rstdiv0          (c1_rst),

       .clk              (c1_clk),

       .clk_div2         (c1_clk_div2),

       .rst_div2         (c1_rst_div2),

       .mem_refclk       (c1_mem_refclk),

       .freq_refclk      (c1_freq_refclk),

       .sync_pulse       (c1_sync_pulse),

       .mmcm_ps_clk      (c1_mmcm_ps_clk),

       .poc_sample_pd    (c1_poc_sample_pd),

       .psdone           (c1_psdone),

       .iddr_rst         (c1_iddr_rst),

//       .auxout_clk       (),

       .ui_addn_clk_0    (),

       .ui_addn_clk_1    (),

       .ui_addn_clk_2    (),

       .ui_addn_clk_3    (),

       .ui_addn_clk_4    (),

       .pll_locked       (c1_pll_locked),

       .mmcm_locked      (),

       .rst_phaser_ref   (c1_rst_phaser_ref),

       // Inputs

       .psen             (c1_psen),

       .psincdec         (c1_psincdec),

       .mmcm_clk         (c1_mmcm_clk),

       .sys_rst          (sys_rst_o),

       .iodelay_ctrl_rdy (iodelay_ctrl_rdy),

       .ref_dll_lock     (c1_ref_dll_lock)

       );

      



  mig_7series_v4_2_memc_ui_top_std #

    (

     .TCQ                              (C0_TCQ),

     .ADDR_CMD_MODE                    (C0_ADDR_CMD_MODE),

     .AL                               (C0_AL),

     .PAYLOAD_WIDTH                    (C0_PAYLOAD_WIDTH),

     .BANK_WIDTH                       (C0_BANK_WIDTH),

     .BM_CNT_WIDTH                     (C0_BM_CNT_WIDTH),

     .BURST_MODE                       (C0_BURST_MODE),

     .BURST_TYPE                       (C0_BURST_TYPE),

     .CA_MIRROR                        (C0_CA_MIRROR),

     .DDR3_VDD_OP_VOLT                 (C0_VDD_OP_VOLT),

     .CK_WIDTH                         (C0_CK_WIDTH),

     .COL_WIDTH                        (C0_COL_WIDTH),

     .CMD_PIPE_PLUS1                   (C0_CMD_PIPE_PLUS1),

     .CS_WIDTH                         (C0_CS_WIDTH),

     .nCS_PER_RANK                     (C0_nCS_PER_RANK),

     .CKE_WIDTH                        (C0_CKE_WIDTH),

     .DATA_WIDTH                       (C0_DATA_WIDTH),

     .DATA_BUF_ADDR_WIDTH              (C0_DATA_BUF_ADDR_WIDTH),

     .DM_WIDTH                         (C0_DM_WIDTH),

     .DQ_CNT_WIDTH                     (C0_DQ_CNT_WIDTH),

     .DQ_WIDTH                         (C0_DQ_WIDTH),

     .DQS_CNT_WIDTH                    (C0_DQS_CNT_WIDTH),

     .DQS_WIDTH                        (C0_DQS_WIDTH),

     .DRAM_TYPE                        (DRAM_TYPE),

     .DRAM_WIDTH                       (C0_DRAM_WIDTH),

     .ECC                              (C0_ECC),

     .ECC_WIDTH                        (C0_ECC_WIDTH),

     .ECC_TEST                         (C0_ECC_TEST),

     .MC_ERR_ADDR_WIDTH                (C0_MC_ERR_ADDR_WIDTH),

     .REFCLK_FREQ                      (REFCLK_FREQ),

     .nAL                              (C0_nAL),

     .nBANK_MACHS                      (C0_nBANK_MACHS),

     .CKE_ODT_AUX                      (C0_CKE_ODT_AUX),

     .nCK_PER_CLK                      (C0_nCK_PER_CLK),

     .ORDERING                         (C0_ORDERING),

     .OUTPUT_DRV                       (C0_OUTPUT_DRV),

     .IBUF_LPWR_MODE                   (C0_IBUF_LPWR_MODE),

     .DATA_IO_IDLE_PWRDWN              (C0_DATA_IO_IDLE_PWRDWN),

     .BANK_TYPE                        (C0_BANK_TYPE),

     .DATA_IO_PRIM_TYPE                (C0_DATA_IO_PRIM_TYPE),

     .IODELAY_GRP0                     (IODELAY_GRP0),

     .IODELAY_GRP1                     (IODELAY_GRP1),

     .FPGA_SPEED_GRADE                 (FPGA_SPEED_GRADE),

     .REG_CTRL                         (C0_REG_CTRL),

     .RTT_NOM                          (C0_RTT_NOM),

     .RTT_WR                           (C0_RTT_WR),

     .CL                               (C0_CL),

     .CWL                              (C0_CWL),

     .tCK                              (C0_tCK),

     .tCKE                             (C0_tCKE),

     .tFAW                             (C0_tFAW),

     .tPRDI                            (C0_tPRDI),

     .tRAS                             (C0_tRAS),

     .tRCD                             (C0_tRCD),

     .tREFI                            (C0_tREFI),

     .tRFC                             (C0_tRFC),

     .tRP                              (C0_tRP),

     .tRRD                             (C0_tRRD),

     .tRTP                             (C0_tRTP),

     .tWTR                             (C0_tWTR),

     .tZQI                             (C0_tZQI),

     .tZQCS                            (C0_tZQCS),

     .USER_REFRESH                     (C0_USER_REFRESH),

     .TEMP_MON_EN                      (TEMP_MON_EN),

     .WRLVL                            (C0_WRLVL),

     .DEBUG_PORT                       (C0_DEBUG_PORT),

     .CAL_WIDTH                        (CAL_WIDTH),

     .RANK_WIDTH                       (C0_RANK_WIDTH),

     .RANKS                            (C0_RANKS),

     .ODT_WIDTH                        (C0_ODT_WIDTH),

     .ROW_WIDTH                        (C0_ROW_WIDTH),

     .ADDR_WIDTH                       (C0_ADDR_WIDTH),

     .APP_DATA_WIDTH                   (C0_APP_DATA_WIDTH),

     .APP_MASK_WIDTH                   (C0_APP_MASK_WIDTH),

     .SIM_BYPASS_INIT_CAL              (C0_SIM_BYPASS_INIT_CAL),

     .BYTE_LANES_B0                    (C0_BYTE_LANES_B0),

     .BYTE_LANES_B1                    (C0_BYTE_LANES_B1),

     .BYTE_LANES_B2                    (C0_BYTE_LANES_B2),

     .BYTE_LANES_B3                    (C0_BYTE_LANES_B3),

     .BYTE_LANES_B4                    (C0_BYTE_LANES_B4),

     .DATA_CTL_B0                      (C0_DATA_CTL_B0),

     .DATA_CTL_B1                      (C0_DATA_CTL_B1),

     .DATA_CTL_B2                      (C0_DATA_CTL_B2),

     .DATA_CTL_B3                      (C0_DATA_CTL_B3),

     .DATA_CTL_B4                      (C0_DATA_CTL_B4),

     .PHY_0_BITLANES                   (C0_PHY_0_BITLANES),

     .PHY_1_BITLANES                   (C0_PHY_1_BITLANES),

     .PHY_2_BITLANES                   (C0_PHY_2_BITLANES),

     .CK_BYTE_MAP                      (C0_CK_BYTE_MAP),

     .ADDR_MAP                         (C0_ADDR_MAP),

     .BANK_MAP                         (C0_BANK_MAP),

     .CAS_MAP                          (C0_CAS_MAP),

     .CKE_ODT_BYTE_MAP                 (C0_CKE_ODT_BYTE_MAP),

     .CKE_MAP                          (C0_CKE_MAP),

     .ODT_MAP                          (C0_ODT_MAP),

     .CS_MAP                           (C0_CS_MAP),

     .PARITY_MAP                       (C0_PARITY_MAP),

     .RAS_MAP                          (C0_RAS_MAP),

     .WE_MAP                           (C0_WE_MAP),

     .DQS_BYTE_MAP                     (C0_DQS_BYTE_MAP),

     .DATA0_MAP                        (C0_DATA0_MAP),

     .DATA1_MAP                        (C0_DATA1_MAP),

     .DATA2_MAP                        (C0_DATA2_MAP),

     .DATA3_MAP                        (C0_DATA3_MAP),

     .DATA4_MAP                        (C0_DATA4_MAP),

     .DATA5_MAP                        (C0_DATA5_MAP),

     .DATA6_MAP                        (C0_DATA6_MAP),

     .DATA7_MAP                        (C0_DATA7_MAP),

     .DATA8_MAP                        (C0_DATA8_MAP),

     .DATA9_MAP                        (C0_DATA9_MAP),

     .DATA10_MAP                       (C0_DATA10_MAP),

     .DATA11_MAP                       (C0_DATA11_MAP),

     .DATA12_MAP                       (C0_DATA12_MAP),

     .DATA13_MAP                       (C0_DATA13_MAP),

     .DATA14_MAP                       (C0_DATA14_MAP),

     .DATA15_MAP                       (C0_DATA15_MAP),

     .DATA16_MAP                       (C0_DATA16_MAP),

     .DATA17_MAP                       (C0_DATA17_MAP),

     .MASK0_MAP                        (C0_MASK0_MAP),

     .MASK1_MAP                        (C0_MASK1_MAP),

     .CALIB_ROW_ADD                    (C0_CALIB_ROW_ADD),

     .CALIB_COL_ADD                    (C0_CALIB_COL_ADD),

     .CALIB_BA_ADD                     (C0_CALIB_BA_ADD),

     .IDELAY_ADJ                       (C0_IDELAY_ADJ),

     .FINE_PER_BIT                     (C0_FINE_PER_BIT),

     .CENTER_COMP_MODE                 (C0_CENTER_COMP_MODE),

     .PI_VAL_ADJ                       (C0_PI_VAL_ADJ),

     .SLOT_0_CONFIG                    (C0_SLOT_0_CONFIG),

     .SLOT_1_CONFIG                    (C0_SLOT_1_CONFIG),

     .MEM_ADDR_ORDER                   (C0_MEM_ADDR_ORDER),

     .STARVE_LIMIT                     (STARVE_LIMIT),

     .USE_CS_PORT                      (C0_USE_CS_PORT),

     .USE_DM_PORT                      (C0_USE_DM_PORT),

     .USE_ODT_PORT                     (C0_USE_ODT_PORT),

     .MASTER_PHY_CTL                   (C0_PHY_CONTROL_MASTER_BANK),

     .TAPSPERKCLK                      (C0_TAPSPERKCLK),

     .SKIP_CALIB                       (SKIP_CALIB),

     .FPGA_VOLT_TYPE                   (C0_FPGA_VOLT_TYPE)

     )

    c0_u_memc_ui_top_std

      (

       .clk                              (c0_clk),

       .clk_div2                         (c0_clk_div2),

       .rst_div2                         (c0_rst_div2),

       .clk_ref                          (clk_ref),

       .mem_refclk                       (c0_mem_refclk), //memory clock

       .freq_refclk                      (c0_freq_refclk),

       .pll_lock                         (c0_pll_locked),

       .sync_pulse                       (c0_sync_pulse),

       .mmcm_ps_clk                      (c0_mmcm_ps_clk),

       .poc_sample_pd                    (c0_poc_sample_pd),

       .psdone                           (c0_psdone),

       .iddr_rst                         (c0_iddr_rst),

       .psen                             (c0_psen),

       .psincdec                         (c0_psincdec),

       .rst                              (c0_rst),

       .rst_phaser_ref                   (c0_rst_phaser_ref),

       .ref_dll_lock                     (c0_ref_dll_lock),



// Memory interface ports

       .ddr_dq                           (c0_ddr3_dq),

       .ddr_dqs_n                        (c0_ddr3_dqs_n),

       .ddr_dqs                          (c0_ddr3_dqs_p),

       .ddr_addr                         (c0_ddr3_addr),

       .ddr_ba                           (c0_ddr3_ba),

       .ddr_cas_n                        (c0_ddr3_cas_n),

       .ddr_ck_n                         (c0_ddr3_ck_n),

       .ddr_ck                           (c0_ddr3_ck_p),

       .ddr_cke                          (c0_ddr3_cke),

       .ddr_cs_n                         (c0_ddr3_cs_n),

       .ddr_dm                           (c0_ddr3_dm),

       .ddr_odt                          (c0_ddr3_odt),

       .ddr_ras_n                        (c0_ddr3_ras_n),

       .ddr_reset_n                      (c0_ddr3_reset_n),

       .ddr_parity                       (c0_ddr3_parity),

       .ddr_we_n                         (c0_ddr3_we_n),

       .bank_mach_next                   (c0_bank_mach_next),



// Application interface ports

       .app_addr                         (c0_app_addr),

       .app_cmd                          (c0_app_cmd),

       .app_en                           (c0_app_en),

       .app_hi_pri                       (1'b0),

       .app_wdf_data                     (c0_app_wdf_data),

       .app_wdf_end                      (c0_app_wdf_end),

       .app_wdf_mask                     (c0_app_wdf_mask),

       .app_wdf_wren                     (c0_app_wdf_wren),

       .app_ecc_multiple_err             (c0_app_ecc_multiple_err),

       .app_ecc_single_err               (c0_app_ecc_single_err),

       .app_rd_data                      (c0_app_rd_data),

       .app_rd_data_end                  (c0_app_rd_data_end),

       .app_rd_data_valid                (c0_app_rd_data_valid),

       .app_rdy                          (c0_app_rdy),

       .app_wdf_rdy                      (c0_app_wdf_rdy),

       .app_sr_req                       (c0_app_sr_req),

       .app_sr_active                    (c0_app_sr_active),

       .app_ref_req                      (c0_app_ref_req),

       .app_ref_ack                      (c0_app_ref_ack),

       .app_zq_req                       (c0_app_zq_req),

       .app_zq_ack                       (c0_app_zq_ack),

       .app_raw_not_ecc                  ({2*C0_nCK_PER_CLK{1'b0}}),

       .app_correct_en_i                 (1'b1),



       .device_temp                      (c0_device_temp_s),



       // skip calibration ports

       `ifdef SKIP_CALIB

       .calib_tap_req                    (c0_calib_tap_req),

       .calib_tap_load                   (c0_calib_tap_load),

       .calib_tap_addr                   (c0_calib_tap_addr),

       .calib_tap_val                    (c0_calib_tap_val),

       .calib_tap_load_done              (c0_calib_tap_load_done),

       `else

       .calib_tap_req                    (),

       .calib_tap_load                   (1'b0),

       .calib_tap_addr                   (7'b0),

       .calib_tap_val                    (8'b0),

       .calib_tap_load_done              (1'b0),

       `endif



// Debug logic ports

       .dbg_idel_up_all                  (c0_dbg_idel_up_all),

       .dbg_idel_down_all                (c0_dbg_idel_down_all),

       .dbg_idel_up_cpt                  (c0_dbg_idel_up_cpt),

       .dbg_idel_down_cpt                (c0_dbg_idel_down_cpt),

       .dbg_sel_idel_cpt                 (c0_dbg_sel_idel_cpt),

       .dbg_sel_all_idel_cpt             (c0_dbg_sel_all_idel_cpt),

       .dbg_sel_pi_incdec                (c0_dbg_sel_pi_incdec),

       .dbg_sel_po_incdec                (c0_dbg_sel_po_incdec),

       .dbg_byte_sel                     (c0_dbg_byte_sel),

       .dbg_pi_f_inc                     (c0_dbg_pi_f_inc),

       .dbg_pi_f_dec                     (c0_dbg_pi_f_dec),

       .dbg_po_f_inc                     (c0_dbg_po_f_inc),

       .dbg_po_f_stg23_sel               (c0_dbg_po_f_stg23_sel),

       .dbg_po_f_dec                     (c0_dbg_po_f_dec),

       .dbg_cpt_tap_cnt                  (c0_dbg_cpt_tap_cnt),

       .dbg_dq_idelay_tap_cnt            (c0_dbg_dq_idelay_tap_cnt),

       .dbg_calib_top                    (c0_dbg_calib_top),

       .dbg_cpt_first_edge_cnt           (c0_dbg_cpt_first_edge_cnt),

       .dbg_cpt_second_edge_cnt          (c0_dbg_cpt_second_edge_cnt),

       .dbg_rd_data_offset               (c0_dbg_rd_data_offset),

       .dbg_phy_rdlvl                    (c0_dbg_phy_rdlvl),

       .dbg_phy_wrcal                    (c0_dbg_phy_wrcal),

       .dbg_final_po_fine_tap_cnt        (c0_dbg_final_po_fine_tap_cnt),

       .dbg_final_po_coarse_tap_cnt      (c0_dbg_final_po_coarse_tap_cnt),

       .dbg_rd_data_edge_detect          (c0_dbg_rd_data_edge_detect),

       .dbg_rddata                       (c0_dbg_rddata),

       .dbg_rddata_valid                 (c0_dbg_rddata_valid),

       .dbg_rdlvl_done                   (c0_dbg_rdlvl_done),

       .dbg_rdlvl_err                    (c0_dbg_rdlvl_err),

       .dbg_rdlvl_start                  (c0_dbg_rdlvl_start),

       .dbg_wrlvl_fine_tap_cnt           (c0_dbg_wrlvl_fine_tap_cnt),

       .dbg_wrlvl_coarse_tap_cnt         (c0_dbg_wrlvl_coarse_tap_cnt),

       .dbg_tap_cnt_during_wrlvl         (c0_dbg_tap_cnt_during_wrlvl),

       .dbg_wl_edge_detect_valid         (c0_dbg_wl_edge_detect_valid),

       .dbg_wrlvl_done                   (c0_dbg_wrlvl_done),

       .dbg_wrlvl_err                    (c0_dbg_wrlvl_err),

       .dbg_wrlvl_start                  (c0_dbg_wrlvl_start),

       .dbg_phy_wrlvl                    (c0_dbg_phy_wrlvl),

       .dbg_phy_init                     (c0_dbg_phy_init),

       .dbg_prbs_rdlvl                   (c0_dbg_prbs_rdlvl),

       .dbg_pi_counter_read_val          (c0_dbg_pi_counter_read_val),

       .dbg_po_counter_read_val          (c0_dbg_po_counter_read_val),

       .dbg_prbs_final_dqs_tap_cnt_r     (c0_dbg_prbs_final_dqs_tap_cnt_r_int),

       .dbg_prbs_first_edge_taps         (c0_dbg_prbs_first_edge_taps_int),

       .dbg_prbs_second_edge_taps        (c0_dbg_prbs_second_edge_taps_int),

       .dbg_pi_phaselock_start           (c0_dbg_pi_phaselock_start),

       .dbg_pi_phaselocked_done          (c0_dbg_pi_phaselocked_done),

       .dbg_pi_phaselock_err             (c0_dbg_pi_phaselock_err),

       .dbg_pi_phase_locked_phy4lanes    (c0_dbg_pi_phase_locked_phy4lanes),

       .dbg_pi_dqsfound_start            (c0_dbg_pi_dqsfound_start),

       .dbg_pi_dqsfound_done             (c0_dbg_pi_dqsfound_done),

       .dbg_pi_dqsfound_err              (c0_dbg_pi_dqsfound_err),

       .dbg_pi_dqs_found_lanes_phy4lanes (c0_dbg_pi_dqs_found_lanes_phy4lanes),

       .dbg_calib_rd_data_offset_1       (c0_dbg_calib_rd_data_offset_1),

       .dbg_calib_rd_data_offset_2       (c0_dbg_calib_rd_data_offset_2),

       .dbg_data_offset                  (c0_dbg_data_offset),

       .dbg_data_offset_1                (c0_dbg_data_offset_1),

       .dbg_data_offset_2                (c0_dbg_data_offset_2),

       .dbg_wrcal_start                  (c0_dbg_wrcal_start),

       .dbg_wrcal_done                   (c0_dbg_wrcal_done),

       .dbg_wrcal_err                    (c0_dbg_wrcal_err),

       .dbg_phy_oclkdelay_cal            (c0_dbg_phy_oclkdelay_cal),

       .dbg_oclkdelay_rd_data            (c0_dbg_oclkdelay_rd_data),

       .dbg_oclkdelay_calib_start        (c0_dbg_oclkdelay_calib_start),

       .dbg_oclkdelay_calib_done         (c0_dbg_oclkdelay_calib_done),

       .dbg_dqs_found_cal                (c0_dbg_dqs_found_cal),  

       .init_calib_complete              (c0_init_calib_complete),

       .dbg_poc                          ()

       );



      

  mig_7series_v4_2_memc_ui_top_std #

    (

     .TCQ                              (C1_TCQ),

     .ADDR_CMD_MODE                    (C1_ADDR_CMD_MODE),

     .AL                               (C1_AL),

     .PAYLOAD_WIDTH                    (C1_PAYLOAD_WIDTH),

     .BANK_WIDTH                       (C1_BANK_WIDTH),

     .BM_CNT_WIDTH                     (C1_BM_CNT_WIDTH),

     .BURST_MODE                       (C1_BURST_MODE),

     .BURST_TYPE                       (C1_BURST_TYPE),

     .CA_MIRROR                        (C1_CA_MIRROR),

     .DDR3_VDD_OP_VOLT                 (C1_VDD_OP_VOLT),

     .CK_WIDTH                         (C1_CK_WIDTH),

     .COL_WIDTH                        (C1_COL_WIDTH),

     .CMD_PIPE_PLUS1                   (C1_CMD_PIPE_PLUS1),

     .CS_WIDTH                         (C1_CS_WIDTH),

     .nCS_PER_RANK                     (C1_nCS_PER_RANK),

     .CKE_WIDTH                        (C1_CKE_WIDTH),

     .DATA_WIDTH                       (C1_DATA_WIDTH),

     .DATA_BUF_ADDR_WIDTH              (C1_DATA_BUF_ADDR_WIDTH),

     .DM_WIDTH                         (C1_DM_WIDTH),

     .DQ_CNT_WIDTH                     (C1_DQ_CNT_WIDTH),

     .DQ_WIDTH                         (C1_DQ_WIDTH),

     .DQS_CNT_WIDTH                    (C1_DQS_CNT_WIDTH),

     .DQS_WIDTH                        (C1_DQS_WIDTH),

     .DRAM_TYPE                        (DRAM_TYPE),

     .DRAM_WIDTH                       (C1_DRAM_WIDTH),

     .ECC                              (C1_ECC),

     .ECC_WIDTH                        (C1_ECC_WIDTH),

     .ECC_TEST                         (C1_ECC_TEST),

     .MC_ERR_ADDR_WIDTH                (C1_MC_ERR_ADDR_WIDTH),

     .REFCLK_FREQ                      (REFCLK_FREQ),

     .nAL                              (C1_nAL),

     .nBANK_MACHS                      (C1_nBANK_MACHS),

     .CKE_ODT_AUX                      (C1_CKE_ODT_AUX),

     .nCK_PER_CLK                      (C1_nCK_PER_CLK),

     .ORDERING                         (C1_ORDERING),

     .OUTPUT_DRV                       (C1_OUTPUT_DRV),

     .IBUF_LPWR_MODE                   (C1_IBUF_LPWR_MODE),

     .DATA_IO_IDLE_PWRDWN              (C1_DATA_IO_IDLE_PWRDWN),

     .BANK_TYPE                        (C1_BANK_TYPE),

     .DATA_IO_PRIM_TYPE                (C1_DATA_IO_PRIM_TYPE),

     .IODELAY_GRP0                     (IODELAY_GRP0),

     .IODELAY_GRP1                     (IODELAY_GRP1),

     .FPGA_SPEED_GRADE                 (FPGA_SPEED_GRADE),

     .REG_CTRL                         (C1_REG_CTRL),

     .RTT_NOM                          (C1_RTT_NOM),

     .RTT_WR                           (C1_RTT_WR),

     .CL                               (C1_CL),

     .CWL                              (C1_CWL),

     .tCK                              (C1_tCK),

     .tCKE                             (C1_tCKE),

     .tFAW                             (C1_tFAW),

     .tPRDI                            (C1_tPRDI),

     .tRAS                             (C1_tRAS),

     .tRCD                             (C1_tRCD),

     .tREFI                            (C1_tREFI),

     .tRFC                             (C1_tRFC),

     .tRP                              (C1_tRP),

     .tRRD                             (C1_tRRD),

     .tRTP                             (C1_tRTP),

     .tWTR                             (C1_tWTR),

     .tZQI                             (C1_tZQI),

     .tZQCS                            (C1_tZQCS),

     .USER_REFRESH                     (C1_USER_REFRESH),

     .TEMP_MON_EN                      (TEMP_MON_EN),

     .WRLVL                            (C1_WRLVL),

     .DEBUG_PORT                       (C1_DEBUG_PORT),

     .CAL_WIDTH                        (CAL_WIDTH),

     .RANK_WIDTH                       (C1_RANK_WIDTH),

     .RANKS                            (C1_RANKS),

     .ODT_WIDTH                        (C1_ODT_WIDTH),

     .ROW_WIDTH                        (C1_ROW_WIDTH),

     .ADDR_WIDTH                       (C1_ADDR_WIDTH),

     .APP_DATA_WIDTH                   (C1_APP_DATA_WIDTH),

     .APP_MASK_WIDTH                   (C1_APP_MASK_WIDTH),

     .SIM_BYPASS_INIT_CAL              (C1_SIM_BYPASS_INIT_CAL),

     .BYTE_LANES_B0                    (C1_BYTE_LANES_B0),

     .BYTE_LANES_B1                    (C1_BYTE_LANES_B1),

     .BYTE_LANES_B2                    (C1_BYTE_LANES_B2),

     .BYTE_LANES_B3                    (C1_BYTE_LANES_B3),

     .BYTE_LANES_B4                    (C1_BYTE_LANES_B4),

     .DATA_CTL_B0                      (C1_DATA_CTL_B0),

     .DATA_CTL_B1                      (C1_DATA_CTL_B1),

     .DATA_CTL_B2                      (C1_DATA_CTL_B2),

     .DATA_CTL_B3                      (C1_DATA_CTL_B3),

     .DATA_CTL_B4                      (C1_DATA_CTL_B4),

     .PHY_0_BITLANES                   (C1_PHY_0_BITLANES),

     .PHY_1_BITLANES                   (C1_PHY_1_BITLANES),

     .PHY_2_BITLANES                   (C1_PHY_2_BITLANES),

     .CK_BYTE_MAP                      (C1_CK_BYTE_MAP),

     .ADDR_MAP                         (C1_ADDR_MAP),

     .BANK_MAP                         (C1_BANK_MAP),

     .CAS_MAP                          (C1_CAS_MAP),

     .CKE_ODT_BYTE_MAP                 (C1_CKE_ODT_BYTE_MAP),

     .CKE_MAP                          (C1_CKE_MAP),

     .ODT_MAP                          (C1_ODT_MAP),

     .CS_MAP                           (C1_CS_MAP),

     .PARITY_MAP                       (C1_PARITY_MAP),

     .RAS_MAP                          (C1_RAS_MAP),

     .WE_MAP                           (C1_WE_MAP),

     .DQS_BYTE_MAP                     (C1_DQS_BYTE_MAP),

     .DATA0_MAP                        (C1_DATA0_MAP),

     .DATA1_MAP                        (C1_DATA1_MAP),

     .DATA2_MAP                        (C1_DATA2_MAP),

     .DATA3_MAP                        (C1_DATA3_MAP),

     .DATA4_MAP                        (C1_DATA4_MAP),

     .DATA5_MAP                        (C1_DATA5_MAP),

     .DATA6_MAP                        (C1_DATA6_MAP),

     .DATA7_MAP                        (C1_DATA7_MAP),

     .DATA8_MAP                        (C1_DATA8_MAP),

     .DATA9_MAP                        (C1_DATA9_MAP),

     .DATA10_MAP                       (C1_DATA10_MAP),

     .DATA11_MAP                       (C1_DATA11_MAP),

     .DATA12_MAP                       (C1_DATA12_MAP),

     .DATA13_MAP                       (C1_DATA13_MAP),

     .DATA14_MAP                       (C1_DATA14_MAP),

     .DATA15_MAP                       (C1_DATA15_MAP),

     .DATA16_MAP                       (C1_DATA16_MAP),

     .DATA17_MAP                       (C1_DATA17_MAP),

     .MASK0_MAP                        (C1_MASK0_MAP),

     .MASK1_MAP                        (C1_MASK1_MAP),

     .CALIB_ROW_ADD                    (C1_CALIB_ROW_ADD),

     .CALIB_COL_ADD                    (C1_CALIB_COL_ADD),

     .CALIB_BA_ADD                     (C1_CALIB_BA_ADD),

     .IDELAY_ADJ                       (C1_IDELAY_ADJ),

     .FINE_PER_BIT                     (C1_FINE_PER_BIT),

     .CENTER_COMP_MODE                 (C1_CENTER_COMP_MODE),

     .PI_VAL_ADJ                       (C1_PI_VAL_ADJ),

     .SLOT_0_CONFIG                    (C1_SLOT_0_CONFIG),

     .SLOT_1_CONFIG                    (C1_SLOT_1_CONFIG),

     .MEM_ADDR_ORDER                   (C1_MEM_ADDR_ORDER),

     .STARVE_LIMIT                     (STARVE_LIMIT),

     .USE_CS_PORT                      (C1_USE_CS_PORT),

     .USE_DM_PORT                      (C1_USE_DM_PORT),

     .USE_ODT_PORT                     (C1_USE_ODT_PORT),

     .MASTER_PHY_CTL                   (C1_PHY_CONTROL_MASTER_BANK),

     .TAPSPERKCLK                      (C1_TAPSPERKCLK),

     .SKIP_CALIB                       (SKIP_CALIB),

     .FPGA_VOLT_TYPE                   (C1_FPGA_VOLT_TYPE)

     )

    c1_u_memc_ui_top_std

      (

       .clk                              (c1_clk),

       .clk_div2                         (c1_clk_div2),

       .rst_div2                         (c1_rst_div2),

       .clk_ref                          (clk_ref),

       .mem_refclk                       (c1_mem_refclk), //memory clock

       .freq_refclk                      (c1_freq_refclk),

       .pll_lock                         (c1_pll_locked),

       .sync_pulse                       (c1_sync_pulse),

       .mmcm_ps_clk                      (c1_mmcm_ps_clk),

       .poc_sample_pd                    (c1_poc_sample_pd),

       .psdone                           (c1_psdone),

       .iddr_rst                         (c1_iddr_rst),

       .psen                             (c1_psen),

       .psincdec                         (c1_psincdec),

       .rst                              (c1_rst),

       .rst_phaser_ref                   (c1_rst_phaser_ref),

       .ref_dll_lock                     (c1_ref_dll_lock),



// Memory interface ports

       .ddr_dq                           (c1_ddr3_dq),

       .ddr_dqs_n                        (c1_ddr3_dqs_n),

       .ddr_dqs                          (c1_ddr3_dqs_p),

       .ddr_addr                         (c1_ddr3_addr),

       .ddr_ba                           (c1_ddr3_ba),

       .ddr_cas_n                        (c1_ddr3_cas_n),

       .ddr_ck_n                         (c1_ddr3_ck_n),

       .ddr_ck                           (c1_ddr3_ck_p),

       .ddr_cke                          (c1_ddr3_cke),

       .ddr_cs_n                         (c1_ddr3_cs_n),

       .ddr_dm                           (c1_ddr3_dm),

       .ddr_odt                          (c1_ddr3_odt),

       .ddr_ras_n                        (c1_ddr3_ras_n),

       .ddr_reset_n                      (c1_ddr3_reset_n),

       .ddr_parity                       (c1_ddr3_parity),

       .ddr_we_n                         (c1_ddr3_we_n),

       .bank_mach_next                   (c1_bank_mach_next),



// Application interface ports

       .app_addr                         (c1_app_addr),

       .app_cmd                          (c1_app_cmd),

       .app_en                           (c1_app_en),

       .app_hi_pri                       (1'b0),

       .app_wdf_data                     (c1_app_wdf_data),

       .app_wdf_end                      (c1_app_wdf_end),

       .app_wdf_mask                     (c1_app_wdf_mask),

       .app_wdf_wren                     (c1_app_wdf_wren),

       .app_ecc_multiple_err             (c1_app_ecc_multiple_err),

       .app_ecc_single_err               (c1_app_ecc_single_err),

       .app_rd_data                      (c1_app_rd_data),

       .app_rd_data_end                  (c1_app_rd_data_end),

       .app_rd_data_valid                (c1_app_rd_data_valid),

       .app_rdy                          (c1_app_rdy),

       .app_wdf_rdy                      (c1_app_wdf_rdy),

       .app_sr_req                       (c1_app_sr_req),

       .app_sr_active                    (c1_app_sr_active),

       .app_ref_req                      (c1_app_ref_req),

       .app_ref_ack                      (c1_app_ref_ack),

       .app_zq_req                       (c1_app_zq_req),

       .app_zq_ack                       (c1_app_zq_ack),

       .app_raw_not_ecc                  ({2*C1_nCK_PER_CLK{1'b0}}),

       .app_correct_en_i                 (1'b1),



       .device_temp                      (c1_device_temp_s),



       // skip calibration ports

       `ifdef SKIP_CALIB

       .calib_tap_req                    (c1_calib_tap_req),

       .calib_tap_load                   (c1_calib_tap_load),

       .calib_tap_addr                   (c1_calib_tap_addr),

       .calib_tap_val                    (c1_calib_tap_val),

       .calib_tap_load_done              (c1_calib_tap_load_done),

       `else

       .calib_tap_req                    (),

       .calib_tap_load                   (1'b0),

       .calib_tap_addr                   (7'b0),

       .calib_tap_val                    (8'b0),

       .calib_tap_load_done              (1'b0),

       `endif



// Debug logic ports

       .dbg_idel_up_all                  (c1_dbg_idel_up_all),

       .dbg_idel_down_all                (c1_dbg_idel_down_all),

       .dbg_idel_up_cpt                  (c1_dbg_idel_up_cpt),

       .dbg_idel_down_cpt                (c1_dbg_idel_down_cpt),

       .dbg_sel_idel_cpt                 (c1_dbg_sel_idel_cpt),

       .dbg_sel_all_idel_cpt             (c1_dbg_sel_all_idel_cpt),

       .dbg_sel_pi_incdec                (c1_dbg_sel_pi_incdec),

       .dbg_sel_po_incdec                (c1_dbg_sel_po_incdec),

       .dbg_byte_sel                     (c1_dbg_byte_sel),

       .dbg_pi_f_inc                     (c1_dbg_pi_f_inc),

       .dbg_pi_f_dec                     (c1_dbg_pi_f_dec),

       .dbg_po_f_inc                     (c1_dbg_po_f_inc),

       .dbg_po_f_stg23_sel               (c1_dbg_po_f_stg23_sel),

       .dbg_po_f_dec                     (c1_dbg_po_f_dec),

       .dbg_cpt_tap_cnt                  (c1_dbg_cpt_tap_cnt),

       .dbg_dq_idelay_tap_cnt            (c1_dbg_dq_idelay_tap_cnt),

       .dbg_calib_top                    (c1_dbg_calib_top),

       .dbg_cpt_first_edge_cnt           (c1_dbg_cpt_first_edge_cnt),

       .dbg_cpt_second_edge_cnt          (c1_dbg_cpt_second_edge_cnt),

       .dbg_rd_data_offset               (c1_dbg_rd_data_offset),

       .dbg_phy_rdlvl                    (c1_dbg_phy_rdlvl),

       .dbg_phy_wrcal                    (c1_dbg_phy_wrcal),

       .dbg_final_po_fine_tap_cnt        (c1_dbg_final_po_fine_tap_cnt),

       .dbg_final_po_coarse_tap_cnt      (c1_dbg_final_po_coarse_tap_cnt),

       .dbg_rd_data_edge_detect          (c1_dbg_rd_data_edge_detect),

       .dbg_rddata                       (c1_dbg_rddata),

       .dbg_rddata_valid                 (c1_dbg_rddata_valid),

       .dbg_rdlvl_done                   (c1_dbg_rdlvl_done),

       .dbg_rdlvl_err                    (c1_dbg_rdlvl_err),

       .dbg_rdlvl_start                  (c1_dbg_rdlvl_start),

       .dbg_wrlvl_fine_tap_cnt           (c1_dbg_wrlvl_fine_tap_cnt),

       .dbg_wrlvl_coarse_tap_cnt         (c1_dbg_wrlvl_coarse_tap_cnt),

       .dbg_tap_cnt_during_wrlvl         (c1_dbg_tap_cnt_during_wrlvl),

       .dbg_wl_edge_detect_valid         (c1_dbg_wl_edge_detect_valid),

       .dbg_wrlvl_done                   (c1_dbg_wrlvl_done),

       .dbg_wrlvl_err                    (c1_dbg_wrlvl_err),

       .dbg_wrlvl_start                  (c1_dbg_wrlvl_start),

       .dbg_phy_wrlvl                    (c1_dbg_phy_wrlvl),

       .dbg_phy_init                     (c1_dbg_phy_init),

       .dbg_prbs_rdlvl                   (c1_dbg_prbs_rdlvl),

       .dbg_pi_counter_read_val          (c1_dbg_pi_counter_read_val),

       .dbg_po_counter_read_val          (c1_dbg_po_counter_read_val),

       .dbg_prbs_final_dqs_tap_cnt_r     (c1_dbg_prbs_final_dqs_tap_cnt_r_int),

       .dbg_prbs_first_edge_taps         (c1_dbg_prbs_first_edge_taps_int),

       .dbg_prbs_second_edge_taps        (c1_dbg_prbs_second_edge_taps_int),

       .dbg_pi_phaselock_start           (c1_dbg_pi_phaselock_start),

       .dbg_pi_phaselocked_done          (c1_dbg_pi_phaselocked_done),

       .dbg_pi_phaselock_err             (c1_dbg_pi_phaselock_err),

       .dbg_pi_phase_locked_phy4lanes    (c1_dbg_pi_phase_locked_phy4lanes),

       .dbg_pi_dqsfound_start            (c1_dbg_pi_dqsfound_start),

       .dbg_pi_dqsfound_done             (c1_dbg_pi_dqsfound_done),

       .dbg_pi_dqsfound_err              (c1_dbg_pi_dqsfound_err),

       .dbg_pi_dqs_found_lanes_phy4lanes (c1_dbg_pi_dqs_found_lanes_phy4lanes),

       .dbg_calib_rd_data_offset_1       (c1_dbg_calib_rd_data_offset_1),

       .dbg_calib_rd_data_offset_2       (c1_dbg_calib_rd_data_offset_2),

       .dbg_data_offset                  (c1_dbg_data_offset),

       .dbg_data_offset_1                (c1_dbg_data_offset_1),

       .dbg_data_offset_2                (c1_dbg_data_offset_2),

       .dbg_wrcal_start                  (c1_dbg_wrcal_start),

       .dbg_wrcal_done                   (c1_dbg_wrcal_done),

       .dbg_wrcal_err                    (c1_dbg_wrcal_err),

       .dbg_phy_oclkdelay_cal            (c1_dbg_phy_oclkdelay_cal),

       .dbg_oclkdelay_rd_data            (c1_dbg_oclkdelay_rd_data),

       .dbg_oclkdelay_calib_start        (c1_dbg_oclkdelay_calib_start),

       .dbg_oclkdelay_calib_done         (c1_dbg_oclkdelay_calib_done),

       .dbg_dqs_found_cal                (c1_dbg_dqs_found_cal),  

       .init_calib_complete              (c1_init_calib_complete),

       .dbg_poc                          ()

       );



      









  //*****************************************************************

  // PHY Debug Port Example:

  //  * This provides a limited Chipscope Interface for observing

  //    PHY signals (outputs of read and write timing calibration,

  //    general status, synchronized read data), and a mechanism for

  //    dynamically changing some of the IODELAY elements used to

  //    adjust timing in the read data path.

  //  * This logic supports up to the first 72 DQ and 9 DQS groups.

  //    Larger interfaces will require manual modification and

  //    additional Chipscope blocks to support monitoring of the

  //    additional DQS groups. Smaller interfaces can also obviously

  //    use smaller ILA cores (user will have to generate these

  //    themselves) if resources or timing is a concern

  //*****************************************************************



   // Connect these to VIO if changing output IODELAY taps desired

   // IODELAY taps desired

   assign c0_dbg_idel_down_all    = 1'b0;

   assign c0_dbg_idel_down_cpt    = 1'b0;

   assign c0_dbg_idel_up_all      = 1'b0;

   assign c0_dbg_idel_up_cpt      = 1'b0;

   assign c0_dbg_sel_all_idel_cpt = 1'b0;

   assign c0_dbg_sel_idel_cpt     = 'b0;



   //*******************************************************

   //     - ILA for monitoring basic set of phy signals,

   //       and synchronized read data

   //*******************************************************

   assign c0_dbg_bit                 = c0_ddr3_vio_sync_out[8:0];

   assign c0_dbg_dqs                 = c0_ddr3_vio_sync_out[13:9];



   assign c0_ddr3_ila_basic_int[0]       = c0_init_calib_complete;



   assign c0_ddr3_ila_basic_int[1]       = c0_dbg_wrlvl_start;

   assign c0_ddr3_ila_basic_int[2]       = c0_dbg_wrlvl_done;

   assign c0_ddr3_ila_basic_int[3]       = c0_dbg_wrlvl_err;



   assign c0_ddr3_ila_basic_int[4]       = c0_dbg_pi_phaselock_start;

   assign c0_ddr3_ila_basic_int[5]       = c0_dbg_pi_phaselocked_done;

   assign c0_ddr3_ila_basic_int[6]       = c0_dbg_pi_phaselock_err;



   assign c0_ddr3_ila_basic_int[7]       = c0_dbg_pi_dqsfound_start;

   assign c0_ddr3_ila_basic_int[8]       = c0_dbg_pi_dqsfound_done;

   assign c0_ddr3_ila_basic_int[9]       = c0_dbg_pi_dqsfound_err;



   assign c0_ddr3_ila_basic_int[11:10]   = c0_dbg_rdlvl_start;

   assign c0_ddr3_ila_basic_int[13:12]   = c0_dbg_rdlvl_done;

   assign c0_ddr3_ila_basic_int[15:14]   = c0_dbg_rdlvl_err;



   assign c0_ddr3_ila_basic_int[16]      = c0_dbg_oclkdelay_calib_start;

   assign c0_ddr3_ila_basic_int[17]      = c0_dbg_oclkdelay_calib_done;

   assign c0_ddr3_ila_basic_int[18]      = 1'b0;



   assign c0_ddr3_ila_basic_int[19]      = c0_dbg_wrcal_start;

   assign c0_ddr3_ila_basic_int[20]      = c0_dbg_wrcal_done;

   assign c0_ddr3_ila_basic_int[21]      = c0_dbg_wrcal_err;



   assign c0_ddr3_ila_basic_int[27:22]   = c0_dbg_phy_init[5:0];

   assign c0_ddr3_ila_basic_int[28]      = c0_dbg_rddata_valid_r;

   assign c0_ddr3_ila_basic_int[29+:64]  = c0_dbg_rddata_r;



   // additional signals required for debug

   assign c0_ddr3_ila_basic_int[93]      = c0_dbg_dqs_found_cal[14]; // fine_adjust_done_r

   assign c0_ddr3_ila_basic_int[119:94]  = 'b0;



   always @(posedge c0_clk) begin

     c0_dbg_rddata_valid_r <= c0_dbg_rddata_valid;

   end



   always @(posedge c0_clk) begin

     c0_dbg_rddata_r[7:0]   <= #C0_TCQ c0_dbg_rddata[(8*c0_dbg_dqs)+:8];

     c0_dbg_rddata_r[15:8]  <= #C0_TCQ c0_dbg_rddata[(8*c0_dbg_dqs)+C0_DQ_WIDTH+:8];

     c0_dbg_rddata_r[23:16] <= #C0_TCQ c0_dbg_rddata[(8*c0_dbg_dqs)+2*C0_DQ_WIDTH+:8];

     c0_dbg_rddata_r[31:24] <= #C0_TCQ c0_dbg_rddata[(8*c0_dbg_dqs)+3*C0_DQ_WIDTH+:8];

     c0_dbg_rddata_r[39:32] <= #C0_TCQ (C0_nCK_PER_CLK == 2 && C0_DQ_WIDTH == 8) ? 8'h0 :

                                  c0_dbg_rddata[(8*c0_dbg_dqs)+4*C0_DQ_WIDTH+:8];

     c0_dbg_rddata_r[47:40] <= #C0_TCQ (C0_nCK_PER_CLK == 2 && C0_DQ_WIDTH == 8) ? 8'h0 :

                                  c0_dbg_rddata[(8*c0_dbg_dqs)+5*C0_DQ_WIDTH+:8];

     c0_dbg_rddata_r[55:48] <= #C0_TCQ (C0_nCK_PER_CLK == 2 && C0_DQ_WIDTH == 8) ? 8'h0 :

                                  c0_dbg_rddata[(8*c0_dbg_dqs)+6*C0_DQ_WIDTH+:8];

     c0_dbg_rddata_r[63:56] <= #C0_TCQ (C0_nCK_PER_CLK == 2 && C0_DQ_WIDTH == 8) ? 8'h0 :

                                  c0_dbg_rddata[(8*c0_dbg_dqs)+7*C0_DQ_WIDTH+:8];

   end



   //*******************************************************

   //     - ILA for monitoring write path signals,

   //       and synchronized read data

   //*******************************************************



   assign c0_rd_data_edge_detect_r     = c0_dbg_phy_wrlvl[67+:9];

   assign c0_wl_po_fine_cnt            = c0_dbg_phy_wrlvl[76+:54];

   assign c0_wl_po_coarse_cnt          = c0_dbg_phy_wrlvl[130+:27];



   // write-leveling calibration debug data

   assign c0_ddr3_ila_wrpath_int[0+:5]     = c0_dbg_phy_wrlvl [27+:5]; // wl_state_r

   assign c0_ddr3_ila_wrpath_int[6+:4]     = c0_dbg_phy_wrlvl [32+:4]; // dqs_cnt_r

   assign c0_ddr3_ila_wrpath_int[10]       = c0_dbg_phy_wrlvl[60]; // wl_edge_detect_valid_r

   assign c0_ddr3_ila_wrpath_int[11]       = c0_rd_data_edge_detect_r[c0_dbg_dqs];

   assign c0_ddr3_ila_wrpath_int[12+:6]    = c0_wl_po_fine_cnt[(c0_dbg_dqs*6)+:6];

   assign c0_ddr3_ila_wrpath_int[18+:3]    = c0_wl_po_coarse_cnt[(c0_dbg_dqs*3)+:3];

   assign c0_ddr3_ila_wrpath_int[21+:6]    = c0_dbg_phy_wrlvl[61+:6]; //wl_tap_count_r;

   assign c0_ddr3_ila_wrpath_int[29:27]    = 'b0; // reserved

   assign c0_ddr3_ila_wrpath_int[336:310]  = c0_dbg_final_po_coarse_tap_cnt[((C0_DQS_WIDTH*3)-1):0];

   assign c0_ddr3_ila_wrpath_int[390:337]  = c0_dbg_final_po_fine_tap_cnt[((C0_DQS_WIDTH*6)-1):0];



   // oclk delay calibration debug data

   assign c0_ocal_tap_cnt              = c0_dbg_phy_oclkdelay_cal [53+:54];       // final_stg3_tap_count // 54

   assign c0_ddr3_ila_wrpath_int[ 30+: 4]  = c0_dbg_phy_oclkdelay_cal[  0+: 4];  // ocal flag info for edges        // 4

   assign c0_ddr3_ila_wrpath_int[ 34+: 6]  = c0_dbg_phy_oclkdelay_cal[  4+: 6];  // fuzz2oneeighty                  // 6

   assign c0_ddr3_ila_wrpath_int[ 40+: 6]  = c0_dbg_phy_oclkdelay_cal[ 10+: 6];  // fuzz2zero                       // 6

   assign c0_ddr3_ila_wrpath_int[ 46+: 6]  = c0_dbg_phy_oclkdelay_cal[ 16+: 6];  // oneeighty2fuzz                  // 6

   assign c0_ddr3_ila_wrpath_int[ 52+: 6]  = c0_dbg_phy_oclkdelay_cal[ 22+: 6];  // zero2fuzz                       // 6

   assign c0_ddr3_ila_wrpath_int[ 58+: 3]  = c0_dbg_phy_oclkdelay_cal[ 28+: 3];  // oclkdelay_calib_cnt             // 3

   assign c0_ddr3_ila_wrpath_int[ 61+: 1]  = c0_dbg_phy_oclkdelay_cal[107+: 1];  // ocal_scan_win_not_found         // 1

   assign c0_ddr3_ila_wrpath_int[ 62+: 1]  = c0_dbg_phy_oclkdelay_cal[ 32+: 1];  // lim_done                        // 1

   assign c0_ddr3_ila_wrpath_int[241+: 6]  = c0_dbg_phy_oclkdelay_cal[ 33+: 6];  // lim2ocal_stg3_left_lim          // 6

   assign c0_ddr3_ila_wrpath_int[247+: 6]  = c0_dbg_phy_oclkdelay_cal[ 39+: 6];  // lim2ocal_stg3_right_lim         // 6

   assign c0_ddr3_ila_wrpath_int[253+: 1]  = c0_dbg_phy_oclkdelay_cal[108+: 1];  // oclkdelay_center_calib_start    // 1

   assign c0_ddr3_ila_wrpath_int[254+: 1]  = c0_dbg_phy_oclkdelay_cal[109+: 1];  // oclkdelay_center_calib_done     // 1

   assign c0_ddr3_ila_wrpath_int[255+:54]  = c0_dbg_phy_oclkdelay_cal[ 53+:54];  // final_stg3_tap_count            // 54

   assign c0_ddr3_ila_wrpath_int[ 87+: 6]  = c0_dbg_phy_oclkdelay_cal[110+: 6];  // oclkdelay_calib_stg3            // 6

   assign c0_ddr3_ila_wrpath_int[309+: 1]  = 'b0; // reserved



   // write calibration stage debug signals

   assign c0_ddr3_ila_wrpath_int[64]       = c0_dbg_phy_wrcal[0]; // pat_data_match_r

   assign c0_ddr3_ila_wrpath_int[65]       = c0_dbg_phy_wrcal[8]; // pat_data_match_valid_r

   assign c0_ddr3_ila_wrpath_int[66+:4]    = c0_dbg_phy_wrcal[13+:C0_DQS_CNT_WIDTH]; // wrcal_dqs_cnt_r

   assign c0_ddr3_ila_wrpath_int[70+:5]    = c0_dbg_phy_wrcal[5:1]; // cal2_state_r

   assign c0_ddr3_ila_wrpath_int[75+:5]    = c0_dbg_phy_wrcal[21:17]; // not_empty_wait_cnt

   assign c0_ddr3_ila_wrpath_int[80]       = c0_dbg_phy_wrcal[22]; // early1_data

   assign c0_ddr3_ila_wrpath_int[81]       = c0_dbg_phy_wrcal[23]; // early2_data

   assign c0_ddr3_ila_wrpath_int[82]       = c0_dbg_phy_wrcal[88]; // early1_data_match_r

   assign c0_ddr3_ila_wrpath_int[83]       = c0_dbg_phy_wrcal[89]; // early2_data_match_r

   assign c0_ddr3_ila_wrpath_int[84]       = c0_dbg_phy_wrcal[90]; // wrcal_sanity_chk_r and pat_data_match_valid_r

   assign c0_ddr3_ila_wrpath_int[85]       = c0_dbg_phy_wrcal[91]; // wrcal_sanity_chk_r

   assign c0_ddr3_ila_wrpath_int[86]       = c0_dbg_phy_wrcal[92]; // wrcal_sanity_chk_done

   assign c0_ddr3_ila_wrpath_int[93+:3]    = 'b0; // reserved



   assign c0_ddr3_ila_wrpath_int[96+:54]   = c0_dbg_phy_wrlvl[76+:54];

   assign c0_ddr3_ila_wrpath_int[150+:27]  = c0_dbg_phy_wrlvl[130+:27];



   assign c0_ddr3_ila_wrpath_int[177+:8]   = c0_dbg_phy_wrcal[31:24]; // mux_rd_rise0_r

   assign c0_ddr3_ila_wrpath_int[185+:8]   = c0_dbg_phy_wrcal[39:32]; // mux_rd_fall0_r

   assign c0_ddr3_ila_wrpath_int[193+:8]   = c0_dbg_phy_wrcal[47:40]; // mux_rd_rise1_r

   assign c0_ddr3_ila_wrpath_int[201+:8]   = c0_dbg_phy_wrcal[55:48]; // mux_rd_fall1_r

   assign c0_ddr3_ila_wrpath_int[209+:8]   = c0_dbg_phy_wrcal[63:56]; // mux_rd_rise2_r

   assign c0_ddr3_ila_wrpath_int[217+:8]   = c0_dbg_phy_wrcal[71:64]; // mux_rd_fall2_r

   assign c0_ddr3_ila_wrpath_int[225+:8]   = c0_dbg_phy_wrcal[79:72]; // mux_rd_rise3_r

   assign c0_ddr3_ila_wrpath_int[233+:8]   = c0_dbg_phy_wrcal[87:80]; // mux_rd_fall3_r







   //*******************************************************

   //     - ILA for monitoring read path signals,

   //       and synchronized read data

   //*******************************************************



   // PHASER_IN debug signals

   assign c0_ddr3_ila_rdpath_int[0+:12]    = c0_dbg_pi_phase_locked_phy4lanes;

   assign c0_ddr3_ila_rdpath_int[12+:12]   = c0_dbg_pi_dqs_found_lanes_phy4lanes;

   assign c0_ddr3_ila_rdpath_int[24+:12]   = c0_dbg_rd_data_offset;

   assign c0_ddr3_ila_rdpath_int[39:36]    = 'b0; //reserved



   // read-leveling calibration debug data

   assign c0_ddr3_ila_rdpath_int[40+:6]    = c0_dbg_phy_rdlvl[14:9]; // cal1_state_r

   assign c0_ddr3_ila_rdpath_int[46+:4]    = c0_dbg_phy_rdlvl[64:61]; // cal1_cnt_cpt_r

   assign c0_ddr3_ila_rdpath_int[50+:8]    = c0_dbg_phy_rdlvl[177:170]; // mux_rd_rise0_r

   assign c0_ddr3_ila_rdpath_int[58+:8]    = c0_dbg_phy_rdlvl[185:178]; // mux_rd_fall0_r

   assign c0_ddr3_ila_rdpath_int[66+:8]    = c0_dbg_phy_rdlvl[193:186]; // mux_rd_rise1_r

   assign c0_ddr3_ila_rdpath_int[74+:8]    = c0_dbg_phy_rdlvl[201:194]; // mux_rd_fall1_r

   assign c0_ddr3_ila_rdpath_int[82+:8]    = c0_dbg_phy_rdlvl[209:202]; // mux_rd_rise2_r

   assign c0_ddr3_ila_rdpath_int[90+:8]    = c0_dbg_phy_rdlvl[217:210]; // mux_rd_fall2_r

   assign c0_ddr3_ila_rdpath_int[98+:8]    = c0_dbg_phy_rdlvl[225:218]; // mux_rd_rise3_r

   assign c0_ddr3_ila_rdpath_int[106+:8]   = c0_dbg_phy_rdlvl[233:226]; // mux_rd_fall3_r

   assign c0_ddr3_ila_rdpath_int[114]      = c0_dbg_phy_rdlvl[1]; // pat_data_match_r

   assign c0_ddr3_ila_rdpath_int[115]      = c0_dbg_phy_rdlvl[2]; // mux_rd_valid_r

   assign c0_ddr3_ila_rdpath_int[116+:6]   = c0_dbg_cpt_first_edge_cnt[(c0_dbg_dqs*6)+:6];

   assign c0_ddr3_ila_rdpath_int[122+:6]   = c0_dbg_cpt_second_edge_cnt[(c0_dbg_dqs*6)+:6];

   assign c0_ddr3_ila_rdpath_int[128+:6]   = c0_dbg_cpt_tap_cnt[(c0_dbg_dqs*6)+:6];

   assign c0_ddr3_ila_rdpath_int[134+:5]   = c0_dbg_dq_idelay_tap_cnt[(c0_dbg_dqs*5)+:5];

   assign c0_ddr3_ila_rdpath_int[163:139]  = 'b0;



   // data offset values for PHASER_IN

   assign c0_ddr3_ila_rdpath_int[164+:12]  = c0_dbg_calib_rd_data_offset_1;

   assign c0_ddr3_ila_rdpath_int[176+:12]  = c0_dbg_calib_rd_data_offset_2;

   assign c0_ddr3_ila_rdpath_int[188+:6]   = c0_dbg_data_offset;

   assign c0_ddr3_ila_rdpath_int[194+:6]   = c0_dbg_data_offset_1;

   assign c0_ddr3_ila_rdpath_int[200+:6]   = c0_dbg_data_offset_2;

   assign c0_ddr3_ila_rdpath_int[206+:108] = c0_dbg_cpt_first_edge_cnt;

   assign c0_ddr3_ila_rdpath_int[314+:108] = c0_dbg_cpt_second_edge_cnt;

   assign c0_ddr3_ila_rdpath_int[422+:108] = c0_dbg_cpt_tap_cnt;

   assign c0_ddr3_ila_rdpath_int[530+:90]  = c0_dbg_dq_idelay_tap_cnt;

   assign c0_ddr3_ila_rdpath_int[620+:255] = c0_dbg_prbs_rdlvl;



   always @ (*)

   begin

      c0_ddr3_ila_wrpath   = 'h0;

      c0_ddr3_ila_wrpath   = c0_ddr3_ila_wrpath_int;

   end



   always @ (*)

   begin

      c0_ddr3_ila_rdpath   = 'h0;

      c0_ddr3_ila_rdpath   = c0_ddr3_ila_rdpath_int;

   end



   always @ (*)

   begin

      c0_ddr3_ila_basic    = 'h0;

      c0_ddr3_ila_basic    = c0_ddr3_ila_basic_int;

   end



   always @ (*) begin

     c0_dbg_prbs_final_dqs_tap_cnt_r = 'h0;

     c0_dbg_prbs_final_dqs_tap_cnt_r[(6*C0_DQS_WIDTH*C0_RANKS)-1:0] = c0_dbg_prbs_final_dqs_tap_cnt_r_int;

   end



   always @ (*) begin

     c0_dbg_prbs_first_edge_taps = 'h0;

     c0_dbg_prbs_first_edge_taps[(6*C0_DQS_WIDTH*C0_RANKS)-1:0] = c0_dbg_prbs_first_edge_taps_int;

   end



   always @ (*) begin

     c0_dbg_prbs_second_edge_taps = 'h0;

     c0_dbg_prbs_second_edge_taps[(6*C0_DQS_WIDTH*C0_RANKS)-1:0] = c0_dbg_prbs_second_edge_taps_int;

   end



   

   //*********************************************************************

   // Resetting all RTL debug inputs as the debug ports are not enabled

   //*********************************************************************

   assign c1_dbg_idel_down_all    = 1'b0;

   assign c1_dbg_idel_down_cpt    = 1'b0;

   assign c1_dbg_idel_up_all      = 1'b0;

   assign c1_dbg_idel_up_cpt      = 1'b0;

   assign c1_dbg_sel_all_idel_cpt = 1'b0;

   assign c1_dbg_sel_idel_cpt     = 'b0;

   assign c1_dbg_byte_sel         = 'd0;

   assign c1_dbg_sel_pi_incdec    = 1'b0;

   assign c1_dbg_pi_f_inc         = 1'b0;

   assign c1_dbg_pi_f_dec         = 1'b0;

   assign c1_dbg_po_f_inc         = 'b0;

   assign c1_dbg_po_f_dec         = 'b0;

   assign c1_dbg_po_f_stg23_sel   = 'b0;

   assign c1_dbg_sel_po_incdec    = 'b0;



      



endmodule




