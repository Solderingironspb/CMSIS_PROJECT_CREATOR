#   Makefile for STM32F401CEU6
#   Автор: Волков Олег
#   Дата создания скрипта: 11.11.2025
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

#Выбор компиляции под определенную систему. 
#OS_IS_LINUX = 1 - Это Linux
#OS_IS_LINUX = 0 - Это Windows
OS_IS_LINUX = 0

#Имя папки пользователя(для Linux)
USER_FOLDER_NAME = oleg

#######################################################################################################################################
# Системные include-директории
#######################################################################################################################################

#Чтоб clangd видел системные include-директории корректно, а не выдумывал их сам, пропишем пути вручную:
ifeq ($(OS_IS_LINUX), 1)
# Настройки для Linux
# Путь до компилятора:
COMPILER_PATH = /home/$(USER_FOLDER_NAME)/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/bin/arm-none-eabi-gcc
# Системные заголовочне файлы компилятора
ISYSTEM_INCLUDE_PATH_1 = /home/$(USER_FOLDER_NAME)/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/arm-none-eabi/include
# Внутренние заголовочные файлы GCC, специфичные для компилятора заголовки
ISYSTEM_INCLUDE_PATH_2 = /home/$(USER_FOLDER_NAME)/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/lib/gcc/arm-none-eabi/10.3.1/include
else

# Настройки для Windows
# Путь до компилятора:
COMPILER_PATH = C:/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/tools/arm-none-eabi
# Системные заголовочне файлы компилятора
ISYSTEM_INCLUDE_PATH_1 = C:/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/tools/arm-none-eabi/include
# Внутренние заголовочные файлы GCC, специфичные для компилятора заголовки
ISYSTEM_INCLUDE_PATH_2 = C:/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/tools/arm-none-eabi/include/sys
endif

#######################################################################################################################################
# Пути для проекта
#######################################################################################################################################

# GNU Arm Embedded Toolchain:
ifeq ($(OS_IS_LINUX), 1)
# Настройки для Linux
GNU_TOOLCHAIN = /home/$(USER_FOLDER_NAME)/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/bin
GNU_TOOLCHAIN_GCC_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-gcc
GNU_TOOLCHAIN_GDB_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-gdb
GNU_TOOLCHAIN_SIZE_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-size
else
# Настройки для Windows
GNU_TOOLCHAIN = C:/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/tools/bin
GNU_TOOLCHAIN_GCC_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-gcc.exe
GNU_TOOLCHAIN_GDB_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-gdb.exe
GNU_TOOLCHAIN_SIZE_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-size.exe
endif

# OpenOCD:
ifeq ($(OS_IS_LINUX), 1)
# Настройки для Linux
OPEN_OCD_PATH = /usr
OPEN_OCD_BIN_PATH = $(OPEN_OCD_PATH)/bin/openocd
else
# Настройки для Windows
OPEN_OCD_PATH = C:/dev_tools/STM32_tools/OpenOCD-20240916-0.12.0
OPEN_OCD_BIN_PATH = $(OPEN_OCD_PATH)/bin/openocd.exe
endif


# OpenOCD, кофигурационные файлы под St-Link и микроконтроллер:
ifeq ($(OS_IS_LINUX), 1)
# Настройки для Linux
OPEN_OCD_INTERFACE_PATH = $(OPEN_OCD_PATH)/share/openocd/scripts/interface/stlink.cfg
OPEN_OCD_TARGET_PATH = $(OPEN_OCD_PATH)/share/openocd/scripts/target/stm32f4x.cfg
else
# Настройки для Windows
OPEN_OCD_INTERFACE_PATH = $(OPEN_OCD_PATH)/share/openocd/scripts/interface/stlink.cfg
OPEN_OCD_TARGET_PATH = $(OPEN_OCD_PATH)/share/openocd/scripts/target/stm32f4x.cfg
endif


