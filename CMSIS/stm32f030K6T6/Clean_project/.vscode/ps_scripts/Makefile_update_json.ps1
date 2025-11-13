#   Читаю Makefile. Переменная update json v1.2
#   Автор: Волков Олег
#   Дата создания скрипта: 12.11.2025
#   ВАЖНО: Работает под PowerShell (Core, 7+)
#   Для установки в Windows откройте powershell и введите: winget install Microsoft.Powershell 
#   Для установки в Linux откройте konsole (на примере Debian 13) и введите: sudo snap install powershell --classic
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749
#   Изменения: Ускорено обновление файлов. Теперь задержка не требуется. Обновление json файлов происходит мгновенно.
#   Также добавлено обновление параметра -j в командах сборки (Количество логических процессоров для параллельной сборки).

# Функция для безопасной записи в файл с повторными попытками
function Write-FileWithRetry {
    param(
        [string]$Path,
        [string]$Value,
        [int]$MaxRetries = 10,
        [int]$RetryDelayMs = 50
    )
    
    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            Set-Content -Path $Path -Value $Value -Encoding utf8 -NoNewline -ErrorAction Stop
            return $true
        }
        catch {
            if ($i -eq $MaxRetries - 1) {
                Write-Host "`n Ошибка записи в $Path после $MaxRetries попыток: $($_.Exception.Message)" -ForegroundColor Red
                return $false
            }
            Start-Sleep -Milliseconds $RetryDelayMs
        }
    }
    return $false
}

# Функция для безопасного чтения файла с повторными попытками
function Read-FileWithRetry {
    param(
        [string]$Path,
        [int]$MaxRetries = 5,
        [int]$RetryDelayMs = 50
    )
    
    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            return Get-Content -Path $Path -Raw -Encoding utf8 -ErrorAction Stop
        }
        catch {
            if ($i -eq $MaxRetries - 1) { 
                Write-Host "Ошибка чтения из $Path после $MaxRetries попыток: $($_.Exception.Message)" -ForegroundColor Red
                throw
            }
            Start-Sleep -Milliseconds $RetryDelayMs
        }
    }
}

