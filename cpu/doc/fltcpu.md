FLTCPU
======
## Introduction ##
The fltfpga CPU is a simple RISC processor core. We could have used an
ARM clone, RISC-V, OpenRISC or a number of different CPU cores. But what
is the fun with that?

Anyway, the CPU is a 32-bit CPU with a very limited instruction set. The
machines has a shared code and data memory to allow dynamic/self
modifying code, use data as code and other fun things. I/O is memory
mapped too. Oh and the program counter (PC) and return address (RET) are
of course normal registers so one can manipulate the PC and
RET from SW. Running code backwards by shifting the PC? Jumping by
setting RET and do a RTS? Should be doable.

The machine reads 32-bit aligned words. But can write independent bytes
(one to four) to memory.

The first version of the machine will only support integer arithmetic.


## Architecture ##
- Endianness:     Big endian, 32-bit data words.
- Address space:  At least 24 bits. Word oriented.
- Registers:      32 registers, 32 bits wide.
- Opcodes:        Max 64 opcodes. Should reduce to 32.
- Instructions:   Always a single word (32 bits)
- Execution:      Single scalar, in order and variable number of cycles. No delay slots or API visible pipeline artifacts.
- Status/Control: Status flags and control bits. Can be written to set/clear.


## Register map ##
32 registers in total. All registers are directly writable by SW. This
means that one can easily jump, change status regs, manipulate return
addresses.

- r00: Zero registers (ZERO). Will always return zero.
- r01..r28: General registers (gp01 .. gp28).
- r29: status register (STATUS). (zero, carry, equal etc...) Not a complete register. Only the specified bits are actually there.
- r30: return address (RET). Is actually a Top Of Stack (TOS) element.
- r31: program counter (PC).


## Instruction types and structure ##
- reg, reg -> reg operations
  (AND, OR, XOR, ADD, SUB, MUL)
  6 bit opcode, 5 bit dst, 5 bit src0, 5 bit src0 = 6 + 15 = 21 + x bits

- reg -> reg operations
  (ROL, ROR, ASL, ASR, NOT, RD, WR)
  6 bit opcode, 5 bit dest, 5 bit src0 = 6 + 10 = 16 + x bits

- reg, imm -> reg operations
  (ADDI, SUBI, MULI)
  6 bit opcode, 5 bit dst, 5 bit src0, 16 bit constant = 5 + 12 + z = 17 + z bits


Where in the instruction the fields are:
- opcode = instruction_reg[31 : 26];
- destination register number = instruction_reg[25 : 21];
- source0 register number = instruction_reg[20 : 16];
- source1 register number = instruction_reg[15 : 11];
- constant                = instruction_reg[15 : 00];


## Instruction Set ##

