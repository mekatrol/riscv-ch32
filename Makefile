GNU_DIR=/home/dad/MRS_Toolchain_Linux_x64_V1.91/RISC-V_Embedded_GCC/bin
OPENOCD_DIR=/home/dad/MRS_Toolchain_Linux_x64_V1.91/OpenOCD/bin

TARGET_NAME ?= hello_world
TARGET_ELF  ?= $(TARGET_NAME).elf
TARGET_LST  ?= $(TARGET_NAME).lst
TARGET_HEX  ?= $(TARGET_NAME).hex
TARGET_BIN  ?= $(TARGET_NAME).bin
TARGET_MAP  ?= $(TARGET_NAME).map

OBJCPY  = riscv-none-embed-objcopy
OBJDUMP = riscv-none-embed-objdump
SIZE    = riscv-none-embed-size
GCC     = riscv-none-embed-gcc
OPENOCD = $(OPENOCD_DIR)/openocd

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.S)

MKDIR = mkdir -p
RM = rm -rf

all: init $(TARGET_BIN) $(TARGET_HEX) $(TARGET_LST) size

init:
	$(MKDIR) $(BUILD_DIR)

$(TARGET_HEX): $(TARGET_ELF)
		$(GNU_DIR)/$(OBJCPY) -O ihex $(BUILD_DIR)/$(TARGET_ELF) $(BUILD_DIR)/$(TARGET_HEX)

$(TARGET_BIN): $(TARGET_ELF)
		$(GNU_DIR)/$(OBJCPY) $(BUILD_DIR)/$(TARGET_ELF) -O binary $(BUILD_DIR)/$(TARGET_BIN)

$(TARGET_LST): $(TARGET_ELF)
		$(GNU_DIR)/$(OBJDUMP) -Mnumeric,no-aliases -dr $(BUILD_DIR)/$(TARGET_ELF) > $(BUILD_DIR)/$(TARGET_LST)

$(TARGET_ELF): src/boot.S
		$(GNU_DIR)/$(GCC) -pipe -Wl,-Map=$(BUILD_DIR)/$(TARGET_MAP) --freestanding -fno-pic -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0x0 -Tbss=0x20000000 -Wl,--no-relax src/boot.S -o $(BUILD_DIR)/$(TARGET_ELF) 

size: $(TARGET_ELF)
	$(GNU_DIR)/$(SIZE) $(BUILD_DIR)/$(TARGET_ELF)

flash: $(TARGET_ELF)
	$(OPENOCD) -f ./openocd/openocd_probe.cfg -f ./openocd/openocd_chip.cfg -c "program {$(BUILD_DIR)/$(TARGET_ELF)} verify reset; shutdown;"

clean:
	$(RM) $(BUILD_DIR)

rebuild: clean all

.PHONY: init clean size rebuild
