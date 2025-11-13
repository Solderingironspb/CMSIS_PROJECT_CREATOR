#   clangd_update v1.1
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
# Функция для обновления существующего файла
function Update-ClangdFile {
    param([string[]]$Content)
    
    $inCompileFlags = $false
    $inAddSection = $false
    $inRemoveSection = $false
    $otherSections = @()
    $otherFlags = @()
    $removeFlags = @()
    $compileFlagsContent = @()
    
    # Собираем все секции
    for ($i = 0; $i -lt $Content.Length; $i++) {
        $line = $Content[$i]
        $trimmedLine = $line.Trim()
        
        if ($trimmedLine -eq "CompileFlags:") {
            $inCompileFlags = $true
            $compileFlagsContent += $line
            continue
        }
        
        if ($inCompileFlags) {
            if ($trimmedLine -eq "Add:") {
                $inAddSection = $true
                $inRemoveSection = $false
                $compileFlagsContent += $line
                continue
            }
            
            if ($trimmedLine -eq "Remove:") {
                $inAddSection = $false
                $inRemoveSection = $true
                $compileFlagsContent += $line
                continue
            }
            
            if ($inAddSection) {
                if ($trimmedLine.StartsWith("- -isystem")) {
                    # Пропускаем старые -isystem флаги
                    $i++ # Пропускаем следующую строку пути
                    continue
                } elseif ($trimmedLine.StartsWith("-")) {
                    # Сохраняем другие флаги
                    $otherFlags += $line
                } else {
                    $compileFlagsContent += $line
                }
            } elseif ($inRemoveSection) {
                if ($trimmedLine.StartsWith("-")) {
                    # Сохраняем флаги Remove
                    $removeFlags += $line
                } else {
                    $compileFlagsContent += $line
                }
            } else {
                $compileFlagsContent += $line
            }
            
            # Проверяем конец секции CompileFlags
            if (-not $line.StartsWith(" ") -and -not $line.StartsWith("  ") -and $trimmedLine -ne "" -and $trimmedLine -ne "CompileFlags:" -and $trimmedLine -ne "Add:" -and $trimmedLine -ne "Remove:") {
                $inCompileFlags = $false
                $inAddSection = $false
                $inRemoveSection = $false
                $otherSections += $line
            }
        } else {
            # Сохраняем все остальные секции
            $otherSections += $line
        }
    }
    
    # Собираем финальный вывод
    $finalOutput = @()
    
    # Добавляем обновленную секцию CompileFlags
    $finalOutput += "CompileFlags:"
    $finalOutput += "  Compiler: $CompilerPath"
    $finalOutput += "  Add:"
    $finalOutput += "    - -isystem"
    $finalOutput += "    - $IncludePath1"
    $finalOutput += "    - -isystem" 
    $finalOutput += "    - $IncludePath2"
    
    # Добавляем остальные флаги Add
    foreach ($flag in $otherFlags) {
        $finalOutput += $flag
    }
    
    # Добавляем секцию Remove если она была
    if ($removeFlags.Count -gt 0) {
        $finalOutput += "  Remove:"
        foreach ($flag in $removeFlags) {
            $finalOutput += $flag
        }
    }
    
    # Добавляем пустую строку перед другими секциями
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