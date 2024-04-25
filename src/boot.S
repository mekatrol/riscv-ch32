# The "ax",@progbits tells the assembler that the section is allocatable ("a"), executable ("x") and contains data ("@progbits").
	.section             .init, "ax", @progbits

	.globl               _start
	.align               2

	.include             "./src/memory.S"
	.include             "./src/registers.S"
	.include             "./src/bits.S"

# Bit zero defines if PD0 state and bit 1 PD4 state
	STATE_LED_PD0_MASK   = 0x00000001
	STATE_LED_PD4_MASK   = 0x00000002
	STATE_LED_STATE_MASK = STATE_LED_PD0_MASK | STATE_LED_PD4_MASK

# NOTE: For calling conventions used see: https: //riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf
# NOTE: ABI names preferred over Register names

	.bss
# Keep track f current LED bit state
LED_STATE:
	.word

	.text
_start:
# Initialise stack pointer
	li                   sp, STACK

#############################
# Enable external oscillator
#############################
# Point to R32_RCC_CFGR0 register
	li                   a0,R32_RCC_CFGR0

# Turn HSE ON
	li                   a1,HSEON

# Update register
	call                 set_register_bits

#############################
# Initialise state
#############################
# Init LED state in RAM to 0x00000001
	li                   t0,0x00000001
	la                   a0,LED_STATE
	sw                   t0,0(a0)

#############################
# Enable port module clocks
#############################
# Point to APB2PCENR register
	li                   a0,R32_RCC_APB2PCENR

# Create port module clock enable mask for ports
	li                   a1,(IOPAEN|IOPCEN|IOPDEN)

# Update register
	call                 set_register_bits

#############################
# Configure GPIO
#############################

# Point to R32_GPIOD_CFGLR register
	li                   a0,R32_GPIOD_CFGLR
	li                   a1,~(GPIO_PD4_MASK | GPIO_PD4_MASK)
	li                   a2, ((GPIO_OUT_UNI_PUSH_PULL | GPIO_OUT_MPX_OD)<<0) | ((GPIO_OUT_UNI_PUSH_PULL | GPIO_OUT_MPX_OD)<<16)

	call                 configure_port

#############################
# Toggle LED bits
#############################
TOGGLE_BITS:
# Point to LED state in RAM
	la                   a0, LED_STATE

# Load current LED state values into t1
	lw                   t0,0(a0)

# Invert LED state bits
	xori                 t0,t0,STATE_LED_STATE_MASK

# Save back to memory (and retain in t0)
	sw                   t0,0(a0)

# Clear all but LED state bit
	andi                 t0,t0,STATE_LED_STATE_MASK

####################################
# Set LED bit value based on state
####################################
# Clear t1
	addi                 t1,zero,0

# Bit 0 LED state on?
	li                   t2,STATE_LED_PD0_MASK
	bne                  t0,t2,TURN_PD0_OFF

# Turn PD0 on in t1
	li                   t2,1 < <0
	or                   t1,t1,t2
	j                    TEST_PD4

TURN_PD0_OFF:
# Turn PD0 off in t1
	li                   t2,1 << 16
	or                   t1,t1,t2

TEST_PD4:
# Bit 2 LED state on?
	li                   t2,STATE_LED_PD4_MASK
	bne                  t0,t2,TURN_PD4_OFF

# Turn PD4 on in t1
	li                   t2,1 << 4
	or                   t1,t1,t2
	j                    UPDATE_GPIO

TURN_PD4_OFF:
# Turn PD4 off in t1
	li                   t2,1 << 20
	or                   t1,t1,t2

UPDATE_GPIO:
# Point to R32_GPIOD_BSHR register
	li                   a0,R32_GPIOD_BSHR

# Load existing R32_GPIOD_BSHR register value
	lw                   a1,0(a0)

# OR with PD4 bit state value
	or                   a1,a1,t1

# Write updated mask to R32_GPIOD_BSHR register
	sw                   a1,0(a0)

# Load delay period
	li                   t1,1000000

# Call delay subroutine
	call                 delay

# Jump back to toggle
	j                    TOGGLE_BITS

# Delay by count in t1
delay:
# Decrement t1 by 1
	addi                 t1,t1,-1

# If zero not reached then continue looping
	bne                  t1,zero,delay

	ret

# params:
# Register in a0
# Bit mask (bits to set) in a1
set_register_bits:
# Load existing register value
	lw                   t1,0(a0)

# OR with existing register value
	or                   t1,t1,a1

# Write updated mask to R32_RCC_CFGR0 register
	sw                   t1,0(a0)

	ret

# params:
# GPIO register in a0
# GPIO configuration mask bits (any bits set to 0 will be cleared in config register)
# GPIO configuration (bits to set) in a2
configure_port:
# Load existing register value from a0 pointer into t0
	lw                   t0,0(a0)

# Clear masked bits in loaded register value
	and                  t0,t0,a1

# OR GPIO configuration mask with existing register value
	or                   t0,t0,a2

# Write updated GPIO register
	sw                   t0,0(a0)

	ret