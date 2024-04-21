GNU_DIR=/home/dad/riscv/install/rv32i/bin

TARGET_NAME ?= hello_world
# TARGET_ELF  ?= $(TARGET_NAME).elf
# TARGET_HEX  ?= $(TARGET_NAME).hex
# TARGET_BIN  ?= $(TARGET_NAME).bin

# AS := riscv64-unknown-elf-as.exe
# CC := riscv64-unknown-elf-gcc.exe
# CXX := riscv64-unknown-elf-g++.exe
# OBJCOPY := riscv64-unknown-elf-objcopy.exe

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.S)
# OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
# DEPS := $(OBJS:.o=.d)

MKDIR = mkdir -p
RM = rm -rf

all: init $(TARGET_NAME).bin $(TARGET_NAME).lst

init:
	$(MKDIR) $(BUILD_DIR)

$(TARGET_NAME).bin: $(TARGET_NAME)
		$(GNU_DIR)/riscv32-unknown-elf-objcopy $(BUILD_DIR)/$(TARGET_NAME) -O binary $(BUILD_DIR)/$(TARGET_NAME).bin

$(TARGET_NAME).lst:
		$(GNU_DIR)/riscv32-unknown-elf-objdump -Mnumeric,no-aliases -dr $(BUILD_DIR)/$(TARGET_NAME) > $(BUILD_DIR)/$(TARGET_NAME).lst

$(TARGET_NAME): src/boot.S
		$(GNU_DIR)/riscv32-unknown-elf-gcc --freestanding -fno-pic -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0x0 -Wl,--no-relax src/boot.S -o $(BUILD_DIR)/$(TARGET_NAME)

clean:
	$(RM) $(BUILD_DIR)	

.PHONY: clean
