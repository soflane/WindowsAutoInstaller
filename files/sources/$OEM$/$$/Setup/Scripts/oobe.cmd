@echo off
TITLE Setting-up RunOnceEx
CLS

:RUNONCE

REG ADD HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnceEx /f
SET KEY=HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnceEx

REG ADD %KEY% /V TITLE /D "Installing applications Sofiane" /f

REG ADD %KEY%\010 /VE /D "First Round..." /f
REG ADD %KEY%\010 /V 1 /D "Powershell.exe -executionpolicy ByPass -File  %systemdrive%\setup\setup.ps1" /f
::REG ADD %KEY%\010 /V 1 /D "%systemdrive%\setup\setup.exe" /f
REG ADD %KEY%\010 /V 2 /D "TIMEOUT 5" /f
REG ADD %KEY%\010 /V 3 /D "shutdown /r /t 0" /f
REG ADD %KEY%\010 /V 4 /D "TIMEOUT 60" /f


REG ADD %KEY%\020 /VE /D "Second Round..." /f
REG ADD %KEY%\020 /V 1 /D "Powershell.exe -executionpolicy ByPass -File  %systemdrive%\setup\setup.ps1" /f
::REG ADD %KEY%\020 /V 1 /D "%systemdrive%\setup\setup.exe" /f
REG ADD %KEY%\020 /V 2 /D "TIMEOUT 5" /f
REG ADD %KEY%\020 /V 3 /D "shutdown /r /t 0" /f
REG ADD %KEY%\020 /V 4 /D "TIMEOUT 60" /f



REG ADD %KEY%\099 /VE /D "Finishing..." /f
REG ADD %KEY%\099 /V 1 /D "rmdir /s /q c:\setup" /f
REG ADD %KEY%\099 /V 2 /D "Powershell.exe -executionpolicy ByPass -command \"Remove-Item 'C:\setup' -Recurse\"" /f
REG ADD %KEY%\099 /V 3 /D "TIMEOUT 10" /f

::REG ADD %KEY%\099 /V 3 /D "shutdown /r /t 0" /f
:: https://stackoverflow.com/questions/97875/rm-rf-equivalent-for-windows

EXIT

