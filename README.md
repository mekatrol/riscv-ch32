# CH32Vxx setup and configuration

## Overview

This repository provides instructions for configuring risc-v 32 bit (primarily WCH processors). 

It has the following guidance:

1. Building the riscv-gnu-toolchain
2. Compiling a simple ASM file using make
3. Compiling OpenOCD for risc-v 32 bit WCH processors
3. Flashing the file to a device
4. Debugging the flashed file 

## Build risc-v RV32I toolchain

### Clean build

```bash
# Remove output path
rm -rf ~/riscv/install/*
```

### Install build dependencies
```bash
sudo apt install autoconf automake autotools-dev curl libmpc-dev \
  libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
  libtool patchutils bc zlib1g-dev libexpat-dev
```

### Clone toolchain
```bash
# Create toolchain directory if it does not exist
mkdir -p ~/riscv

# Change to toolchain directory
cd ~/riscv

# Clone the GNU risc-v toolchain (use recursive so that all sub modules are fetched during clone)
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain

# Change to cloned toolchain directory
cd riscv-gnu-toolchain
```

### Create install variable and directory
```bash
export INSTALL_DIR="echo "$(cd "$(dirname "$1")/../"; pwd)/$(basename "$1")install""
mkdir -p $INSTALL_DIR
```

### Build & install tool chain
```bash
# Configure with risc-v 32 bit architecture
./configure --prefix=$(INSTALL_DIR)/rv32i --with-arch=rv32i --with-abi=ilp32

# Make the tool chain
make
```

### Include toolchain path
```bash
export PATH=$PATH:~/riscv/install/rv32i/bin
```

## Build OpenOCD for CH32 processors

### Packages

```bash
sudo apt-get install -y libtool pkg-config texinfo libusb-dev libusb-1.0.0-dev libftdi-dev autoconf
```

### Clone and initialise repo
```bash
git clone https://github.com/mekatrol/riscv-openocd-wch.git
cd riscv-openocd-wch

chmod +x ./configure
chmod +x /home/dad/repos/riscv-openocd-wch/jimtcl/configure
chmod +x /home/dad/repos/riscv-openocd-wch/jimtcl/autosetup/autosetup-find-tclsh
chmod +x ./src/helper/bin2char.sh
```

### In ./configure add:

```bash
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-pointer-sign"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-return-type"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-maybe-uninitialized"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-unused-variable"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-incompatible-pointer-types"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-discarded-qualifiers"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-endif-labels"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-sign-compare"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-shadow"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-strict-prototypes"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-unused-but-set-variable"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-implicit-function-declaration"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-unused-label"  
  GCC_WARNINGS="${GCC_WARNINGS} -Wno-redundant-decls"  
```

### in src/jtag/drivers/wlink.c add before first use:

```c
void wlink_ramcodewrite(uint8_t *buffer, int size);
```

### in src/target/riscv/riscv-013.c change:
```c
LOG_DEBUG("[wch] read dcsr value is 0x%x", tmpDcsr);
```
**to**
```c
LOG_DEBUG("[wch] read dcsr value is 0x%x", (unsigned int) tmpDcsr);
```

### Configure, make and install OpenOCD

```bash
./configure --enable-wlink --disable-jlink
make

# Install to /usr/local/share/openocd
sudo make install
```

## Enabling USB in wsl

> Guid from here [WSL Connect USB devices](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)  

```powershell
usbipd list
usbipd bind --busid <busid>
usbipd attach --wsl --busid <busid>
```
