$name = $args[0]
(Get-Content .cproject) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content .cproject
(Get-Content .mxproject) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content .mxproject
(Get-Content .project) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content .project
(Get-Content Clean_project.ioc) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content Clean_project.ioc
(Get-Content STM32F407VGTX_FLASH.ld) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content STM32F407VGTX_FLASH.ld
(Get-Content STM32F407VGTX_RAM.ld) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content STM32F407VGTX_RAM.ld
(Get-Content Makefile) | ForEach-Object { $_ -replace "Clean_project", $name } | Set-Content Makefile
$filename = $name + ".ioc"
Rename-Item Clean_project.ioc $filename
echo "Job is done"