#   Makefile update json
#   Автор: Волков Олег
#   Дата создания скрипта: 28.02.2025
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

$DELAY = 500

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
        # Чтение JSON-файла
        $jsonContent = Get-Content -Path $JsonFilePath -Raw -Encoding utf8
        # Регулярное выражение для поиска и замены значения параметра
        $pattern = "`"$ParameterName`":\s*\[[^\]]*\]"
        $updatedJsonContent = $jsonContent -replace $pattern, "`"$ParameterName`": [$NewValue]"
        # Сохранение изменённого JSON обратно в файл
        Start-Sleep -Milliseconds $DELAY
        Set-Content -Path $JsonFilePath -Value $updatedJsonContent -Encoding utf8 -NoNewline 
        Write-Host "Success" -ForegroundColor Green
    }
    catch {
        Write-Host "Error" -ForegroundColor Red
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
        # Чтение JSON-файла
        $jsonContent = Get-Content -Path $JsonFilePath -Raw -Encoding utf8
        # Регулярное выражение для поиска и замены значения параметра
        $pattern = "`"$ParameterName`":\s*`"[^`"]*`""
        $updatedJsonContent = $jsonContent -replace $pattern, "`"$ParameterName`": `"$NewValue`""
        # Сохранение изменённого JSON обратно в файл
        Start-Sleep -Milliseconds $DELAY
        Set-Content -Path $JsonFilePath -Value $updatedJsonContent -Encoding utf8 -NoNewline
        Write-Host "Success" -ForegroundColor Green
    }
    catch {
        Write-Host "Error" -ForegroundColor Red
    }
}

############################################ Читаем и правим файл c_cpp_properties.json ############################################
# Читаем текущее значение поля "name" из файла
$C_CPP_PROPERTIES_PATH = ".vscode/c_cpp_properties.json"
Write-Host "file $C_CPP_PROPERTIES_PATH`:" -ForegroundColor DarkYellow

# Преобразуем TARGET в формат, удобоваримыя для c_cpp_properties.json
Write-Host "Makefile TARGET = $TARGET -> `"name`": `"$TARGET`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue $TARGET -ParameterName "name"  

#Преобразуем $C_INCLUDES в формат, удобоваримый для c_cpp_properties.json
$formattedPaths = Parser_args -inputString $C_INCLUDES
Write-Host "Makefile C_INCLUDES = $C_INCLUDES -> 'includePath: [$formattedPaths]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue "$formattedPaths" -ParameterName "includePath"

#Преобразуем $C_DEFS в формат, удобоваримый для c_cpp_properties.json
$formattedDefs = Parser_args -inputString $C_DEFS -Prefix "" -Suffix ""
Write-Host "Makefile C_DEFS = $C_DEFS -> 'defines: [$formattedDefs]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue "$formattedDefs" -ParameterName "defines" 

# Преобразуем $GNU_TOOLCHAIN_GCC_PATH в формат, удобоваримыя для c_cpp_properties.json
Write-Host "Makefile GNU_TOOLCHAIN_GCC_PATH = $GNU_TOOLCHAIN_GCC_PATH -> `"compilerPath`": `"$GNU_TOOLCHAIN_GCC_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue $GNU_TOOLCHAIN_GCC_PATH -ParameterName "compilerPath"

#Преобразуем $CFLAGS в формат, удобоваримый для c_cpp_properties.json
$formattedCFLAGS = Parser_args -inputString $CFLAGS -Prefix "" -Suffix ""
Write-Host "Makefile CFLAGS = $CFLAGS -> 'compilerArgs: [$formattedCFLAGS]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $C_CPP_PROPERTIES_PATH -NewValue "$formattedCFLAGS" -ParameterName "compilerArgs" 
############################################ Читаем и правим файл c_cpp_properties.json ############################################


################################################# Читаем и правим файл launch.json #################################################
# Читаем файл launch.json
$LAUNCH_PATH = ".vscode/launch.json"
Write-Host "file $LAUNCH_PATH`: " -ForegroundColor DarkYellow 

# Заменяем текущее значение поля "executable" из файла
# Преобразуем TARGET/BUILD в формат, удобоваримыя для launch.json
Write-Host "Makefile BUILD_DIR/TARGET = $BUILD_DIR/$TARGET -> `"executable`": `"$BUILD_DIR/$TARGET.elf`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue "$BUILD_DIR/$TARGET.elf" -ParameterName "executable"  

