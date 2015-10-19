//======================================================================
//
// fltcpu.v
// --------
// Top level file of the fltfpga cpu.
//
// For instruction format and details of the CPU see the
// fltcpu.md document.
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

              output wire          mem_cs,
              output wire [3 : 0]  mem_we,
              output wire [31 : 0] mem_address,
              input wire [31 : 0]  mem_rd_data,
              output wire [31 : 0] mem_wr_data
             );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  // Control states.
  localparam CTRL_IDLE        = 4'h0;
  localparam CTRL_INSTR_READ  = 4'h1;
  localparam CTRL_INSTR_WAIT  = 4'h2;
  localparam CTRL_INSTR_STORE = 4'h3;
  localparam CTRL_INSTR_EXE0  = 4'h4;
  localparam CTRL_MEM_WRITE   = 4'h5;
  localparam CTRL_MEM_READ    = 4'h6;
  localparam CTRL_MEM_WAIT    = 4'h7;
  localparam CTRL_INSTR_EXE1  = 4'h8;
  localparam CTRL_INSTR_DONE  = 4'h9;
  localparam CTRL_IRQ_START   = 4'hc;
  localparam CTRL_IRQ_DECODE  = 4'hd;
  localparam CTRL_IRQ_DONE    = 4'he;


  // Opcodes.
  localparam OP_BRK  = 6'h00;
  localparam OP_NOP  = 6'h01;
  localparam OP_EXE  = 6'h02;
  localparam OP_AND  = 6'h04;
  localparam OP_OR   = 6'h05;
  localparam OP_XOR  = 6'h06;
  localparam OP_NOT  = 6'h07;
  localparam OP_ADD  = 6'h08;
  localparam OP_ADDI = 6'h09;
  localparam OP_SUB  = 6'h0a;
  localparam OP_SUBI = 6'h0b;
  localparam OP_MUL  = 6'h0c;
  localparam OP_MULI = 6'h0d;
  localparam OP_ASL  = 6'h10;
  localparam OP_ASLI = 6'h11;
  localparam OP_ASR  = 6'h12;
  localparam OP_ASRI = 6'h13;
  localparam OP_ROL  = 6'h14;
  localparam OP_ROLI = 6'h15;
  localparam OP_ROR  = 6'h16;
  localparam OP_RORI = 6'h17;
  localparam OP_RD   = 6'h20;
  localparam OP_RDI  = 6'h21;
  localparam OP_RDC  = 6'h22;
  localparam OP_WR   = 6'h28;
  localparam OP_WRI  = 6'h29;
  localparam OP_MV   = 6'h2a;
  localparam OP_CMP  = 6'h30;
  localparam OP_CMPI = 6'h31;
  localparam OP_BEQ  = 6'h32;
  localparam OP_BEQI = 6'h33;
  localparam OP_BNEI = 6'h35;
  localparam OP_JSR  = 6'h38;
  localparam OP_JSRI = 6'h39;
  localparam OP_JMP  = 6'h3a;
  localparam OP_JMPI = 6'h3b;
  localparam OP_RTS  = 6'h3f;

  // Instruction types.
  localparam ITYPE_REG_REG = 2'h0;
  localparam ITYPE_MEM_RD  = 2'h1;
  localparam ITYPE_MEM_WR  = 2'h2;
  localparam ITYPE_MEM_JMP = 2'h3;


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

  wire [4 : 0]  dst_addr;
  wire [31 : 0] dst_wr_data;
  wire [31 : 0] dst_rd_data;
  reg           dst_we;

  wire [4 : 0]  source0_addr;
  wire [31 : 0] source0_data;

  wire [4 : 0]  source1_addr;
  wire [31 : 0] source1_data;

  wire [15 : 0] constant;

  reg           inc_pc;
  reg           ret_pc;
  wire [31 : 0] pc;

  wire          zero_flag;
  wire          eq_data;

  reg [1 : 0]   instr_type;

  reg           tmp_mem_cs;
  reg [3 : 0]   tmp_mem_we;
  reg [31 : 0]  tmp_mem_address;
  reg [31 : 0]  tmp_mem_wr_data;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign mem_cs      = tmp_mem_cs;
  assign mem_we      = tmp_mem_we;
  assign mem_address = tmp_mem_address;
  assign mem_wr_data = tmp_mem_wr_data;

  assign opcode       = instruction_reg[31 : 26];
  assign dst_addr     = instruction_reg[25 : 21];
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

                         .dst_we(dst_we),
                         .dst_addr(dst_addr),
                         .dst_wr_data(dst_wr_data),

                         .zero_flag(zero_flag),

                         .inc(inc_pc),
                         .ret(ret_pc),
                         .pc(pc)
                        );

  fltcpu_alu alu(
                 .clk(clk),
                 .reset_n(reset_n),

                 .opcode(opcode),

                 .src0_data(source0_data),
                 .src1_data(source1_data),
                 .dst_data(dst_wr_data),

                 .eq_data(eq_data)
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
          fltcpu_ctrl_reg <= CTRL_IDLE;
        end
      else
        begin
          if (instruction_we)
            instruction_reg <= mem_rd_data;

          if (fltcpu_ctrl_we)
            fltcpu_ctrl_reg <= fltcpu_ctrl_new;
        end
    end // reg_update


  //----------------------------------------------------------------
  // mem_access
  //
  // Memory access mux.
  //----------------------------------------------------------------
  always @*
    begin : mem_access
      if (instruction_we)
        begin

        end
      else
        begin

          end
    end // mem_access


  //----------------------------------------------------------------
  // instruction_decode
  //
  // Detect instruction type and select operands based on the
  // current instruction.
  //----------------------------------------------------------------
  always @*
    begin : select_operands

      case (opcode)
        OP_BRK, OP_NOP:
          begin
          end

        OP_AND, OP_OR, OP_XOR, OP_NOT:
          begin
          end

        OP_ADD, OP_ADDI, OP_SUB, OP_SUBI, OP_MUL, OP_MULI:
          begin
          end

        OP_ASL, OP_ASLI, OP_ASR, OP_ASRI, OP_ROL, OP_ROLI, OP_ROR, OP_RORI:
          begin
          end

        OP_MV:
          begin
          end

        OP_CMP, OP_CMPI:
          begin
            instr_type = ITYPE_REG_REG;
          end

        OP_RD, OP_RDI, OP_RDC:
          begin
            instr_type = ITYPE_MEM_RD;
          end

        OP_WR, OP_WRI:
          begin
            instr_type = ITYPE_MEM_WR;
          end

        OP_BEQ, OP_BEQI, OP_BNEI:
          begin
          end

        OP_JSR, OP_JSRI, OP_JMP, OP_JMPI, OP_RTS:
          begin
            instr_type = ITYPE_MEM_JMP;
          end

        default:
          begin
          end
      endcase // case (opcode)

      // Decode instruction types


    end // select_operands


  //----------------------------------------------------------------
  // fltcpu_ctrl
  //
  // Main control FSM of the CPU.
  //----------------------------------------------------------------
  always @*
    begin : fltcpu_ctrl
      dst_we          = 0;
      instruction_we  = 0;
      inc_pc          = 0;
      ret_pc          = 0;
      tmp_mem_cs      = 0;
      tmp_mem_we      = 0;
      tmp_mem_address = 0;
      fltcpu_ctrl_new = CTRL_IDLE;
      fltcpu_ctrl_we  = 0;

      case (fltcpu_ctrl_reg)
        CTRL_IDLE:
          begin
            fltcpu_ctrl_new = CTRL_INSTR_READ;
            fltcpu_ctrl_we  = 1;
          end

        CTRL_INSTR_READ:
          begin
            tmp_mem_cs      = 1;
            tmp_mem_address = pc;
            fltcpu_ctrl_new = CTRL_INSTR_WAIT;
            fltcpu_ctrl_we  = 1;
          end

        CTRL_INSTR_WAIT:
          begin
            tmp_mem_cs      = 1;
            tmp_mem_address = pc;
            fltcpu_ctrl_new = CTRL_INSTR_STORE;
            fltcpu_ctrl_we  = 1;
          end

        CTRL_INSTR_STORE:
          begin
            instruction_we  = 1;
            fltcpu_ctrl_new = CTRL_INSTR_STORE;
            fltcpu_ctrl_we  = 1;
          end

        CTRL_INSTR_EXE0:
          begin
          end

        CTRL_MEM_WRITE:
          begin
          end

        CTRL_MEM_READ:
          begin
          end

        CTRL_MEM_WAIT:
          begin
          end

        CTRL_INSTR_EXE1:
          begin
          end

        CTRL_INSTR_DONE:
          begin
          end

        CTRL_IRQ_START:
          begin
          end

        CTRL_IRQ_DECODE:
          begin
          end

        CTRL_IRQ_DONE:
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
