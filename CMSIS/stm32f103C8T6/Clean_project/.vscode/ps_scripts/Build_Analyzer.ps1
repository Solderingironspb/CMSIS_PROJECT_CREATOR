#   Build Analyzer v1.0
#   Автор: Волков Олег
#   Дата создания скрипта: 26.02.2025
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

#Укажите путь до arm-none-eabi-size.exe
$GNU_TOOLCHAIN_SIZE_PATH = "C:\dev_tools\STM32_tools\gnu-tools-for-stm32.12.3\tools\bin\arm-none-eabi-size.exe"

# Путь к .elf файлу
$elfFile = $args[0]

# Путь к .map файлу
$mapFile = $args[1]

# Размер памяти RAM (KB) Смотри ld файл
$ram_size_ld_file = "20"

# Размер памяти FLASH (KB) Смотри ld файл
$flash_size_ld_file = "64"

# Memory Details (true/false) Показывать или нет детальную информацию
$memory_details = "false"


# Проверка, существует ли *.elf файл
if (-Not (Test-Path $elfFile)) {
    Write-Host "File $elfFile not found." -ForegroundColor Red
    exit
}

# Проверка, существует ли *.map файл
if (-Not (Test-Path $mapFile)) {
    Write-Host "File $mapFile not found." -ForegroundColor Red
    exit
}


# Чтение содержимого .map файла
$mapContent = Get-Content -Path $mapFile

# Поиск строк с информацией о памяти
$memoryConfig = $mapContent | Select-String -Pattern '^(FLASH|RAM|CCMRAM|DTCMRAM|RAM_D1|RAM_D2|RAM_D3|ITCMRAM)\s+0x[0-9A-Fa-f]+\s+0x[0-9A-Fa-f]+\s+[a-z]+'

# Создание массива для хранения данных
$memoryData = @()

# Обработка найденных строк
foreach ($line in $memoryConfig) {
    # Разделение строки на части
    $parts = $line -split '\s+'

    # Извлечение значений
    $name = $parts[0]
    $origin = $parts[1]
    $length = $parts[2]
    $attributes = $parts[3]

    # Сохранение значений в хэш-таблицу
    $memoryEntry = @{
        Name       = $name
        Origin     = $origin
        Length     = $length
        Attributes = $attributes
    }

    # Добавление хэш-таблицы в массив
    $memoryData += $memoryEntry
}

# Сохранение данных в переменные
$FLASH = $memoryData | Where-Object { $_.Name -eq "FLASH" }
$RAM = $memoryData | Where-Object { $_.Name -eq "RAM" }

$RAM_Start_address = [int]$RAM.Origin
$RAM_End_address = [int]$RAM.Origin + [int]$RAM.Length 

$Flash_Start_address = [int]$FLASH.Origin
$flash_End_address = [int]$FLASH.Origin + [int]$FLASH.Length 

# Показывать или нет детальную информацию?
if (($memory_details -eq "true") -or ($memory_details -eq "True") -or ($memory_details -eq 1)) {
    Write-Host "Memory Details:" -ForegroundColor Green
    & $GNU_TOOLCHAIN_SIZE_PATH -A $elfFile
}


# Запуск arm-none-eabi-size и получение вывода
$sizeOutput = & $GNU_TOOLCHAIN_SIZE_PATH -A $elfFile

# Извлечение значений
# Список интересующих нас секций
$sections = @('.isr_vector', '.text', '.rodata', '.ARM', '.init_array', '.fini_array', '.data', '.bss', '._user_heap_stack')

# Создаем хэш-таблицу для хранения результатов
$sectionSizes = @{}

# Обрабатываем каждую секцию
foreach ($section in $sections) {
    $line = $sizeOutput | Select-String -Pattern $section
    if ($line) {
        $size = ($line -split '\s+')[1]
        $sectionSizes[$section] = [int]$size
    }
    else {
        Write-Warning "Секция $section не найдена в выводе."
    }
}

# Теперь значения доступны в хэш-таблице $sectionSizes
# Например, можно получить размер секции .text так:

# Расчет FLASH и RAM
[int]$ramUsed = $sectionSizes['.data'] + $sectionSizes['.bss'] + $sectionSizes['._user_heap_stack']
[int]$flashUsed = $sectionSizes['.isr_vector'] + $sectionSizes['.rodata'] + $sectionSizes['.init_array'] + $sectionSizes['.fini_array'] + $sectionSizes['.text'] + $sectionSizes['.data']
    

# Размеры памяти (замените на свои значения)
$ramSize = [int]$ram_size_ld_file * 1024    
$flashSize = [int]$flash_size_ld_file * 1024  


$ramFree = $ramSize - $ramUsed
$flashFree = $flashSize - $flashUsed    

# Расчет процентов
$flashPercent = [math]::Round(($flashUsed / $flashSize) * 100, 2)
$ramPercent = [math]::Round(($ramUsed / $ramSize) * 100, 2)

# Вывод
Write-Host "Memory Regions:" -NoNewline -ForegroundColor Green
# Создание объектов для таблицы
$data = @(
    [PSCustomObject]@{
        "Region    "        = "RAM:" 
        "Start address    " = "0x$("{0:X8}" -f $RAM_Start_address)"
        "End address    "   = "0x$("{0:X8}" -f $RAM_End_address)"
        "Size      "        = "$([math]::Round($ramSize / 1024)) KB"
        "Free      "        = "$([math]::Round($ramFree / 1024, 2)) KB"
        "Used      "        = "$([math]::Round($ramUsed / 1024, 2)) KB"
        "Usage (%)"         = "$ramPercent%"
    },
    [PSCustomObject]@{
        "Region    "        = "FLASH:"
        "Start address    " = "0x$("{0:X8}" -f $FLASH_Start_address)"
        "End address    "   = "0x$("{0:X8}" -f $FLASH_End_address)"
        "Size      "        = "$([math]::Round($flashSize / 1024)) KB"
        "Free      "        = "$([math]::Round($flashFree / 1024, 2)) KB"
        "Used      "        = "$([math]::Round($flashUsed / 1024, 2)) KB"
        "Usage (%)"         = "$flashPercent%"
    }
)

# Вывод таблицы
$data | Format-Table -AutoSize 

















