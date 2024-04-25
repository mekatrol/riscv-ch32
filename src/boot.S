# The "ax",@progbits tells the assembler that the section is allocatable ("a"), executable ("x") and contains data ("@progbits").
	.section       .init, "ax", @progbits

	.globl         _start
	.align         2

	.include       "./src/memory.S"
	.include       "./src/registers.S"
	.include       "./src/bits.S"

	STATE_PD4_MASK = 0x000001                                          # Bit zero defines if PD4 should be on or off

# NOTE: For calling conventions used see: https: //riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf
# NOTE: ABI names preferred over Register names

	.text
_start:
	li             sp, STACK                                           # Initialise stack pointer

#############################
# Enable port module clocks
#############################
	li             a0,R32_RCC_APB2PCENR                                # Point to APB2PCENR register
	lw             a1,0(a0)                                            # Load existing APB2PCENR register value
	li             t0,(IOPAEN|IOPCEN|IOPDEN)                           # Create port module clock enable mask for ports
	or             a1,a1,t0                                            # OR with existing register value
	sw             a1,0(a0)                                            # Write updated mask to R32_RCC_APB2PCENR register

#############################
# Configure GPIO
#############################

# Point to R32_GPIOD_CFGLR register
	li             a0,R32_GPIOD_CFGLR

# Load existing R32_GPIOD_CFGLR register value
	lw             a1,0(a0)

# At reset PD4 value is 0x4 (floating input), so we need to clear PD4 bits
	li             t0,~(GPIO_PD4_MASK)

# Clear PD4 MODE4 and CNF4 bits
	and            a1,a1,t0

# Push pull output at maximum 30MHz speed
	li             t0,((GPIO_OUT_UNI_PUSH_PULL | GPIO_OUT_MPX_OD)<<16)

# OR with existing register value
	or             a1,a1,t0

# Write updated PD4 mask to R32_GPIOD_CFGLR register
	sw             a1,0(a0)

#############################
# Initialise
#############################
# Clear state
	li             t2,STATE_PD4_MASK

#############################
# Toggle PD4 state bit
#############################
TOGGLE_PD4:
# Toggle PD4 bit (t2 contains the state flags)
	xori           t2,t2,STATE_PD4_MASK

# Copy t2 to t1
	addi           t1,t2,0

# Clear all but PD4 state bit
	andi           t1,t1,STATE_PD4_MASK

#############################
# Set PD4 value based on state
#############################

# Load PD4 set mask
	li             t0,1 << 4

# Load PD4 on mask
	addi           t1,zero,STATE_PD4_MASK

# Are we setting PD4, if so branch to update PD4
	beq            t2,t1,UPDATE_PD4

# Load PD4 reset mask
	li             t0,1<<20

UPDATE_PD4:
# Point to R32_GPIOD_BSHR register
	li             a0,R32_GPIOD_BSHR

# Load existing R32_GPIOD_BSHR register value
	lw             a1,0(a0)

# OR with PD4 bit state value
	or             a1,a1,t0

# Write updated mask to R32_GPIOD_BSHR register
	sw             a1,0(a0)

# Load delay period
	li             t1,1000000

# Call delay subroutine
	call           delay

# Jump back to toggle
	j              TOGGLE_PD4

# Delay by count in t1
delay:
# Decrement t1 by 1
	addi           t1,t1,-1

# If zero not reached then continue looping
	bne            t1,zero,delay

	ret