# SVD файл для описания периферии микроконтроллера
ifeq ($(OS_IS_LINUX), 1)
# Настройки для Linux
SVD_FILE_PATH =/home/$(USER_FOLDER_NAME)/dev_tools/STM32_tools/cmsis-svd-stm32/stm32f4/STM32F401.svd
else
# Настройки для Windows
SVD_FILE_PATH = C:/dev_tools/STM32_tools/cmsis-svd-stm32/stm32f4/STM32F401.svd
endif

#######################################################################################################################################
# Название проекта
#######################################################################################################################################
TARGET = Clean_project

#######################################################################################################################################
# Build path
#######################################################################################################################################
BUILD_DIR = Debug

#######################################################################################################################################
# Source location (Вводим через пробел, либо с новой строки, но с знаком '\' в конце)
#######################################################################################################################################
# GNU C 
C_SOURCES = \
Core/Src/main.c \
Core/Src/syscalls.c \
Core/Src/sysmem.c \
Core/Src/system_stm32f4xx.c

# Assembly (Обратите внимание, почему-то STM32 выпускает ASM файлы, 
# то с расширением *.S, то c расширением *.s). Это важно. 
# Для унификации переименуйте в *.s (с маленькой буквой)
ASM_SOURCES = \
Core/Startup/startup_stm32f401ceux.s

#######################################################################################################################################
# Include location (Вводим через пробел, либо с новой строки, но с знаком '\' в конце)
# Пример: C_INCLUDES = Core/Inc Drivers/CMSIS 
#######################################################################################################################################
# C includes
C_INCLUDES = \
Core/Inc/ \
Drivers/CMSIS/

# Assembly includes
AS_INCLUDES = 

#######################################################################################################################################
# MCU_Settings
#######################################################################################################################################

CPU = -mcpu=cortex-m4
INSTRUCTION_SET = -mthumb
FPU = -mfpu=fpv4-sp-d16
FLOAT_ABI = -mfloat-abi=hard

MCU = $(CPU) $(INCTRUCTION_SET) $(FPU) $(FLOAT_ABI) -specs=nano.specs

#######################################################################################################################################
# MCU_GCC_Compiler (CFLAGS) (ASFLAGS)
#######################################################################################################################################

# Defines (Записываются через пробел. Пример: C_DEFS =  DEBUG STM32F103xB)
# GNU C
C_DEFS =  DEBUG STM32F401xE
# Assembly
AS_DEFS = DEBUG

# Language standard
LANG_STD = -std=gnu11

# Optimization
#(None "-O0", Optimize for Debug "-Og", Optimize "-O1", Optimize more "-O2",
# Optimize most "-O3", Optimize for size "-Os", Optimize for speed "-Ofast") 
OPT = -O0 

# Debug level(None " ", Minimal "-g1", Default "-g", Maximum "-g3" )
DEBUG = -g3

# compile gcc flags
ASFLAGS = $(MCU) $(DEBUG) $(OPT) $(addprefix -, $(AS_DEFS)) $(AS_INCLUDES) 
CFLAGS = $(MCU) $(DEBUG) $(OPT) $(LANG_STD) $(addprefix -D, $(C_DEFS)) $(addprefix -I, $(C_INCLUDES))  -Wall -fdata-sections -ffunction-sections -fstack-usage

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"
ASFLAGS += -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@"

#######################################################################################################################################
# Binaries
#######################################################################################################################################
PREFIX = arm-none-eabi-

ifdef GNU_TOOLCHAIN
CC = $(GNU_TOOLCHAIN)/$(PREFIX)gcc
AS = $(GNU_TOOLCHAIN)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GNU_TOOLCHAIN)/$(PREFIX)objcopy
SZ = $(GNU_TOOLCHAIN)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################################################################################################################
# LDFLAGS
#######################################################################################################################################
# link script
LDSCRIPT = \
STM32F401CEUX_FLASH.ld

# libraries
LIBS = -Wl,--start-group -lc -lm -Wl,--end-group
LIBDIR = 
LDFLAGS = $(MCU) -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################################################################################################################
# build the application (Можно не трогать этот участок)
#######################################################################################################################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		


#######################################################################################################################################
# update json files (Обновить JSON файлы в соответствие с данным Makefile). Работает под PowerShell (Core, 7+)
#######################################################################################################################################

