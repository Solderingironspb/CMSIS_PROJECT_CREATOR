#   clangd_update v1.0
#   Автор: Волков Олег
#   Дата создания скрипта: 25.10.2025
#   ВАЖНО: Работает под PowerShell (Core, 7+)
#   Для установки в Windows откройте powershell и введите: winget install Microsoft.Powershell 
#   Для установки в Linux откройте konsole (на примере Debian 13) и введите: sudo snap install powershell --classic
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

param(
    [string]$CompilerPath,
    [string]$IncludePath1,
    [string]$IncludePath2
)

# Проверяем аргументы
if (-not $CompilerPath -or -not $IncludePath1 -or -not $IncludePath2) {
    Write-Error "Необходимо указать все три аргумента: CompilerPath, IncludePath1, IncludePath2"
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Join-Path $ScriptDir "../.."
$ClangdPath = Join-Path $ProjectRoot ".clangd"

Write-Host "Директория скрипта: $ScriptDir"
Write-Host "Корень проекта: $ProjectRoot"
Write-Host "Путь к .clangd: $ClangdPath"

# Функция для создания нового файла .clangd
function New-ClangdFile {
    @"
CompileFlags:
  Compiler: $CompilerPath
  Add: 
    - -isystem
    - $IncludePath1
    - -isystem
    - $IncludePath2
    
Diagnostics:
  UnusedIncludes: None
  Suppress:
    - pp_including_mainfile_in_preamble
    - unused-includes
"@
}

# Функция для обновления существующего файла
function Update-ClangdFile {
    param([string[]]$Content)
    
    $inCompileFlags = $false
    $inAddSection = $false
    $otherSections = @()
    $otherFlags = @()
    
    # Собираем все флаги кроме -isystem из секции Add
    for ($i = 0; $i -lt $Content.Length; $i++) {
        $line = $Content[$i]
        $trimmedLine = $line.Trim()
        
        if ($trimmedLine -eq "CompileFlags:") {
            $inCompileFlags = $true
            continue
        }
        
        if ($inCompileFlags -and $trimmedLine -eq "Add:") {
            $inAddSection = $true
            continue
        }
        
        if ($inAddSection) {
            if ($trimmedLine.StartsWith("- -isystem")) {
                # Пропускаем строку -isystem и следующую за ней (путь)
                $i++ # Пропускаем следующую строку пути
                continue
            } elseif ($trimmedLine.StartsWith("-")) {
                # Сохраняем другие флаги
                $otherFlags += $line
            } elseif (-not $trimmedLine.StartsWith("-") -and $trimmedLine -ne "" -and -not $line.StartsWith(" ")) {
                # Конец секции Add и CompileFlags
                $inAddSection = $false
                $inCompileFlags = $false
                $otherSections += $line
            }
        } elseif ($inCompileFlags -and -not $inAddSection) {
            # Пропускаем другие строки в CompileFlags (например старый Compiler)
            continue
        } else {
            # Сохраняем все остальные секции
            $otherSections += $line
        }
    }
    
    # Собираем финальный вывод
    $finalOutput = @()
    
    # Добавляем обновленную секцию CompileFlags в начало
    $finalOutput += "CompileFlags:"
    $finalOutput += "  Compiler: $CompilerPath"
    $finalOutput += "  Add:"
    $finalOutput += "    - -isystem"
    $finalOutput += "    - $IncludePath1"
    $finalOutput += "    - -isystem" 
    $finalOutput += "    - $IncludePath2"
    
    # Добавляем остальные флаги
    foreach ($flag in $otherFlags) {
        $finalOutput += $flag
    }
    
    $finalOutput += ""
    
    # Добавляем все остальные секции
    foreach ($sectionLine in $otherSections) {
        $finalOutput += $sectionLine
    }
    
    return $finalOutput
}

# Основная логика
try {
    if (Test-Path $ClangdPath) {
        Write-Host "`n Обновляю существующий .clangd файл..."
        $content = Get-Content $ClangdPath
        $newContent = Update-ClangdFile -Content $content
        $newContent | Out-File $ClangdPath -Encoding UTF8
        Write-Host "`n Файл .clangd успешно обновлен!"
    } else {
        Write-Host "`n Создаю новый .clangd файл..."
        $newContent = New-ClangdFile
        $newContent | Out-File $ClangdPath -Encoding UTF8
        Write-Host "`n Файл .clangd успешно создан!"
    }
    
    # Показываем содержимое файла
    Write-Host "`n Содержимое файла .clangd: `n"
    Get-Content $ClangdPath | ForEach-Object { Write-Host "  $_" }
}
catch {
    Write-Error "Ошибка обработки файла: $($_.Exception.Message)"
    exit 1
}