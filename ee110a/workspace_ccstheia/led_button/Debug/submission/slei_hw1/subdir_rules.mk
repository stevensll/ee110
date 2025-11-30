################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
submission/slei_hw1/%.o: ../submission/slei_hw1/%.asm $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/opt/ccstudio/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button" -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$(shell echo $<)"
	@echo 'Finished building: "$<"'
	@echo ' '


