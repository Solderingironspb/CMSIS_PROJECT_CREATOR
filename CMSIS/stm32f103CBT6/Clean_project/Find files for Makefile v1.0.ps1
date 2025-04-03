Write-Host "Find files for Makefile v1.0" -ForegroundColor White
Write-Host "Autor: Volkov Oleg" -ForegroundColor White
Write-Host ""

## Укажите путь к директории, в которой нужно искать файлы
$directoryPath = $PSScriptRoot

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