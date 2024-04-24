@echo off
echo STM32F401CEU6: new project for CMSIS
cd C:\CMSIS\stm32f401CEU6
set /p name="Enter project name:"
md %name%
xcopy /y /o /e /d "Clean_project" %name%
cd %name%
Powershell.exe -executionpolicy remotesigned -File "C:\CMSIS\stm32f401CEU6\script.ps1" %name%
explorer.exe C:\CMSIS\stm32f401CEU6