################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

# Each subdirectory must supply rules for building sources it contributes
LEDButton.o: ../LEDButton.asm $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"C:/ti/ccs2031/ccs/tools/compiler/ti-cgt-armllvm_4.0.4.LTS/bin/tiarmclang.exe" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"C:/Users/Steven/Documents/ee110/ee110a/workspace_ccstheia/led_button" -I"C:/Users/Steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug" -I"C:/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"C:/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"C:/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m --language=ti-asm -I"C:/Users/Steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

build-597136881: ../empty.syscfg
	@echo 'Building file: "$<"'
	@echo 'Invoking: SysConfig'
	"C:/ti/ccs2031/ccs/utils/sysconfig_1.25.0/sysconfig_cli.bat" --script "C:/Users/Steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/empty.syscfg" -o "syscfg" -s "C:/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/.metadata/product.json" --compiler ticlang
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
	"C:/ti/ccs2031/ccs/tools/compiler/ti-cgt-armllvm_4.0.4.LTS/bin/tiarmclang.exe" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"C:/Users/Steven/Documents/ee110/ee110a/workspace_ccstheia/led_button" -I"C:/Users/Steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug" -I"C:/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"C:/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"C:/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m -MMD -MP -MF"syscfg/$(basename $(<F)).d_raw" -MT"$(@)" -I"C:/Users/Steven/Documents/ee110/ee110a/workspace_ccstheia/led_button/Debug/syscfg"  $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '


