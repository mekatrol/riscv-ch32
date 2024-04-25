# 1.2.1 Memory allocation
SRAM_SIZE  = 0x800                      # 2K of SRAM
SRAM_START = 0x20000000                 # Start of SRAM memory block
SRAM_END   = SRAM_START + SRAM_SIZE     # End of SRAM memory block

# Set stack to top of SRAM
STACK      = SRAM_END
