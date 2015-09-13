//======================================================================
//
// fltcpu.v
// --------
// Top level file of the fltfpga cpu.
//
// Instruction format:
// [31 : 26] 6 bit opcode.
// [25 : 21] 5 bit destination reg if present.
// [20 : 16] 5 bit source reg 0 if present
// [15 : 11] 5 bit source reg 1 if present
//           5 bit shift amount if present
// [15 : 0]  16 bit immediate if present
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

module fltcpu(
              // Clock and reset.
              input wire           clk,
              input wire           reset_n,

              output wire          mem_cs
              output wire          mem_we
              output wire [31 : 0] mem_address,
              output wire [31 : 0] mem_data
             );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam FLTCPU_IDLE = 4'h0;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [31 : 0] instruction_reg;
  reg          instruction_we;

  reg [3 : 0]  fltcpu_ctrl_reg;
  reg [3 : 0]  fltcpu_ctrl_new;
  reg          fltcpu_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire [5 : 0]  opcode;

  wire [4 : 0]  dest_addr;
  wire [31 : 0] dest_data;
  reg           dest_we;

  wire [4 : 0]  source0_addr;
  wire [31 : 0] source0_data;

  wire [4 : 0]  source1_addr;
  wire [31 : 0] source1_data;

  wire [15 : 0] constant;

  reg           inc_pc;
  reg           ret_pc;
  wire [31 : 0] pc;

  wire          zero_flag;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign mem_cs      = 0;
  assign mem_we      = 0;
  assign mem_address = 32'h00000000;
  assign mem_data    = 32'h00000000;

  assign opcode       = instruction_reg[31 : 26];
  assign dest_addr    = instruction_reg[25 : 21];
  assign source0_addr = instruction_reg[20 : 16];
  assign source1_addr = instruction_reg[15 : 11];
  assign constant     = instruction_reg[15 : 00];


  //----------------------------------------------------------------
  // Instantiations.
  //----------------------------------------------------------------
  fltcpu_regfile regfile(
                         .clk(clk),
                         .reset_n(reset_n),

                         .src0_addr(source0_addr),
                         .src0_data(source0_data),

                         .src1_addr(source1_addr),
                         .src1_data(source1_data),

                         .dst_we(dest_we),
                         .dst_addr(dest_addr),
                         .dst_data(dest_data),

                         .zero_flag(zero_flag),

                         .inc(inc_pc),
                         .return(ret_pc),
                         .pc(pc)
                        );

  fltcpu_alu alu(
                 .clk(clk),
                 .reset_n(reset_n),

                 .opcode(opcode),

                 .src0_addr(),
                 .src0_data(source0_data),

                 .src1_addr(),
                 .src1_data(),

                 .mem_cs(),
                 .mem_we(),
                 .mem_addr(),

                 .eq_data(),
                 .eq_we(),

                 .dst_we(),
                 .dst_addr(),
                 .dst_data(),
                );


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
          instruction_reg <= 32'h00000000;
          fltcpu_ctrl_reg <= FLTCPU_IDLE;
        end
      else
        begin
          if (instruction_we)
            instruction_reg <= mem_data;

          if (fltcpu_ctrl_we)
            fltcpu_ctrl_reg <= fltcpu_ctrl_new;
        end
    end // reg_update


  //----------------------------------------------------------------
  // select_operands
  //
  // Select the operands used during operations. This mainly
  // relates to source1 since it will be replaced by a zero
  // extended constant for operations that uses them.
  //----------------------------------------------------------------
  always @*
    begin : select_operands

    end // select_operands

  //----------------------------------------------------------------
  // fltcpu_ctrl
  //
  // Main control FSM of the CPU.
  //----------------------------------------------------------------
  always @*
    begin : fltcpu_ctrl
      fltcpu_ctrl_new = FLTCPU_IDLE;
      fltcpu_ctrl_we  = 0;

      case (fltcpu_ctrl_reg)
        FLTCPU_IDLE:
          begin
          end

        default:
          begin
          end
      endcase // case (fltcpu_ctrl_reg)
    end // fltcpu_ctrl

endmodule // fltcpu

//======================================================================
// EOF fltcpu.v
//======================================================================
