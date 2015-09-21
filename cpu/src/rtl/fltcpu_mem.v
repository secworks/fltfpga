//======================================================================
//
// fltcpu_mem.v
// ------------
// FPGA internal memory for the cpu.
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

module fltcpu_mem(
                  // Clock and reset.
                  input wire           clk,
                  input wire           reset_n,

                  input wire           mem_cs,
                  input wire [3 : 0]   mem_we,
                  input wire [31 : 0]  mem_address,
                  input wire [31 : 0]  mem_wr_data,
                  output wire [31 : 0] mem_rd_data
                 );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam MEM_BITS = 12:
  localparam MEM_SIZE = 2**MEM_BITS;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [7 : 0] mem_byte0 [0 : (MEM_SIZE - 1)];
  reg [7 : 0] mem_byte1 [0 : (MEM_SIZE - 1)];
  reg [7 : 0] mem_byte2 [0 : (MEM_SIZE - 1)];
  reg [7 : 0] mem_byte3 [0 : (MEM_SIZE - 1)];


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire [31 : 0] tmp_mem_rd_data;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign mem_rd_data = tmp_mem_rd_data;


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
        end
      else
        begin
          if (mem_we[0])
            mem_byte0[mem_address[(MEM_BITS - 1) : 0]] <= mem_wr_data[07 : 00];

          if (mem_we[1])
            mem_byte1[mem_address[(MEM_BITS - 1) : 0]] <= mem_wr_data[15 : 08];

          if (mem_we[2])
            mem_byte2[mem_address[(MEM_BITS - 1) : 0]] <= mem_wr_data[23 : 16];

          if (mem_we[3])
            mem_byte3[mem_address[(MEM_BITS - 1) : 0]] <= mem_wr_data[31 : 24];


          tmp_mem_rd_data <= {mem_byte3[mem_address[(MEM_BITS - 1) : 0]],
                              mem_byte2[mem_address[(MEM_BITS - 1) : 0]],
                              mem_byte1[mem_address[(MEM_BITS - 1) : 0]],
                              mem_byte0[mem_address[(MEM_BITS - 1) : 0]]};

        end
    end // reg_update
endmodule // fltcpu_mem

//======================================================================
// EOF fltcpu_mem.v
//======================================================================
