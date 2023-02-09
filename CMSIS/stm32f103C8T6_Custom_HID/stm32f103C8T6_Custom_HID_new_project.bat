@echo off
echo STM32F103C8T6_Custom_HID: new project for CMSIS/HAL	
cd C:\CMSIS\stm32f103C8T6_Custom_HID
set /p name="Enter project name:"
md %name%
xcopy /y /o /e /d "Clean_project" %name%
cd %name%
Powershell.exe -executionpolicy remotesigned -File "C:\CMSIS\stm32f103C8T6_Custom_HID\script.ps1" %name%
explorer.exe C:\CMSIS\stm32f103C8T6_Custom_HID