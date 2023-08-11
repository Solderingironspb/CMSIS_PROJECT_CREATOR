@echo off
echo STM32F103C8T6_FreeRTOS: new project for CMSIS	
cd C:\CMSIS\stm32f103C8T6_FreeRTOS
set /p name="Enter project name:"
md %name%
xcopy /y /o /e /d "Clean_project" %name%
cd %name%
Powershell.exe -executionpolicy remotesigned -File "C:\CMSIS\stm32f103C8T6\script.ps1" %name%
explorer.exe C:\CMSIS\stm32f103C8T6_FreeRTOS