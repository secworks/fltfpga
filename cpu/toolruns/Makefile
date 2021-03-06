#===================================================================
#
# Makefile
# --------
# Makefile for building the fltcpu.
#
#
# Author: Joachim Strombergson
# Copyright (c) 2015, Secworks Sweden AB
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#===================================================================

SRC_DIR=../src/rtl
CPU_SRC=$(SRC_DIR)/fltcpu.v $(SRC_DIR)/fltcpu_regfile.v $(SRC_DIR)/fltcpu_alu.v
CPU_TB=../src/tb/tb_fltcpu.v
PU_TOP=fltcpu

CC = iverilog
CC_FLAGS = -Wall

LINT = verilator
LINT_FLAGS = +1364-2001ext+ --lint-only -Wall -Wno-fatal -Wno-DECLFILENAME


all: cpu.sim


cpu.sim: $(CPU_TB) $(CPU_SRC)
	$(CC) $(CC_FLAGS) -o cpu.sim $(CPU_TB) $(CPU_SRC)


lint: $(CPU_SRC)
	$(LINT) $(LINT_FLAGS) $(CPU_TOP) $(CPU_SRC)


clean:
	rm -f *.sim


help:
	@echo "Supported targets:"
	@echo "------------------"
	@echo "cpu:      Build cpu simulation targets."
	@echo "lint:     Lint the CPU source."
	@echo "clean:    Delete all built files."

#===================================================================
# EOF Makefile
#===================================================================
