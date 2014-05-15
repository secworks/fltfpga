//======================================================================
//
// fltfpga.v
// ---------
// Top level wrapper for the fltfpga design.
// The fltfpga (FairLight FPGA) is an attempt at implementing a
// demo system om the TerasIC C5G development board using the
// board HDMI and AC97 interfaces for graphics and sound.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014, Secworks Sweden AB
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or 
// without modification, are permitted provided that the following 
// conditions are met: 
// 
// 1. Redistributions of source code must retain the above copyright 
//    notice, this list of conditions and the following disclaimer. 
// 
// 2. Redistributions in binary form must reproduce the above copyright 
//    notice, this list of conditions and the following disclaimer in 
//    the documentation and/or other materials provided with the 
//    distribution. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module fltfpga(
               // Clock and reset.
               input wire           clk,
               input wire           reset_n,

               // Board I2C interface.
               output wire           hdmi_i2c_clk,
               input wire            hdmi_i2c_data_in,
               output wire           hdmi_i2c_data_out,
               
               // HDMI interface.
               input wire            hdmi_tx_int,
               output wire [23 : 0]  hdmi_tdx,
               output wire           hdmi_tx_clk,
               output wire           hdmi_tx_data_en,
               output wire           hdmi_tx_vsync,
               output wire           hdmi_tx_hsync,
               output wire           hdmi_tx_de,

               // I2C interface
               input wire           scl_in,
               output wire          scl_out,
               input wire           sda_in,
               output wire          sda_out,

               // AC97 interface.
               
               // LED interface.
               output wire [7 : 0]   led,

               // button interface.
               input wire            button0,
               input wire            button1,

               // USB-UART interface.
               input wire          uart_rxd,
               output wire         uart_txd
              );

  
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter AUDIO_I2C_ADDR = 8'h42;
  parameter HDMI_I2C_ADDR  = 8'h43;

  
  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------

  
  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  
  
  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------

  
             
  //----------------------------------------------------------------
  // core instantiations.
  //----------------------------------------------------------------
  
  
  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with synchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin
      if (!reset_n)
        begin

        end
      else
        begin
          
        end
    end // reg_update

endmodule // fltfpga

//======================================================================
// EOF fltfpga.v
//======================================================================
