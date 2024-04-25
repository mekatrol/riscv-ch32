# RCC_CTLR bits
  HSEON                   = (1 << 16)

# RCC_APB2PCENR bits
  IOPAEN                  = (1 << 2)  # Port A enable bit (bit 2)
  IOPCEN                  = (1 << 4)  # Port C enable bit (bit 4)
  IOPDEN                  = (1 << 5)  # Port D enable bit (bit 5)

# GPIO modes
  GPIO_MODE_INP           = 0x00      # Input mode
  GPIO_MODE_OP_10MHZ      = 0x01      # Output mode, maximum speed 10MHz
  GPIO_MODE_OP_2MHZ       = 0x10      # Output mode, maximum speed 2MHz
  GPIO_MODE_OP_30MHZ      = 0x11      # Output mode, maximum speed 30MHz

  GPIO_IN_ANALOGUE        = 0x00      # Analogue input mode
  GPIO_IN_FLOAT           = 0x01      # Floating input mode
  GPIO_IN_PU_PD           = 0x10      # With pull-up and pull-down mode

  GPIO_OUT_UNI_PUSH_PULL  = 0x00      # Universal push-pull output mode
  GPIO_OUT_UNI_OPEN_DRAIN = 0x01      # Universal open-drain output mode
  GPIO_OUT_MPX_PUSH_PULL  = 0x10      # Multiplexed function push-pull output mode
  GPIO_OUT_MPX_OD         = 0x11      # Multiplexing function open-drain output mode

  GPIO_PD0_MASK           = 0xF << 0  # Bits 0,1,2,3
  GPIO_PD1_MASK           = 0xF << 4  # Bits 4,5,6,7
  GPIO_PD2_MASK           = 0xF << 8  # Bits 8,9,10,11
  GPIO_PD3_MASK           = 0xF << 12 # Bits 12,13,14,15
  GPIO_PD4_MASK           = 0xF << 16 # Bits 16,16,18,19
  GPIO_PD5_MASK           = 0xF << 20 # Bits 20,21,22,23
  GPIO_PD6_MASK           = 0xF << 24 # Bits 24,25,26,27
  GPIO_PD7_MASK           = 0xF << 28 # Bits 28,29,30,31