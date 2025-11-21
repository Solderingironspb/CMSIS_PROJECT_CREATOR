#!/bin/bash

# Проверим, запущен ли скрипт от sudo
if [ "$EUID" -ne 0 ]; then
    echo "Running script as sudo..."
    sudo "$0"
    exit $?
fi

# Выведем надпись, под какой мк мы будем вести работу
echo "STM32F103C6T6: new project for CMSIS"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "$SCRIPT_DIR"

read -p "Enter project name: " name

mkdir -p "$name"
# Копируем скрытые файлы и папки
cp -r "Clean_project"/.* "$name/" 2>/dev/null 2>&1 || true
cp -r "Clean_project"/* "$name/" 2>/dev/null 2>&1 || true
cd "$name"

# Запуск PowerShell скрипта через pwsh с полным путем
if [ -f "$SCRIPT_DIR/script.ps1" ]; then
    # Пробуем разные возможные пути к pwsh
    if [ -f "/snap/bin/pwsh" ]; then
        /snap/bin/pwsh -ExecutionPolicy Bypass -File "$SCRIPT_DIR/script.ps1" "$name" 2>&1
    elif [ -f "/usr/bin/pwsh" ]; then
        /usr/bin/pwsh -ExecutionPolicy Bypass -File "$SCRIPT_DIR/script.ps1" "$name" 2>&1
    elif [ -f "/opt/microsoft/powershell/7/pwsh" ]; then
        /opt/microsoft/powershell/7/pwsh -ExecutionPolicy Bypass -File "$SCRIPT_DIR/script.ps1" "$name" 2>&1
    else
        echo "ERROR: pwsh not found in any standard location"
        echo "Please install PowerShell or use Bash version script"
    fi
fi

#Дадим созданному проекту полный полный доступ к операциям
chmod -R 777 "$SCRIPT_DIR"/"$name"