# Функция для обновления параметра -j в командах сборки
function Update-JParameterInTasks {
    param(
        [string]$TasksPath,
        [int]$ProcessorCount
    )
    
    # Проверка существования файла
    if (-not (Test-Path -Path $TasksPath)) {
        Write-Host "Файл '$TasksPath' не найден." -ForegroundColor Red
        return
    }
    
    try {
        # Чтение файла с безопасным методом
        $content = Read-FileWithRetry -Path $TasksPath
        
        # Простая замена - ищем любые -j с цифрами после них
        $pattern = '-j\s*\d+'
        $replacement = "-j$ProcessorCount"
        
        # Заменяем все вхождения
        $updatedContent = $content -replace $pattern, $replacement
        
        # Проверяем, были ли изменения
        if ($content -ne $updatedContent) {
            # Сохранение изменений с безопасным методом
            if (Write-FileWithRetry -Path $TasksPath -Value $updatedContent) {
                Write-Host "Обновление параметра -j в tasks.json выполнено успешно: -j$ProcessorCount" -ForegroundColor Green
            } else {
                Write-Host "Ошибка сохранения измененного файла tasks.json..." -ForegroundColor Red
            }
        } else {
            Write-Host "Параметры -j в tasks.json не найдены для обновления" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Ошибка обновления параметра -j в tasks.json: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Функция для обновления параметра -j в launch.json (если есть команды сборки)
function Update-JParameterInLaunch {
    param(
        [string]$LaunchPath,
        [int]$ProcessorCount
    )
    
    # Проверка существования файла
    if (-not (Test-Path -Path $LaunchPath)) {
        Write-Host "Файл '$LaunchPath' не найден." -ForegroundColor Red
        return
    }
    
    try {
        # Чтение файла с безопасным методом
        $content = Read-FileWithRetry -Path $LaunchPath
        
        # Простая замена - ищем любые -j с цифрами после них
        $pattern = '-j\s*\d+'
        $replacement = "-j$ProcessorCount"
        
        # Заменяем все вхождения
        $updatedContent = $content -replace $pattern, $replacement
        
        # Проверяем, были ли изменения
        if ($content -ne $updatedContent) {
            # Сохранение изменений с безопасным методом
            if (Write-FileWithRetry -Path $LaunchPath -Value $updatedContent) {
                Write-Host "Обновление параметра -j в launch.json выполнено успешно: -j$ProcessorCount" -ForegroundColor Green
            } else {
                Write-Host "Ошибка сохранения измененного файла launch.json..." -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "Ошибка обновления параметра -j в launch.json: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Получаем аргумент (имя целевого проекта)
$TARGET = $args[0]  #Название проекта
$BUILD_DIR = $args[1]   #Папка, в которой будут складываться файлы для дебага
$C_INCLUDES = $args[2] #Папки через пробел, в которых находятся *.h файлы
$C_DEFS = $args[3] #Defines GNU C
$GNU_TOOLCHAIN_GCC_PATH = $args[4] #arm-none-eabi-gcc.exe
$updatedArgs5 = $args[5] -replace "update-json", "" #костыль, но пусть так...я не знаю почему сюда затисалось это :)
$CFLAGS = $updatedArgs5 #Все аргументы CFLAGS
$GNU_TOOLCHAIN_GDB_PATH = $args[6] #Путь до arm-none-eabi-gdb.exe
$OPEN_OCD_BIN_PATH = $args[7] #Путь до OpenOCD.exe
$OPEN_OCD_INTERFACE_AND_TARGET_PATH = $args[8] #Путь до интерфейса stlink и target файла микроконтроллера
$SVD_FILE_PATH = $args[9] #SVD файл для описания периферии микроконтроллера
$GNU_TOOLCHAIN_SIZE_PATH = $args[10] #Путь до arm-none-eabi-size.exe
$PROCESSOR_COUNT = [Environment]::ProcessorCount #Получить количество логических процессоров на данном ПК (Должно работать на Windows и Linux)

Write-Host "Определяю количество логических процессоров на данном ПК:" $PROCESSOR_COUNT -ForegroundColor DarkBlue
Write-Host "Будет использовано ядер для сборки: -j$PROCESSOR_COUNT" -ForegroundColor DarkBlue


#Функция для преобразования аргументов, записанных через пробел в строку с соответствующими параметрами
function Parser_args {
    param (
        [string]$inputString, # Входная строка с путями
        [string]$Prefix = "`${workspaceFolder}/", # Строка, добавляемая в начало каждого пути (по умолчанию "${workspaceFolder}/")
        [string]$Suffix = "/**"  # Строка, добавляемая в конец каждого пути (по умолчанию "/**")
    )
    # Разделяем строку на отдельные пути по пробелам и удаляем пустые элементы
    $paths = $inputString -split ' ' | Where-Object { $_ -ne '' }
    # Преобразуем каждый путь в нужный формат
    $transformedPaths = $paths | ForEach-Object {
        # Добавляем префикс, путь и суффикс, затем заключаем в кавычки
        "`"$Prefix$_$Suffix`""
    }
    # Объединяем преобразованные пути в одну строку с разделителем ", "
    $result = $transformedPaths -join ', '
    # Возвращаем результат
    return $result
}

# Функция замены массива параметров, когда они заключены в квадратные скобки []
function Update_Json_Array_of_parameters {
    param (
        [string]$JsonFilePath, # Путь к JSON-файлу
        [string]$NewValue, # Новая строка для вставки
        [string]$ParameterName # Название параметра (например, "includePath")
    )
    # Проверка существования файла
    if (-not (Test-Path -Path $JsonFilePath)) {
        Write-Host "Файл '$JsonFilePath' не найден." -ForegroundColor Red
        return
    }
    try {
        # Чтение JSON-файла с безопасным методом
        $jsonContent = Read-FileWithRetry -Path $JsonFilePath
        # Регулярное выражение для поиска и замены значения параметра
        $pattern = "`"$ParameterName`":\s*\[[^\]]*\]"
        $updatedJsonContent = $jsonContent -replace $pattern, "`"$ParameterName`": [$NewValue]"
        # Сохранение изменённого JSON обратно в файл с безопасным методом
        if (Write-FileWithRetry -Path $JsonFilePath -Value $updatedJsonContent) {
            Write-Host "Изменение файла прошло успешно" -ForegroundColor Green
        } else {
            Write-Host "Ошибка сохранения измененного файла..." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Функция замены параметра
function Update_Json_Parameter {
    param (
        [string]$JsonFilePath, # Путь к JSON-файлу
        [string]$NewValue, # Новая строка для вставки
        [string]$ParameterName # Название параметра (например, "name")
    )
    # Проверка существования файла
    if (-not (Test-Path -Path $JsonFilePath)) {
        Write-Host "Файл '$JsonFilePath' не найден." -ForegroundColor Red
        return
    }
    try {
        # Чтение JSON-файла с безопасным методом
        $jsonContent = Read-FileWithRetry -Path $JsonFilePath
        # Регулярное выражение для поиска и замены значения параметра
        $pattern = "`"$ParameterName`":\s*`"[^`"]*`""
        $updatedJsonContent = $jsonContent -replace $pattern, "`"$ParameterName`": `"$NewValue`""
        # Сохранение изменённого JSON обратно в файл с безопасным методом
        if (Write-FileWithRetry -Path $JsonFilePath -Value $updatedJsonContent) {
            Write-Host "Изменение файла прошло успешно" -ForegroundColor Green
        } else {
            Write-Host "Ошибка сохранения измененного файла..." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Функция для безопасного обновления tasks.json
function Update-TasksJson {
    param(
        [string]$BuildDir,
        [string]$Target
    )
    
    $tasksPath = ".vscode/tasks.json"
    
    # Проверка существования файла
    if (-not (Test-Path -Path $tasksPath)) {
        Write-Host "Файл '$tasksPath' не найден." -ForegroundColor Red
        return
    }
    
    try {
        # Чтение файла с безопасным методом
        $content = Read-FileWithRetry -Path $tasksPath
        
        # Заменяем .elf файлы
        Write-Host "string replacement 'args: $BuildDir/$Target.elf' " -ForegroundColor Green
        $content = $content -replace '([\"''])([^\"'']*\.elf)([\"''])', "`$1$BuildDir/$Target.elf`$3"
        
        # Заменяем .map файлы  
        Write-Host "string replacement 'args: $BuildDir/$Target.map' " -ForegroundColor Green
        $content = $content -replace '([\"''])([^\"'']*\.map)([\"''])', "`$1$BuildDir/$Target.map`$3"
        
        # Сохранение изменений с безопасным методом
        if (Write-FileWithRetry -Path $tasksPath -Value $content) {
            Write-Host "Success" -ForegroundColor Green
        } else {
            Write-Host "Error" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error updating tasks.json: $($_.Exception.Message)" -ForegroundColor Red
    }
}

############################################ Читаем и правим файл c_cpp_properties.json ############################################
# Читаем текущее значение поля "name" из файла
$C_CPP_PROPERTIES_PATH = ".vscode/c_cpp_properties.json"
Write-Host "Работаю с файлом: $C_CPP_PROPERTIES_PATH`:" -ForegroundColor DarkYellow

# Преобразуем TARGET в формат, удобоваримыя для c_cpp_properties.json
Write-Host "Читаю Makefile. Переменная TARGET = $TARGET -> `"name`": `"$TARGET`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue $TARGET -ParameterName "name"  

#Преобразуем $C_INCLUDES в формат, удобоваримый для c_cpp_properties.json
$formattedPaths = Parser_args -inputString $C_INCLUDES
Write-Host "Читаю Makefile. Переменная C_INCLUDES = $C_INCLUDES -> 'includePath: [$formattedPaths]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue "$formattedPaths" -ParameterName "includePath"

#Преобразуем $C_DEFS в формат, удобоваримый для c_cpp_properties.json
$formattedDefs = Parser_args -inputString $C_DEFS -Prefix "" -Suffix ""
Write-Host "Читаю Makefile. Переменная C_DEFS = $C_DEFS -> 'defines: [$formattedDefs]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue "$formattedDefs" -ParameterName "defines" 

# Преобразуем $GNU_TOOLCHAIN_GCC_PATH в формат, удобоваримыя для c_cpp_properties.json
Write-Host "Читаю Makefile. Переменная GNU_TOOLCHAIN_GCC_PATH = $GNU_TOOLCHAIN_GCC_PATH -> `"compilerPath`": `"$GNU_TOOLCHAIN_GCC_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue $GNU_TOOLCHAIN_GCC_PATH -ParameterName "compilerPath"

#Преобразуем $CFLAGS в формат, удобоваримый для c_cpp_properties.json
$formattedCFLAGS = Parser_args -inputString $CFLAGS -Prefix "" -Suffix ""
Write-Host "Читаю Makefile. Переменная CFLAGS = $CFLAGS -> 'compilerArgs: [$formattedCFLAGS]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue "$formattedCFLAGS" -ParameterName "compilerArgs" 
############################################ Читаем и правим файл c_cpp_properties.json ############################################


################################################# Читаем и правим файл launch.json #################################################
# Читаем файл launch.json
$LAUNCH_PATH = ".vscode/launch.json"
Write-Host "Работаю с файлом: $LAUNCH_PATH`: " -ForegroundColor DarkYellow 

# Заменяем текущее значение поля "executable" из файла
# Преобразуем TARGET/BUILD в формат, удобоваримыя для launch.json
Write-Host "Читаю Makefile. Переменная BUILD_DIR/TARGET = $BUILD_DIR/$TARGET -> `"executable`": `"$BUILD_DIR/$TARGET.elf`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue "$BUILD_DIR/$TARGET.elf" -ParameterName "executable"  

# Заменяем текущее значение поля "gdbPath" из файла
# Преобразуем TARGET/BUILD в формат, удобоваримыя для launch.json
Write-Host "Читаю Makefile. Переменная GNU_TOOLCHAIN_GDB_PATH = $GNU_TOOLCHAIN_GDB_PATH -> `"gdbPath`": `"$GNU_TOOLCHAIN_GDB_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue $GNU_TOOLCHAIN_GDB_PATH -ParameterName "gdbPath"

# Заменяем текущее значение поля "serverpath" из файла
# Преобразуем OPEN_OCD_BIN_PATH в формат, удобоваримыя для launch.json
Write-Host "Читаю Makefile. Переменная OPEN_OCD_BIN_PATH = $OPEN_OCD_BIN_PATH -> `"serverpath`": `"$OPEN_OCD_BIN_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue $OPEN_OCD_BIN_PATH -ParameterName "serverpath"

# Заменяем текущее значение поля "configFiles" из файла
#Преобразуем OPEN_OCD_INTERFACE_AND_TARGET_PATH в формат, удобоваримый для launch.json
$formattedOpenOCDFiles = Parser_args -inputString $OPEN_OCD_INTERFACE_AND_TARGET_PATH -Prefix "" -Suffix ""
Write-Host "Читаю Makefile. Переменная OPEN_OCD_INTERFACE_AND_TARGET_PATH = $OPEN_OCD_INTERFACE_AND_TARGET_PATH -> 'configFiles: [$formattedOpenOCDFiles]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $LAUNCH_PATH -NewValue "$formattedOpenOCDFiles" -ParameterName "configFiles"

# Заменяем текущее значение поля "svdFile" из файла
# Преобразуем SVD_FILE_PATH в формат, удобоваримыя для launch.json
Write-Host "Читаю Makefile. Переменная OPEN_OCD_BIN_PATH = $SVD_FILE_PATH -> `"svdFile`": `"$SVD_FILE_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue $SVD_FILE_PATH -ParameterName "svdFile"

# ОБНОВЛЯЕМ ПАРАМЕТР -j В КОМАНДАХ СБОРКИ (если есть)
Update-JParameterInLaunch -LaunchPath $LAUNCH_PATH -ProcessorCount $PROCESSOR_COUNT
################################################# Читаем и правим файл launch.json #################################################



################################################# Читаем и правим файл tasks.json #################################################
####        ВНИМАНИЕ, ДАННАЯ ФУНКЦИЯ БУДЕТ РАБОТАТЬ ХОРОШО, ЕСЛИ В task.json БОЛЬШЕ НЕ БУДЕТ СТРОКИ ПАРАМЕТРОВ С "args": [ ]

# Читаем файл tasks.json, заменяем строку с .elf и .map и сохраняем изменения
Write-Host "Работаю с файлом: tasks.json: " -ForegroundColor DarkYellow
Update-TasksJson -BuildDir $BUILD_DIR -Target $TARGET

# ОБНОВЛЯЕМ ПАРАМЕТР -j В КОМАНДАХ СБОРКИ
Update-JParameterInTasks -TasksPath ".vscode/tasks.json" -ProcessorCount $PROCESSOR_COUNT
################################################# Читаем и правим файл tasks.json #################################################



####################################################### BONUS ######################################################################

Write-Host "Bonus :) Update files:" -ForegroundColor DarkBlue

############################ Читаем и правим файл .vscode/tasks.json
Write-Host "Работаю с файлом: .vscode/tasks.json" -ForegroundColor DarkBlue
$newPath = $GNU_TOOLCHAIN_SIZE_PATH.Replace("/", "\").Replace("\", "/")

try {
    # Читаем и парсим JSON
    $jsonContent = Get-Content -Path ".vscode/tasks.json" -Raw | ConvertFrom-Json
    
    $changed = $false
    
    # Ищем таску "Build Analyzer"
    foreach ($task in $jsonContent.tasks) {
        if ($task.label -eq "Build Analyzer") {
            # Проверяем, что есть минимум 6 аргументов
            if ($task.args.Count -ge 6) {
                # Меняем 6-й аргумент (индекс 5)
                $task.args[5] = $newPath
                $changed = $true
            }
            break
        }
    }
    
    if ($changed) {
        # Конвертируем обратно в JSON с красивым форматированием
        $updatedJson = $jsonContent | ConvertTo-Json -Depth 10
        
        if (Write-FileWithRetry -Path ".vscode/tasks.json" -Value $updatedJson) {
            Write-Host "Success" -ForegroundColor Green
        } else {
            Write-Host "Error" -ForegroundColor Red
        }
    } else {
        Write-Host "Build Analyzer task or 6th argument not found" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error updating tasks.json: $($_.Exception.Message)" -ForegroundColor Red
}