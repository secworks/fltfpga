FLTCPU
======
Introduction
------------
The fltfpga CPU is a simple RISC processor core. We could have used an
ARM clone, OpenRISC or a number of different CPU cores. But what is the
fun with that?

Anyway, the CPU is a 32-bit CPU with a very limited instruction set. The
machines has a shared code and data memory to allow dymanic/self
modifying code, use data as code and other fun things. I/O including
is memory mapped too.

The first version of the machine will only support integer arithmetic.


Main requirements
-----------------
Endianness:    Big endian, 32-bit data words.
Address space: At least 24 bits. Word oriented.
Register:      32 or 64 registers, 32 bit wide
Opcodes:       Max 64.
Instructions:  Always a single word (32 bits)
Status:        Separate register.


Register map
------------
32 registers

r00: user reg 01
r01: user reg 01
...
r28: user reg 28
r29: status register (zero, carry, ...)
r30: return address
r31: program counter


Instruction types
-----------------
reg, reg -> reg operations
(AND, OR, XOR, ADD, SUB, MUL)
5 bit opcode, 4 bit src0, 4 bit src1, 4 bit dst, x extra = 5 + 12 = 17 + x bits

reg -> reg operations
(ROL, ROR, ASL, ASR, NOT)
5 bit opcode, 4 bit src0, 4 bit dst, 5 bit shamt + y extra = 5 + 12 + 5 = 22 + y bits

reg, imm -> reg operations
(ADDI, SUBI, MULI)
5 bit opcode, 4 bit src0, 4 bit dst, z bit imm = 5 + 12 + z = 17 + z bits



Instruction Set
---------------
AND  - AND src0 and src1, store result in dst.

OR   - Inclusive OR src0 and src1, store result in dst.

XOR  - Exclusive OR src0 and src1, store in dst.

NOT  - Inverse src0, store in dst.

ADD  - Add src0 and src1, store in dst.
ADDI - Add src0 and constant, store in dst.

SUB  - Substract one register from register, store in register
SUBI - Subtract constant from register, store in register

MUL  - Multiply two registers, store in register
MULI - Multiply register with constant, store in register

ASL  - Arithmetic shift left of contents of src0 with number of bits
       given by src1. Store result in dst register.
ASLI - Arithmetic shift left of contents of src0 with number of bits
       given by constant. Store result in dst register.

ASR  - Arithmetic shift right of contents of src0 with number of bits
       given by src1. Store result in dst register.
ASRI - Arithmetic shift right of contents of src0 with number of bits
       given by constant. Store result in dst register.

ROL  - Rotate left of contents of src0 with number of bits
       given by src1. Store result in dst register.
ROLI - Rotate left of contents of src0 with number of bits
       given by constant. Store result in dst register.

ROR  - Rotate right of contents of src0 with number of bits
       given by src1. Store result in dst register.
RORI - Rotate right of contents of src0 with number of bits
       given by constant. Store result in dst register.

RD   - Read from address given by register, store in register
RDI  - Read from constant address, store in register

WR   - Write contents of register to address given by register
WRI  - Write contents of register to constant address

CMP  - Compare contents of register with register
CMPI - Comparre contents of register with constant

BEQ  - Branch to address given by register if eq flag is set
BEQI - Branch to address given by constant if eq flag is set

BNE  - Branch to address given by register if eq flag is not set
BNEI - Branch to address given by constant if eq flag is not set

JSR  - Jump to address given by register, store PC in return address
JMP  - Jump to address given by register
JMPI - Jump to address given by constant

Right now 23 instructions.


TODO
----
Interrupthantering
Boot


Functions to consider:
----------------------
- Autoindex, Auto increment of registers
- DMA
- DSP, MAC
- Floating points
- Byte, word read och write.
- Implicit or explicit stacks
- Implicit or explicit return address
- Implicit pc stack


Test/Exempel
------------
    ADDI r01, r01, 0xdead - 5 + 8 + 16  = 29 bitar
    ADDI r01, r01, 0xdead - 6 + 8 + 16  = 30 bitar (6 bit opkod)
    ADDI r01, r01, 0xdead - 6 + 10 + 16 = 32 bitar (6 bit opkod, 5 bit regadress)

6 bit opcode, 6 bit src0, 6 bit src 1, 4 bit dst = 21 bit. 32 - 21 = 11
6 bit opcode, 5 bit src0, 5 bit dst, 16 bit immediate - 32 bit. Good!
6 bit opcode, 5 bit src0, 21 bit immediate
6 bit opcode, 5 bit dst,  21 bit immediate


6 bit opcode, 6 bit src0, 6 bit src 1, 4 bit dst = 21 bit. 32 - 21 = 11
5 bit opcode, 4 bit src0, 4 bit dst, 16 bit immediate - 32 bit. Good!
5 bit opcode, 4 bit src0, 23 bit immediate