# Заменяем текущее значение поля "gdbPath" из файла
# Преобразуем TARGET/BUILD в формат, удобоваримыя для launch.json
Write-Host "Makefile GNU_TOOLCHAIN_GDB_PATH = $GNU_TOOLCHAIN_GDB_PATH -> `"gdbPath`": `"$GNU_TOOLCHAIN_GDB_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue $GNU_TOOLCHAIN_GDB_PATH -ParameterName "gdbPath"

# Заменяем текущее значение поля "serverpath" из файла
# Преобразуем OPEN_OCD_BIN_PATH в формат, удобоваримыя для launch.json
Write-Host "Makefile OPEN_OCD_BIN_PATH = $OPEN_OCD_BIN_PATH -> `"serverpath`": `"$OPEN_OCD_BIN_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue $OPEN_OCD_BIN_PATH -ParameterName "serverpath"

# Заменяем текущее значение поля "configFiles" из файла
#Преобразуем OPEN_OCD_INTERFACE_AND_TARGET_PATH в формат, удобоваримый для launch.json
$formattedOpenOCDFiles = Parser_args -inputString $OPEN_OCD_INTERFACE_AND_TARGET_PATH -Prefix "" -Suffix ""
Write-Host "Makefile OPEN_OCD_INTERFACE_AND_TARGET_PATH = $OPEN_OCD_INTERFACE_AND_TARGET_PATH -> 'configFiles: [$formattedOpenOCDFiles]' " -ForegroundColor White
Update_Json_Array_of_parameters -JsonFilePath $LAUNCH_PATH -NewValue "$formattedOpenOCDFiles" -ParameterName "configFiles"

# Заменяем текущее значение поля "svdFile" из файла
# Преобразуем SVD_FILE_PATH в формат, удобоваримыя для launch.json
Write-Host "Makefile OPEN_OCD_BIN_PATH = $SVD_FILE_PATH -> `"svdFile`": `"$SVD_FILE_PATH`" " -ForegroundColor White
Update_Json_Parameter -JsonFilePath $LAUNCH_PATH -NewValue $SVD_FILE_PATH -ParameterName "svdFile"
################################################# Читаем и правим файл launch.json #################################################



################################################# Читаем и правим файл launch.json #################################################
####        ВНИМАНИЕ, ДАННАЯ ФУНКЦИЯ БУДЕТ РАБОТАТЬ ХОРОШО, ЕСЛИ В task.json БОЛЬШЕ НЕ БУДЕТ СТРОКИ ПАРАМЕТРОВ С "args": [ ]

# Читаем файл tasks.json, заменяем строку с .elf и сохраняем изменения
Write-Host "file tasks.json: " -ForegroundColor DarkYellow

Write-Host "string replacement 'args: $BUILD_DIR/$TARGET.elf' " -ForegroundColor Green
(Get-Content .vscode/tasks.json -Raw -Encoding utf8) -replace '([\"''])([^\"'']*\.elf)([\"''])', "`$1$BUILD_DIR/$TARGET.elf`$3" | Out-File .vscode/tasks.json -Encoding utf8
Start-Sleep -Milliseconds $DELAY

# Читаем файл tasks.json, заменяем строку с .map и сохраняем изменения
Write-Host "string replacement 'args: $BUILD_DIR/$TARGET.map' " -ForegroundColor Green
(Get-Content .vscode/tasks.json -Raw -Encoding utf8) -replace '([\"''])([^\"'']*\.map)([\"''])', "`$1$BUILD_DIR/$TARGET.map`$3" | Out-File .vscode/tasks.json -Encoding utf8
################################################# Читаем и правим файл launch.json #################################################



####################################################### BONUS ######################################################################

Write-Host "Bonus :) Update files:" -ForegroundColor DarkBlue




############################ Читаем и правим файл .vscode/ps_scripts/Build_Analyzer.ps1
Write-Host "file .vscode/ps_scripts/Build_Analyzer.ps1" -ForegroundColor DarkBlue
$newPath = $GNU_TOOLCHAIN_SIZE_PATH.Replace("/", "\")
$content = Get-Content ".vscode/ps_scripts/Build_Analyzer.ps1" -Raw -Encoding utf8
$updatedContent = $content -replace '(\$GNU_TOOLCHAIN_SIZE_PATH\s*=\s*).*', "`$GNU_TOOLCHAIN_SIZE_PATH = `"$newPath`""
Set-Content ".vscode/ps_scripts/Build_Analyzer.ps1" $updatedContent -Encoding utf8
Write-Host "Success" -ForegroundColor Green