| opcode   | Mnemonic   | Description   | Registers   | Flags   |
|:--------:|:----------:|-------------------------------------------|:-----------:|:-------:|
| 0x00     | BRK        | Break. Do nothing and do not increase PC.   | |   |
| 0x02     | EXE        | Execute the contents of src as the next instruction. | PC ||
|          |            ||||
| 0x04     | AND        | AND src0 and src1, store result in dst.   | dst | zero |
| 0x05     | OR         | Inclusive OR src0 and src1, store result in dst.   | dst | zero |
| 0x06     | XOR        | Exclusive OR src0 and src1, store in dst.   | dst | zero |
| 0x07     | NOT        | Inverse src0, store in dst.    | dst | zero |
|          |            ||||
| 0x08     | ADD        | Add src0 and src1, store in dst.   | dst | carry, zero |
| 0x09     | ADDI       | Add src0 and constant, store in dst.   | dst | carry, zero |
| 0x0a     | SUB        | Substract src1 from src0, store in dst   | dst | zero |
| 0x0b     | SUBI       | Subtract constant from src0, store in dst  | dst | zero |
| 0x0c     | MUL        | Multiply src0 and src1, store in dst | dst | carry, zero |
| 0x0d     | MULI       | Multiply srx0 with constant, store in dst | dst | carry, zero |
|          |            ||||
| 0x10     | ASL        | Arithmetic shift left of contents of src0 with number of bits given by src1. Store result in dst. | dst | carry, zero |
| 0x11     | ASLI       | Arithmetic shift left of contents of src0 with number of bits given by constant. Store result in dst. | dst | carry, zero |
| 0x12     | ASR        | Arithmetic shift right of contents of src0 with number of bits given by src1. Store result in dst. | dst | carry, zero |
| 0x13     | ASRI       | Arithmetic shift right of contents of src0 with number of bits given by constant. Store result in dst. | dst | carry, zero |
| 0x14     | ROL        | Rotate left of contents of src0 with number of bits given by src1. Store result in dst.   | dst ||
| 0x15     | ROLI       | Rotate left of contents of src0 with number of bits given by constant. Store result in dst.   | dst ||
| 0x16     | ROR        | Rotate right of contents of src0 with number of bits given by src1. Store result in dst.   | dst ||
| 0x17     | RORI       | Rotate right of contents of src0 with number of bits given by constant. Store result in dst.   | dst ||
|          |            ||||
| 0x20     | RD         | Read from from address given by src0. Store in dst. | dst ||
| 0x21     | RDI        | Read from address given by src0 added with constant. Store in dst. | dst ||
| 0x22     | RDC        | Read given constant, zero extended value into dst. | dst ||
| 0x28     | WR         | Write contents of src0 to address given by dst. Which bytes are written is controlled by src1 one-hot encoded. |||
| 0x29     | WRI        | Write contents of src0 to address given by dst added with constant. Note that this will only write the full word. |||
|          |            ||||
| 0x30     | CMP        | Compare contents of src0 with src1. Update eq flag. || eq |
| 0x31     | CMPI       | Compare contents of register src0 with zero extented constant. Update eq flag. || eq |
| 0x32     | BEQ        | Branch to address given by dst if eq flag is set. | pc | eq ||
| 0x33     | BEQI       | Branch to address given by dst added with constant if eq flag is set. | pc | eq |
| 0x34     | BNE        | Branch to address given by dst if eq flag is not set. | pc | eq |
| 0x35     | BNEI       | Branch to address given by dst added with constant if eq flag is not set. | pc | eq |
| 0x38     | JSR        | Jump to address given by dst. Store PC in RET.  | pc, ret ||
| 0x39     | JSRI       | Jump to address given by dst added with constant. Store PC in RET.  | pc, ret ||
| 0x3a     | JMP        | Jump to address given by dst.   | pc ||
| 0x3b     | JMPI       | Jump to address given by dst added with constant.  | pc ||
| 0x3f     | RTS        | Return from subroutine using stored return address. Updates PC. | pc ||
|          |            ||||

In total: 36 instructions out of a maximum of 64.


## Details ##

### JSR, RTS and return address handling ###
The return address register r30 is really the top of a stack. Or more
correctly, the value in the register is what is stored in the descriptor
ring register pointed to by the ring pointer. A jsr will move (increase)
the pointer and store the PC in the register the pointer now selects. A
RTS instruction copies the value of the register and the decreases the
pointer. The pointer itself is part of the status/control register
r29. This means that one can actually move the pointer without
performing JSR or RTS operations.

The size of the descriptor is 32 registers.


### The EXE instruction ###
Since we really want to allow weird tricks to be possible, we have added
the ability to use the contents of a register as an instruction.

When the EXE instruction issued, the contents of the register poiinted
to by the instruction is used as the next instruction instead of the
contents of the memory address pointed to by the PC.

If the instruction given by the contents of the register doesn't update
the PC, the next instruction will be what is currently in the memory
pointed to by the PC. So basically the EXE instruction will be a double
instruction - the exe instruction itself, and the instruction given by
the contents of the register.

If the contents of the register is not an instruction, that is it
contains a valid opcode, the CPU will either silently ignore to execute
the instruction, or raise an exception. Which method to be used is given
by the dbg status/control bit.


### The status/control register r29 ##
The flags and control bits we want to expose.

- return address descriptot pointer. 5 bits
- eq 1 bit
- dbg 1 bit.
- zero


## TODO ##
- Interrupt support
- Boot


## Functions to consider ##
- Autoindex, Auto increment of registers
- Byte, word read and write.


## Test/Examples ##
- ADDI r01, r01, 0xdead - 5 + 8 + 16  = 29 bits
- ADDI r01, r01, 0xdead - 6 + 8 + 16  = 30 bits (6 bit opcode)
- ADDI r01, r01, 0xdead - 6 + 10 + 16 = 32 bits (6 bit opcode, 5 bit regaddr)

- 6 bit opcode, 6 bit src0, 6 bit src 1, 4 bit dst = 21 bit. 32 - 21 = 11
- 6 bit opcode, 5 bit src0, 5 bit dst, 16 bit immediate - 32 bit. Good!
- 6 bit opcode, 5 bit src0, 21 bit immediate
- 6 bit opcode, 5 bit dst,  21 bit immediate

- 6 bit opcode, 6 bit src0, 6 bit src 1, 4 bit dst = 21 bit. 32 - 21 = 11
- 5 bit opcode, 4 bit src0, 4 bit dst, 16 bit immediate - 32 bit. Good!
- 5 bit opcode, 4 bit src0, 23 bit immediate
