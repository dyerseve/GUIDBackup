@ECHO OFF

::v0.2 First Github release
::Creates a diskpart script to list volumes, based on result jump to assign a letter or unassign (for letter script, probably not necessary here)
echo list volume > lsvol.tmp
diskpart /s lsvol.tmp > lsvolresult.tmp
for /f "tokens=3 delims= " %%a in (lsvolresult.tmp) do if /i %%a==BACKUP goto Assign
:Assign
:: Find the volume "BACKUP" and assign K to it
for /f "tokens=1,2 delims= " %%a in ('type lsvolresult.tmp ^| find /i "BACKUP"') do echo select %%a %%b > assign.tmp
echo assign letter = K >> assign.tmp
diskpart /s assign.tmp

::Locate the GUID for the drive labeled BACKUP
FOR /F "tokens=* USEBACKQ" %%F IN (`mountvol K:\ /L`) DO (
SET guid=%%F
)
set stripguid=%guid:~0,-1%
::ECHO %guid%
::ECHO %stripguid%
::Wait 10s before removing drive letter
PING 1.1.1.1 -n 1 -w 10000 >NUL
:Unassign
for /f "tokens=1,2 delims= " %%a in ('type lsvolresult.tmp ^| find /i "BACKUP"') do echo select %%a %%b > unassign.tmp
echo remove >> unassign.tmp
diskpart /s unassign.tmp
PING 1.1.1.1 -n 1 -w 10000 >NUL

:Cleanup
del /q unassign.tmp
del /q assign.tmp
del /q lsvolresult.tmp
del /q lsvol.tmp
del /q guid.tmp

:Backup
echo wbadmin start backup -backupTarget:%stripguid% -include:C: -allCritical -quiet
wbadmin start backup -backupTarget:%stripguid% -include:C: -allCritical -quiet
