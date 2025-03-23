#   Makefile for STM32F103C8T6
#   Автор: Волков Олег
#   Дата создания скрипта: 23.03.2025
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

######################################################################################
# Пути для проекта
######################################################################################
# GNU Arm Embedded Toolchain:
GNU_TOOLCHAIN = C:/dev_tools/STM32_tools/gnu-tools-for-stm32.12.3/tools/bin
GNU_TOOLCHAIN_GCC_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-gcc.exe
GNU_TOOLCHAIN_GDB_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-gdb.exe
GNU_TOOLCHAIN_SIZE_PATH = $(GNU_TOOLCHAIN)/arm-none-eabi-size.exe

# OpenOCD:
OPEN_OCD_PATH = C:/dev_tools/STM32_tools/OpenOCD-20240916-0.12.0
OPEN_OCD_BIN_PATH = $(OPEN_OCD_PATH)/bin/openocd.exe

# OpenOCD, кофигурационные файлы под St-Link и микроконтроллер:
OPEN_OCD_INTERFACE_PATH = $(OPEN_OCD_PATH)/share/openocd/scripts/interface/stlink.cfg
OPEN_OCD_TARGET_PATH = $(OPEN_OCD_PATH)/share/openocd/scripts/target/stm32f1x.cfg

# SVD файл для описания периферии микроконтроллера
SVD_FILE_PATH = C:/dev_tools/STM32_tools/cmsis-svd-stm32/stm32f1/STM32F103.svd

#####################################################################################
# Название проекта
#####################################################################################
TARGET = Clean_project

#####################################################################################
# Build path
#####################################################################################
BUILD_DIR = Debug

#####################################################################################
# Source location (Вводим через пробел, либо с новой строки, но с знаком '\' в конце)
#####################################################################################
# GNU C 
C_SOURCES = \
Core/Src/main.c \
Core/Src/stm32f103xx_CMSIS.c \
Core/Src/syscalls.c \
Core/Src/sysmem.c \
Core/Src/system_stm32f1xx.c \
Core/Src/tasks_list.c \
FreeRTOS/croutine.c \
FreeRTOS/event_groups.c \
FreeRTOS/list.c \
FreeRTOS/queue.c \
FreeRTOS/stream_buffer.c \
FreeRTOS/tasks.c \
FreeRTOS/timers.c \
FreeRTOS/portable/port.c \
FreeRTOS/portable/MemMang/heap_4.c
# Assembly (Обратите внимание, почему-то STM32 выпускает ASM файлы, 
# то с расширением *.S, то c расширением *.s). Это важно. 
# Для унификации переименуйте в *.s (с маленькой буквой)
ASM_SOURCES = \
Core/Startup/startup_stm32f103c8tx.s

#####################################################################################
# Include location (Вводим через пробел, либо с новой строки, но с знаком '\' в конце)
# Пример: C_INCLUDES = Core/Inc Drivers/CMSIS 
#####################################################################################
# C includes
C_INCLUDES = \
Core/Inc/ \
FreeRTOS/portable/ \
FreeRTOS/ \
Drivers/CMSIS/ \
FreeRTOS/include/
# Assembly includes
AS_INCLUDES = 

#####################################################################################
# MCU_Settings
#####################################################################################

CPU = -mcpu=cortex-m3
INSTRUCTION_SET = -mthumb
FPU =
FLOAT_ABI = -mfloat-abi=soft

MCU = $(CPU) $(INCTRUCTION_SET) $(FPU) $(FLOAT_ABI) -specs=nano.specs

#####################################################################################
# MCU_GCC_Compiler (CFLAGS) (ASFLAGS)
#####################################################################################

# Defines (Записываются через пробел. Пример: C_DEFS =  DEBUG STM32F103xB)
# GNU C
C_DEFS =  DEBUG STM32F103xB
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

#####################################################################################
# Binaries
#####################################################################################
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

#####################################################################################
# LDFLAGS
#####################################################################################
# link script
LDSCRIPT = \
STM32F103C8TX_FLASH.ld

# libraries
LIBS = -Wl,--start-group -lc -lm -Wl,--end-group
LIBDIR = 
LDFLAGS = $(MCU) -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#####################################################################################
# build the application (Можно не трогать этот участок)
#####################################################################################
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


##########################################################################
# update json files (Обновить JSON файлы в соответствие с данным Makefile)
##########################################################################

update-json:
	powershell.exe -executionpolicy bypass -File .vscode/ps_scripts/Makefile_update_json.ps1 "$(TARGET)" "$(BUILD_DIR)" "$(C_INCLUDES)" "$(C_DEFS)" "$(GNU_TOOLCHAIN_GCC_PATH)" "$(CFLAGS)" "$(GNU_TOOLCHAIN_GDB_PATH)" "$(OPEN_OCD_BIN_PATH)" "$(OPEN_OCD_INTERFACE_PATH) $(OPEN_OCD_TARGET_PATH)" "$(SVD_FILE_PATH)" "$(GNU_TOOLCHAIN_SIZE_PATH)"

##########################################################################
# clean up (for Windows)
##########################################################################
clean:
	rmdir /S /Q $(BUILD_DIR)

#########################################################################
# OpenOCD (Записать прошивку на мк и очистить память мк)
##########################################################################
flash: all
	$(OPEN_OCD_BIN_PATH) -f $(OPEN_OCD_INTERFACE_PATH) -f $(OPEN_OCD_TARGET_PATH) -c "program $(BUILD_DIR)/$(TARGET).elf verify reset exit"

erase: 
	$(OPEN_OCD_BIN_PATH) -f $(OPEN_OCD_INTERFACE_PATH) -f $(OPEN_OCD_TARGET_PATH) -c "init; reset halt; stm32f1x mass_erase 0; reset run; exit"

resume:
	$(OPEN_OCD_BIN_PATH) -f $(OPEN_OCD_INTERFACE_PATH) -f $(OPEN_OCD_TARGET_PATH) -c "init; reset halt; resume; exit"
##########################################################################
# dependencies
##########################################################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***