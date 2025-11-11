#   Определитель операционной системы и имени пользователя v1.0
#   Автор: Волков Олег
#   Дата создания скрипта: 28.10.2025
#   ВАЖНО: Работает под PowerShell (Core, 7+)
#   Для установки в Windows откройте powershell и введите: winget install Microsoft.Powershell 
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749
#   Определитель операционной системы и имени пользователя v1.0
#   Автор: Волков Олег
#   Дата создания скрипта: 28.10.2025
#   ВАЖНО: Работает под PowerShell (Core, 7+)
#   Для установки в Windows откройте powershell и введите: winget install Microsoft.Powershell 
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

# Определяем ОС
if ($IsWindows) {
    $os = "Windows"
    $username = $env:USERNAME
    $os_is_linux = 0
} elseif ($IsLinux) {
    $os = "Linux"
    $username = $env:USER
    $os_is_linux = 1
} elseif ($IsMacOS) {
    $os = "macOS"
    $username = $env:USER
    $os_is_linux = 0
} else {
    $os = "Unknown"
    $username = [System.Environment]::UserName
    $os_is_linux = 0
}

Write-Host "Определяю данные о системе:" -ForegroundColor Yellow
Write-Host "Операционная система: $os"
Write-Host "Имя пользователя: $username"
Write-Host "Полное имя пользователя: $([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
Write-Host "OS_IS_LINUX будет установлен в: $os_is_linux" -ForegroundColor Green


Write-Host "Записываю данные в Makefile:" -ForegroundColor Yellow

# Определяем абсолютный путь к Makefile относительно расположения скрипта
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$MakefilePath = Join-Path $WorkspaceRoot "Makefile"

# Для отладки 
#Write-Host "Директория скрипта: $ScriptDir"
#Write-Host "Корень проекта: $WorkspaceRoot"
#Write-Host "Полный путь к Makefile: $MakefilePath"

if (-not (Test-Path $MakefilePath)) {
    Write-Error "Makefile не найден по пути: $MakefilePath" 
    exit 1
}

# Создаем резервную копию
$backupPath = "$MakefilePath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $MakefilePath $backupPath
Write-Host "Создана резервная копия: $backupPath" -ForegroundColor Green

# Читаем файл построчно для более точной замены
$lines = Get-Content $MakefilePath

for ($i = 0; $i -lt $lines.Length; $i++) {
    # Заменяем только строки, которые начинаются с OS_IS_LINUX (игнорируем комментарии)
    if ($lines[$i] -match '^OS_IS_LINUX\s*=') {
        $lines[$i] = "OS_IS_LINUX = $os_is_linux"
    }
    # Заменяем только строки, которые начинаются с USER_FOLDER_NAME (игнорируем комментарии)
    elseif ($lines[$i] -match '^USER_FOLDER_NAME\s*=') {
        $lines[$i] = "USER_FOLDER_NAME = $username"
    }
}

# Записываем обратно
$lines | Set-Content $MakefilePath -Encoding UTF8
Write-Host "Makefile успешно обновлен!" -ForegroundColor Green
Write-Host "OS_IS_LINUX = $os_is_linux" -ForegroundColor Green
Write-Host "USER_FOLDER_NAME = $username" -ForegroundColor Green