update-json:
	pwsh -executionpolicy bypass -File .vscode/ps_scripts/Makefile_update_json.ps1 "$(TARGET)" "$(BUILD_DIR)" "$(C_INCLUDES)" "$(C_DEFS)" "$(GNU_TOOLCHAIN_GCC_PATH)" "$(CFLAGS)" "$(GNU_TOOLCHAIN_GDB_PATH)" "$(OPEN_OCD_BIN_PATH)" "$(OPEN_OCD_INTERFACE_PATH) $(OPEN_OCD_TARGET_PATH)" "$(SVD_FILE_PATH)" "$(GNU_TOOLCHAIN_SIZE_PATH)"


#######################################################################################################################################
# update .clang file (Обновить .clang файл в соответствие с данным Makefile). Работает под PowerShell (Core, 7+)
#######################################################################################################################################

update-clang:
	pwsh -executionpolicy bypass -File .vscode/ps_scripts/clangd_update.ps1 "$(COMPILER_PATH)" "$(ISYSTEM_INCLUDE_PATH_1)" "$(ISYSTEM_INCLUDE_PATH_2)"

#######################################################################################################################################
# *.ld Анализатор
#######################################################################################################################################

ifeq ($(OS_IS_LINUX), 1)
# Настройки для Linux
ld_analyzer:
	python3 .vscode/py_scripts/ld_analyzer.py $(LDSCRIPT) json > memory_config.json
else
# Настройки для Windows
ld_analyzer:
	python .vscode/py_scripts/ld_analyzer.py $(LDSCRIPT) json > memory_config.json
endif


#######################################################################################################################################
# clean up (Очистить проект)
#######################################################################################################################################

CLANGD_CACHE = .cache # Кэш clangd

clean:
	rm -rf $(BUILD_DIR) $(CLANGD_CACHE) compile_commands.json memory_config.json



#######################################################################################################################################
# OpenOCD (Записать прошивку на мк, очистить память мк, продолжить работу мк после debug)
#######################################################################################################################################
#Именно для STM32 можно подсмотреть здесь https://openocd.org/doc/html/Flash-Commands.html
#Здесь есть flash driver под соответствующую линейку мк:
#stm32f1x - STM32F0, STM32F1 and STM32F3, GD32F1, GD32VF103 (RISC-V core), GD32F3 and GD32E23. APM32F0 and APM32F1
#stm32f2x - STM32F2, STM32F4 and STM32F7 microcontroller families from STMicroelectronics include internal flash and use ARM Cortex-M3/M4/M7 cores. The driver also works for the APM32F4 series from Geehy Semiconductor.
#stm32h7x - All members of the STM32H7 microcontroller families from STMicroelectronics include internal flash and use ARM Cortex-M7 core. 
#stm32lx  - All members of the STM32L0 and STM32L1 microcontroller families from STMicroelectronics include internal flash and use ARM Cortex-M3 and Cortex-M0+ cores.
#stm32l4x - All members of the STM32 C0, G0, G4, L4, L4+, L5, U0, U5, WB and WL microcontroller families from STMicroelectronics include internal flash and use ARM Cortex-M0+, M4 and M33 cores.

flash: all
	$(OPEN_OCD_BIN_PATH) -f $(OPEN_OCD_INTERFACE_PATH) -f $(OPEN_OCD_TARGET_PATH) -c "program $(BUILD_DIR)/$(TARGET).elf verify reset exit"

erase: 
	$(OPEN_OCD_BIN_PATH) -f $(OPEN_OCD_INTERFACE_PATH) -f $(OPEN_OCD_TARGET_PATH) -c "init; reset halt; stm32f2x mass_erase 0; reset run; exit"

resume:
	$(OPEN_OCD_BIN_PATH) -f $(OPEN_OCD_INTERFACE_PATH) -f $(OPEN_OCD_TARGET_PATH) -c "init; reset halt; resume; exit"



#######################################################################################################################################
# dependencies
#######################################################################################################################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***



