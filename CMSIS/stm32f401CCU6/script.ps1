$name = $args[0]
(Get-Content .cproject) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content .cproject
(Get-Content .mxproject) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content .mxproject
(Get-Content .project) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content .project
(Get-Content Clean_project.ioc) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content Clean_project.ioc
(Get-Content STM32F401CCUX_FLASH.ld) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content STM32F401CCUX_FLASH.ld
$filename = $name + ".ioc"
Rename-Item Clean_project.ioc $filename
echo "Job is done"