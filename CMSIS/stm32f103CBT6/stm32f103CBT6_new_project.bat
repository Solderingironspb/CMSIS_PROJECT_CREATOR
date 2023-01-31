@echo off
echo STM32F103CBT6: new project for CMSIS
cd C:\CMSIS\stm32f103CBT6
set /p name="Enter project name:"
md %name%
xcopy /y /o /e /d "Clean_project" %name%
cd %name%
Powershell.exe -executionpolicy remotesigned -File "C:\CMSIS\stm32f103CBT6\script.ps1" %name%
explorer.exe C:\CMSIS\stm32f103CBT6