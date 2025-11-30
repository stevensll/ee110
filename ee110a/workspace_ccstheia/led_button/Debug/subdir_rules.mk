################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
LEDButton.o: ../LEDButton.asm $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/opt/ccstudio/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button" -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 --language=ti-asm -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$(shell echo $<)"
	@echo 'Finished building: "$<"'
	@echo ' '

build-597136881: ../empty.syscfg
	@echo 'Building file: "$<"'
	@echo 'Invoking: SysConfig'
	"/opt/ccstudio/ccs/utils/sysconfig_1.25.0/sysconfig_cli.sh" --script "/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/empty.syscfg" -o "syscfg" -s "/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/.metadata/product.json" --compiler ticlang
	@echo 'Finished building: "$<"'
	@echo ' '

syscfg/ti_devices_config.c: build-597136881 ../empty.syscfg
syscfg/ti_drivers_config.c: build-597136881
syscfg/ti_drivers_config.h: build-597136881
syscfg/ti_utils_build_linker.cmd.genlibs: build-597136881
syscfg/ti_utils_build_linker.cmd.genmap: build-597136881
syscfg/ti_utils_build_compiler.opt: build-597136881
syscfg/syscfg_c.rov.xs: build-597136881
syscfg: build-597136881

syscfg/%.o: ./syscfg/%.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/opt/ccstudio/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button" -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/home/steven/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m -MMD -MP -MF"syscfg/$(basename $(<F)).d_raw" -MT"$(@)" -I"/home/steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug/syscfg"  $(GEN_OPTS__FLAG) -o"$@" "$(shell echo $<)"
	@echo 'Finished building: "$<"'
	@echo ' '


