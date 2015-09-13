//======================================================================
//
// fltcpu_alu.v
// ----------------
// Arithmetic and Logic Unit (ALU) in the cpu. This is where the
// operations are performed.
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

module fltcpu_alu(
                  input wire           clk,
                  input wire           reset_n,

                  input wire [5 : 0]   opcode,

                  input wire [31 : 0]  src0_data,
                  input wire [31 : 0]  src1_data,
                  output wire [31 : 0] dst_data,

                  output wire          eq_data
                 );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam OPCODE_BRK = 6'h00;

  localparam OPCODE_AND = 6'h01;
  localparam OPCODE_OR  = 6'h02;
  localparam OPCODE_XOR = 6'h03;
  localparam OPCODE_NOT = 6'h04;

  localparam OPCODE_ADD = 6'h08;
  localparam OPCODE_SUB = 6'h09;

  localparam OPCODE_ASL = 6'h10;
  localparam OPCODE_ROL = 6'h11;
  localparam OPCODE_ASR = 6'h12;
  localparam OPCODE_ROR = 6'h13;

  localparam OPCODE_CMP = 6'h20;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0] tmp_dst_data;
  reg          tmp_dst_we;

  reg          tmp_eq_data;
  reg          tmp_eq_we;

  wire [4 : 0] shamt;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign dst_data = tmp_dst_data;
  assign shamt    = src1_data[4 : 0];


  //----------------------------------------------------------------
  // alu
  //
  // The alu logic.
  //----------------------------------------------------------------
  always @*
    begin : alu
      // Default assignments
      tmp_dst_data = 32'h00000000;

      case (opcode)
        OPCODE_BRK:

        OPCODE_AND:
          tmp_dst_data = src0_data && src1_data;

        OPCODE_OR:
          tmp_dst_data = src0_data || src1_data;

        OPCODE_XOR:
          tmp_dst_data = src0_data ^ src1_data;

        OPCODE_NOT:
          tmp_dst_data = !src0_data;

        OPCODE_ADD:
          tmp_dst_data = src0_data + src1_data;

        OPCODE_SUB:
          tmp_dst_data = src0_data - src1_data;

        OPCODE_ASL:
          tmp_dst_data = 32'h00000000;

        OPCODE_ROL:
          tmp_dst_data = 32'h00000000;

        OPCODE_ASR:
          tmp_dst_data = 32'h00000000;

        OPCODE_ROR:
          tmp_dst_data = 32'h00000000;

        OPCODE_CMP:
          tmp_dst_data = 32'h00000000;

        default:
          begin
          end
      endcase // case (opcode)
    end // alu

endmodule // fltcpu_alu

//======================================================================
// EOF fltcpu_alu.v
//======================================================================
