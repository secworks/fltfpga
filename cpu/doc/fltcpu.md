FLTCPU
======
## Introduction ##
The fltfpga CPU is a simple RISC processor core. We could have used an
ARM clone, OpenRISC or a number of different CPU cores. But what is the
fun with that?

Anyway, the CPU is a 32-bit CPU with a very limited instruction set. The
machines has a shared code and data memory to allow dymanic/self
modifying code, use data as code and other fun things. I/O including
is memory mapped too. Oh and the program counter (PC) is of course a
normal register so one can manipulate the PC from SW. Running code
backwards? Should be doable.

The first version of the machine will only support integer arithmetic.


## Architecture ##
- Endianness:    Big endian, 32-bit data words.
- Address space: At least 24 bits. Word oriented.
- Registers:     32 or 64 registers, 32 bits wide.
- Opcodes:       Max 64 opcodes.
- Instructions:  Always a single word (32 bits)
- Execution:     Single scalar, in order and variable number of cycles. No delay slots or API visible pipeline artifacts.
- Status:        Separate register.


## Register map ##
32 registers in total. All registers are directly writeable by SW. This means that one can easily jump, change status regs, manipulate return addresses.

- r00..r28: General registers.
- r29: status register (zero, carry, equal etc...) Not a complete register. Only the specified bits are actually there.
- r30: return address
- r31: program counter


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
- destintation register number = instruction_reg[25 : 21];
- source0 register number = instruction_reg[20 : 16];
- source1 register number = instruction_reg[15 : 11];
- constant                = instruction_reg[15 : 00];


## Instruction Set ##

| opcode   | Mnemonic   | Description   | Registers   | Flags   |
|:--------:|:----------:|-------------------------------------------|:-----------:|:-------:|
| 0x00     | BRK        | Break. Do nothing and do not increase PC.   |||
|          |            ||||
| 0x01     | AND        | AND src0 and src1, store result in dst.   |||
| 0x02     | OR         | Inclusive OR src0 and src1, store result in dst.   |||
| 0x03     | XOR        | Exclusive OR src0 and src1, store in dst.   |||
| 0x04     | NOT        | Inverse src0, store in dst.    |||
|          |            ||||
| 0x08     | ADD        | Add src0 and src1, store in dst.   |||
| 0x09     | ADDI       | Add src0 and constant, store in dst.   |||
| 0x0a     | SUB        | Substract one register from register, store in register   |||
| 0x0b     | SUBI       | Subtract constant from register, store in register   |||
| 0x0c     | MUL        | Multiply two registers, store in register   |||
| 0x0d     | MULI       | Multiply register with constant, store in register   |||
|          |            ||||
| 0x10     | ASL        | Arithmetic shift left of contents of src0 with number of bits given by src1. Store result in dst register.   |||
| 0x11     | ASLI       | Arithmetic shift left of contents of src0 with number of bits given by constant. Store result in dst register.   |||
| 0x12     | ASR        | Arithmetic shift right of contents of src0 with number of bits given by src1. Store result in dst register.   |||
| 0x13     | ASRI       | Arithmetic shift right of contents of src0 with number of bits given by constant. Store result in dst register.   |||
| 0x14     | ROL        | Rotate left of contents of src0 with number of bits given by src1. Store result in dst register.   |||
| 0x15     | ROLI       | Rotate left of contents of src0 with number of bits given by constant. Store result in dst register.   |||
| 0x16     | ROR        | Rotate right of contents of src0 with number of bits given by src1. Store result in dst register.   |||
| 0x17     | RORI       | Rotate right of contents of src0 with number of bits given by constant. Store result in dst register.   |||
|          |            ||||
| 0x20     | RD         | Read from address given by register, store in register |||
| 0x21     | RDI        | Read from constant address, store in register |||
| 0x22     | WR         | Write contents of register to address given by register |||
| 0x23     | WRI        | Write contents of register to constant address. |||
|          |            ||||
| 0x30     | CMP        | Compare contents of src0 with src1. Update eq flag.   |||
| 0x31     | CMPI       | Compare contents of register with constant.   |||
| 0x32     | BEQ        | Branch to address given by register if eq flag is set   |||
| 0x33     | BEQI       | Branch to address given by constant if eq flag is set   |||

| 0x38     | BNE        | Branch to address given by register if eq flag is not set   |||
| 0x38     | BNEI       | Branch to address given by constant if eq flag is not set   |||
| 0x3a     | JSR        | Jump to address given by register, store PC in return address   |||
| 0x3b     | JMP        | Jump to address given by register   |||
| 0x3c     | JMPI       | Jump to address given by constant   |||


In total: 32 instructions.


## TODO ##
- Instruction opcode encoding.
- Interrupt support
- Boot


## Functions to consider ##
- Autoindex, Auto increment of registers
- DMA
- DSP, MAC
- Floating points
- Byte, word read och write.
- Implicit or explicit stacks
- Implicit or explicit return address
- Implicit pc stack


## Test/Exempel ##
- ADDI r01, r01, 0xdead - 5 + 8 + 16  = 29 bitar
- ADDI r01, r01, 0xdead - 6 + 8 + 16  = 30 bitar (6 bit opkod)
- ADDI r01, r01, 0xdead - 6 + 10 + 16 = 32 bitar (6 bit opkod, 5 bit regadress)

- 6 bit opcode, 6 bit src0, 6 bit src 1, 4 bit dst = 21 bit. 32 - 21 = 11
- 6 bit opcode, 5 bit src0, 5 bit dst, 16 bit immediate - 32 bit. Good!
- 6 bit opcode, 5 bit src0, 21 bit immediate
- 6 bit opcode, 5 bit dst,  21 bit immediate

- 6 bit opcode, 6 bit src0, 6 bit src 1, 4 bit dst = 21 bit. 32 - 21 = 11
- 5 bit opcode, 4 bit src0, 4 bit dst, 16 bit immediate - 32 bit. Good!
- 5 bit opcode, 4 bit src0, 23 bit immediate
