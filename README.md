# CH32Vxx setup and configuration

## Overview

This repository provides instructions for setting up environment and compiling 'blinky' for WCH CH32V003 processor. 

It has the following guidance:

1. Installing the toolchain
2. Compiling a simple ASM file (blinky) using make
3. Flashing the file to a device
4. Debugging the flashed file 

## Install toolchain

### Get toolchain tar file

> NOTE: V1.91 is used in these examples, use whatever the latest version is available for download.

> Via browser  
1. Navigate to http://www.mounriver.com/download
2. Select Linux as the OS
3. Click the toolchain & debugger download link
![alt download link image](./doc/toolchain_download.png "Download link image")
> Via wget  

`wget http://file.mounriver.com/tools/MRS_Toolchain_Linux_x64_V1.91.tar.xz`

### Extract tar
```bash
tar xf MRS_Toolchain_Linux_x64_V1.91.tar.xz
```

### Update the Makefile paths

Set the paths to where you extracted the toolchain, that is change path part `/home/dad` to your path.

```bash
GNU_DIR=/home/dad/MRS_Toolchain_Linux_x64_V1.91/RISC-V_Embedded_GCC/bin
OPENOCD_DIR=/home/dad/MRS_Toolchain_Linux_x64_V1.91/OpenOCD/bin
```

## Enabling USB in wsl

> Guide from here [WSL Connect USB devices](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)  

### Install 

> [usbipd-win](https://github.com/dorssel/usbipd-win)

### Attach USB to WSL

```powershell
usbipd list
```
Example result:
<pre>
Connected:  
BUSID  VID:PID    DEVICE                                                        STATE  
1-3    1a86:8010  WCH-LinkRV, WCH-Link SERIAL (COM16)                           Attached  
1-6    0a12:0001  Generic Bluetooth Radio                                       Not shared  
1-13   1b1c:0c08  H80i v2                                                       Not shared  
3-4    046d:c52b  Logitech USB Input Device, USB Input Device                   Not shared  
</pre>

```powershell
usbipd list
usbipd bind --busid <busid>
usbipd attach --wsl --busid <busid>
```

## Build example

```bash
make
```

## Flash example

```bash
make flash
```

## Build risc-v RV32I toolchain

We can build the RV32I compiler toolchain if the MounRiver version
does not match your build standards

### Clean build

```bash
# Remove output path
rm -rf ~/riscv/install/*
```

### Install build dependencies
```bash
sudo apt install -y autoconf automake autotools-dev curl libmpc-dev \
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