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
# VelonaCore/applications/. The name of this subdirectory will be the
# application target name.
#
# The application may then be built by invoking this makefile, as follows:
# make TARGET=${folder name} LEROS_STACK_PTR=${init. stack ptr value}
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

TARGETDIR		= $(TARGET)

SRC			:= $(shell find $(TARGETDIR) -type f -name '*.c')
OBJ			:= $(patsubst $(TARGETDIR)/%,$(TARGETDIR)/%,$(SRC:.c=.o))

# Path to the Leros LLVM toolchain
TC				?= ../../build-leros-llvm/bin
LEROS_LIB_PATH	?= ../../leros-lib

CC			:= $(TC)/clang

# Entry point source file
START_SRC	:= startup_VelonaCore.s
START_OBJ	:= $(TARGETDIR)/startup_VelonaCore.o

# Board file for the VelonaCore
VELONACORE_H := $(LEROS_LIB_PATH)/cores/VelonaCore/basys3/VelonaCore_Basys3.h

# Fetch the board header from leros-lib
INC		=	-I$(dir $(VELONACORE_H))

# Instruct clang to use leros32 as the backend target
CFLAGS	:=	-target leros32

# Link using VelonaCore.ld. Given that this linker script includes memory
# segment definitions which are defined in a header, the C preprocessor must be
# run.
LINKER_SCRIPT	:= VelonaCore.ld
LINKER_SCRIPT_PP := $(TARGETDIR)/pp_${LINKER_SCRIPT}
LDFLAGS			:= -Xlinker $(LINKER_SCRIPT_PP)

# Rules
.PHONY: clean
.DEFAULT_GOAL := all

all: $(LINKER_SCRIPT_PP) $(BIN) clean

$(BIN): $(START_OBJ) $(OBJ)
	$(CC) -nostartfiles $(LDFLAGS) $^ -o $@

# Preprocess linker script
$(LINKER_SCRIPT_PP) : $(LINKER_SCRIPT)
	gcc -E -x c $^ -o $@

$(TARGETDIR)/%.o: $(TARGETDIR)/%.c
	$(CC) $(INC) -c -o $@ $<

$(START_OBJ): $(START_SRC)
	$(CC) -c $< -o $@

clean:
	rm -f $(TARGET)/*.o
	rm -f $(LINKER_SCRIPT_PP)
