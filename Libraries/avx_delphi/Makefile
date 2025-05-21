# Compiler and flags
CC        := gcc
CFLAGS    := -Wall -shared -O3 -mavx -mavx2 -mfma -march=native -mtune=native

# Directories
SRC_DIR   := src
OBJ_DIR   := build
INC_DIR   := include

# Targets and artifacts
TARGET    := $(OBJ_DIR)\avx_delphi.dll

# Source and object files
AVX_SRC   := $(SRC_DIR)\avx_delphi.c
AVX_OBJ   := $(OBJ_DIR)\avx_delphi.o
SRCS      := $(AVX_SRC)
OBJS      := $(AVX_OBJ)

# Header files
HEADERS   := $(INC_DIR)\avx_delphi.h

# Default target
all: $(TARGET)

# Link shared library
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Compile source into object
$(OBJS): $(SRCS) $(HEADERS) | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $(AVX_SRC) -o $(AVX_OBJ)

# Create object directory if missing
$(OBJ_DIR):
	@mkdir $(OBJ_DIR)

# Clean up build artifacts
clean:
	rmdir /s /Q $(OBJ_DIR)
