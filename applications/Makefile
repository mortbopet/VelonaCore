# Generic Makefile for building applications for the VelonaCore system.
#
# -------------------------------- Prerequisites -------------------------------
# The makefile assumes that this repository (VelonaCore) was checked out
# next to the remainder of the Leros related repositories, as in:
#
# .
# ├── build-leros-llvm
# │   └─── bin
# ├── leros-lib
# │   └─── runtime
# └── VelonaCore
#     └─── applications <- you are here
#
# If this is not the case, specifying different LEROS_LIB_PATH and TC variables
# to this makefile may point the makefile to the proper locations.
#
# ----------------------------------- Usage ------------------------------------
# Source files for a given program should be placed in a subdirectory within
# VelonaCore/applications/.
# The file containing the main() function should be named identically to the
# directory of which it is placed.
#
# The application may then be built by invoking this makefile, as follows:
# make TARGET=${application} LEROS_STACK_PTR=${init. stack ptr value}
#
# Ie. to build the trianglenumber application with a stack pointer starting at
# 0x3FC:
# make TARGET=trianglenumber LEROS_STACK_PTR=0x3FC
#

## Sources
abort:
ifndef TARGET
$(error TARGET not defined, aborting)
endif

BIN 		= $(TARGET)/$(TARGET)

SRCDIR		= $(TARGET)
OBJDIR		= $(TARGET)

SRC			:= $(shell find $(SRCDIR) -type f -name '*.c')
OBJ			:= $(patsubst $(SRCDIR)/%,$(OBJDIR)/%,$(SRC:.c=.o))

# Path to the Leros LLVM toolchain
TC				?= ../../build-leros-llvm/bin
LEROS_LIB_PATH	?= ../../leros-lib

CC			:= $(TC)/clang

# CRT0 source file, assumed to be placed in the leros-lib repository
CRT0_SRC	:= $(LEROS_LIB_PATH)/runtime/crt0.leros.c
CRT0_OBJ	:= $(OBJDIR)/crt0.leros.o

# Board file for the VelonaCore
VELONACORE_H := $(LEROS_LIB_PATH)/cores/VelonaCore/basys3/VelonaCore_Basys3.h

# Fetch the board header from leros-lib
INC		=	-I$(dir $(VELONACORE_H))

# Instruct clang to use leros32 as the backend target
CFLAGS	:=	-target leros32

# Link using leros.ld, ensuring that emmission of .text segment starts at 0x0
LINKER_SCRIPT	:= leros.ld
LDFLAGS			:= -Xlinker $(LINKER_SCRIPT)

# Rules
.PHONY: clean
.DEFAULT_GOAL := all

all: $(BIN) clean

$(BIN): $(CRT0_OBJ) $(OBJ)
	$(CC) -nostartfiles $(LDFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(INC) -c -o $@ $<

$(CRT0_OBJ): $(CRT0_SRC)
ifndef LEROS_STACK_PTR
	$(error LEROS_STACK_PTR is not set)
endif
	$(CC) $< -c -o $@ -DLEROS_STACK_PTR=$(LEROS_STACK_PTR)

clean:
	rm $(TARGET)/*.o
