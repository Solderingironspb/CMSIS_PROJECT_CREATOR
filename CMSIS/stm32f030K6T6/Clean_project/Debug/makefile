################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (9-2020-q2-update)
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include Core/Startup/subdir.mk
-include Core/Src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

OPTIONAL_TOOL_DEPS := \
$(wildcard ../makefile.defs) \
$(wildcard ../makefile.init) \
$(wildcard ../makefile.targets) \


BUILD_ARTIFACT_NAME := Clean_project
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
Clean_project.elf \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
Clean_project.list \

OBJCOPY_BIN += \
Clean_project.bin \


# All Target
all: main-build

# Main-build Target
main-build: Clean_project.elf secondary-outputs

# Tool invocations
Clean_project.elf: $(OBJS) $(USER_OBJS) C:\dev\2023\Clean_project\STM32F030K6TX_FLASH.ld makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-gcc -o "Clean_project.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m0 -T"C:\dev\2023\Clean_project\STM32F030K6TX_FLASH.ld" --specs=nosys.specs -Wl,-Map="Clean_project.map" -Wl,--gc-sections -static --specs=nano.specs -mfloat-abi=soft -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

Clean_project.list: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "Clean_project.list"
	@echo 'Finished building: $@'
	@echo ' '

Clean_project.bin: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-objcopy  -O binary $(EXECUTABLES) "Clean_project.bin"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(SIZE_OUTPUT)$(OBJDUMP_LIST)$(EXECUTABLES)$(OBJS)$(S_DEPS)$(S_UPPER_DEPS)$(C_DEPS)$(OBJCOPY_BIN) Clean_project.elf
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST) $(OBJCOPY_BIN)

fail-specified-linker-script-missing:
	@echo 'Error: Cannot find the specified linker script. Check the linker settings in the build configuration.'
	@exit 2

warn-no-linker-script-specified:
	@echo 'Warning: No linker script specified. Check the linker settings in the build configuration.'

.PHONY: all clean dependents fail-specified-linker-script-missing warn-no-linker-script-specified

-include ../makefile.targets
