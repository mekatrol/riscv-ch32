###########################################################################################
# DESCRIPTION:
# Sets register bits using the steps:
# 1. Load register value from address a0 into t0
# 2. AND value in t0 with mask supplied in a1 (clears any masked bits)
# 3. OR t0 with the value provided in a2 (sets desired bits)
# 4. Store t0 back to register at address a0
# IN:
# a0 - the address of the register to update
# a1 - the mask used to reset bits in the register value (pass in ~0 if no bits should be cleared)
# a2 - the mask used to set bits in the register value
# ALTERED REGISTERS:
# t0
###########################################################################################
set_register_bits_with_mask:
# Load existing register value from a0 pointer into t0
  lw  t0,0(a0)

# Clear masked bits in loaded register value
  and t0,t0,a1

# OR GPIO configuration mask with existing register value
  or  t0,t0,a2

# Write updated GPIO register
  sw  t0,0(a0)

  ret