//======================================================================
//
// fltcpu_regfile.v
// ----------------
// This file contains the implementation of all API registers. This
// includes program counter (PC) and status registers.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2015 Secworks Sweden AB
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

module fltcpu_regfile(
                      // Clock and reset.
                      input wire           clk,
                      input wire           reset_n,

                      // Main operands.
                      input wire [4 : 0]   src0_addr,
                      output wire [31 : 0] src0_data,

                      input wire [4 : 0]   src1_addr,
                      output wire [31 : 0] src1_data,

                      input wire           dst_we,
                      input wire [4 : 0]   dst_addr,
                      output wire [31 : 0] dst_data,

                      // Flags.
                      output wire          zero_flag,

                      // Program counter.
                      input                update,
                      input wire           return,
                      output wire [31 : 0] pc
                     );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam BOOT_VECTOR = 32'h00000000;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [31 : 0] gp_reg [0 : 28];
  reg          gp_we;

  reg [31 : 0] status_reg;

  reg [31 : 0] return_reg;
  reg          return_we;

  reg [31 : 0] pc_reg;
  reg [31 : 0] pc_new;
  reg          pc_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0] tmp_src0_data;
  reg [31 : 0] tmp_src1_data;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign src0_data = tmp_src0_data;
  assign src1_data = tmp_src1_data;
  assign pc        = pc_reg;


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          gp_reg[00] <= 32'h00000000;
          gp_reg[01] <= 32'h00000000;
          gp_reg[02] <= 32'h00000000;
          gp_reg[03] <= 32'h00000000;
          gp_reg[04] <= 32'h00000000;
          gp_reg[05] <= 32'h00000000;
          gp_reg[06] <= 32'h00000000;
          gp_reg[07] <= 32'h00000000;
          gp_reg[08] <= 32'h00000000;
          gp_reg[09] <= 32'h00000000;
          gp_reg[10] <= 32'h00000000;
          gp_reg[11] <= 32'h00000000;
          gp_reg[12] <= 32'h00000000;
          gp_reg[13] <= 32'h00000000;
          gp_reg[14] <= 32'h00000000;
          gp_reg[15] <= 32'h00000000;
          gp_reg[16] <= 32'h00000000;
          gp_reg[17] <= 32'h00000000;
          gp_reg[18] <= 32'h00000000;
          gp_reg[19] <= 32'h00000000;
          gp_reg[20] <= 32'h00000000;
          gp_reg[21] <= 32'h00000000;
          gp_reg[22] <= 32'h00000000;
          gp_reg[23] <= 32'h00000000;
          gp_reg[24] <= 32'h00000000;
          gp_reg[25] <= 32'h00000000;
          gp_reg[26] <= 32'h00000000;
          gp_reg[27] <= 32'h00000000;
          gp_reg[28] <= 32'h00000000;

          status_reg <= 32'h00000000;
          return_reg <= 32'h00000000;
          pc_reg     <= BOOT_VECTOR;
        end
      else
        begin
          if (gp_we)
            gp_reg[dst_addr] <= dst_data;

          if (pc_we)
            pc_reg <= pc_new;

          if (return_we)
            return_reg <= pc_reg;
        end
    end // reg_update


  //----------------------------------------------------------------
  // read_src0
  //
  // Combinational read of operand source 0.
  //----------------------------------------------------------------
  always @*
    begin : read_src0
      if (src0_addr < 28)
        tmp_src0_data = gp_reg[src0_addr];

      else if (src0_addr == 29)
        tmp_src0_data = status_reg;

      else if (src0_addr == 30)
        tmp_src0_data = return_reg;

      else if (src0_addr == 31)
        tmp_src0_data = pc_reg;
    end // read_src0


  //----------------------------------------------------------------
  // read_src1
  //
  // Combinational read of operand source 1.
  //----------------------------------------------------------------
  always @*
    begin : read_src1
      if (src1_addr < 28)
        tmp_src1_data = gp_reg[src1_addr];

      else if (src1_addr == 29)
        tmp_src0_data = status_reg;

      else if (src1_addr == 30)
        tmp_src1_data = return_reg;

      else if (src1_addr == 31)
        tmp_src1_data = pc_reg;
    end // read_src1


  //----------------------------------------------------------------
  // pc_update
  //
  // Update logic for the program counter. The update supports
  // direct writes to the PC (i.e. jumps), return and simple
  // increments.
  //----------------------------------------------------------------
  always @*
    begin : pc_update
      return_we = 0;
      pc_new    = 32'h00000000
      pc_we     = 0;

      if (dst_we && (dst_addr == 31))
        begin
          return_we = 1;
          pc_new    = dst_data;
          pc_we     = 1;
        end

      else if (return)
        begin
          pc_new = return_reg;
          pc_we  = 1;
        end

      else if (update)
        begin
          pc_new = pc_reg + 1'b1;
          pc_we  = 1;
        end
    end // pc_update

endmodule // fltcpu_regfile

//======================================================================
// EOF fltcpu_regfile.v
//======================================================================