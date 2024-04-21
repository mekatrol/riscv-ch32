# CH32Vxx setup and configuration

## Overview

This repository provides instructions for configuring risc-v 32 bit (primarily WCH processors). 

It has the following guidance:

1. Building the riscv-gnu-toolchain
2. Compiling a simple ASM file using make
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
