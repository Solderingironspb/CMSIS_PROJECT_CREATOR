#   Find files for Makefile v1.1
#   Автор: Волков Олег
#   Дата создания скрипта: 05.10.2025
#   ВАЖНО: Работает под PowerShell (Core, 7+)
#   Для установки в Windows откройте powershell и введите: winget install Microsoft.Powershell 
#   Для установки в Linux откройте konsole (на примере Debian 13) и введите: sudo snap install powershell --classic
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

Write-Host "Find files for Makefile v1.1" -ForegroundColor White
Write-Host "Autor: Volkov Oleg" -ForegroundColor White
Write-Host ""

# Укажите путь к директории, в которой нужно искать файлы
$directoryPath = (Get-Item (Join-Path $PSScriptRoot "..\..")).FullName

# Проверка существования директории
if (Test-Path $directoryPath) {
    Write-Host "Поиск файлов в директории: $directoryPath"
    # Дальнейший код для поиска файлов
} else {
    Write-Host "Директория не найдена: $directoryPath" -ForegroundColor Red
}

# Находим все файлы с расширением .c в указанной директории и её поддиректориях
$cFiles = Get-ChildItem -Path $directoryPath -Recurse -Filter *.c

Write-Host "C_SOURCES = \" -ForegroundColor Blue
# Выводим пути к найденным файлам
# Инициализируем счетчик
$i = 0
# Получаем общее количество файлов
$count = $cFiles.Count
foreach ($file in $cFiles) {
    $i++  # Увеличиваем счетчик на каждой итерации
    # Получаем относительный путь к файлу
    $relativePath = $file.FullName.Substring($directoryPath.Length + 1)
    # Заменяем обратные слэши на прямые (для совместимости с Unix-стилем)
    $relativePath = $relativePath -replace "\\", "/"
    # Выводим путь с "\" или без него
    if ($i -lt $count) {
        Write-Host "$relativePath \" -ForegroundColor Blue
    } else {
        Write-Host $relativePath -ForegroundColor Blue
    }
}

Write-Host ""

# Находим все файлы с расширением .s в указанной директории и её поддиректориях
$sFiles = Get-ChildItem -Path $directoryPath -Recurse -Filter *.s
Write-Host "ASM_SOURCES = \" -ForegroundColor Red
# Выводим пути к найденным файлам
# Инициализируем счетчик
$i = 0
# Получаем общее количество файлов
$count = $sFiles.Count
foreach ($file in $sFiles) {
    $i++  # Увеличиваем счетчик на каждой итерации
    # Получаем относительный путь к файлу
    $relativePath = $file.FullName.Substring($directoryPath.Length + 1)
    # Заменяем обратные слэши на прямые (для совместимости с Unix-стилем)
    $relativePath = $relativePath -replace "\\", "/"
    # Выводим путь с "\" или без него
    if ($i -lt $count) {
        Write-Host "$relativePath \" -ForegroundColor Red
    } else {
        Write-Host $relativePath -ForegroundColor Red
    }
}

# Находим все файлы с расширением .h в указанной директории и её поддиректориях
$hFiles = Get-ChildItem -Path $directoryPath -Recurse -Filter *.h

# Создаем хэш-таблицу для хранения уникальных путей к папкам
$folderPaths = @{}

# Проходим по всем найденным .h файлам
foreach ($file in $hFiles) {
    # Получаем полный путь к папке, в которой находится файл
    $folderPath = $file.DirectoryName
    # Получаем относительный путь к папке
    $relativeFolderPath = $folderPath.Substring($directoryPath.Length + 1)
    # Заменяем обратные слэши на прямые (для совместимости с Unix-стилем)
    $relativeFolderPath = $relativeFolderPath -replace "\\", "/"
    # Добавляем путь в хэш-таблицу (автоматически удаляет дубликаты)
    $folderPaths[$relativeFolderPath] = $true
}

Write-Host ""

# Выводим уникальные пути к папкам
Write-Host "C_INCLUDES = \" -ForegroundColor Magenta
$i = 0
foreach ($path in $folderPaths.Keys) {
    $i++  # Увеличиваем счетчик на каждой итерации
    if ($i -lt $folderPaths.Keys.Count) {
        Write-Host "$path/ \" -ForegroundColor Magenta
    } else {
        Write-Host "$path/" -ForegroundColor Magenta
    }
}

Write-Host ""

# Находим все файлы с расширением .ld в указанной директории и её поддиректориях
$ldFiles = Get-ChildItem -Path $directoryPath -Recurse -Filter *.ld

Write-Host "LDSCRIPT = \" -ForegroundColor White
# Выводим пути к найденным файлам
# Инициализируем счетчик
$i = 0
# Получаем общее количество файлов
$count = $ldFiles.Count
foreach ($file in $ldFiles) {
    $i++  # Увеличиваем счетчик на каждой итерации
    # Получаем относительный путь к файлу
    $relativePath = $file.FullName.Substring($directoryPath.Length + 1)
    # Заменяем обратные слэши на прямые (для совместимости с Unix-стилем)
    $relativePath = $relativePath -replace "\\", "/"
    # Выводим путь ld "\" или без него
    if ($i -lt $count) {
        Write-Host "$relativePath \" -ForegroundColor White
    } else {
        Write-Host $relativePath -ForegroundColor White
    }
}

#Write-Host ""
#Read-Host