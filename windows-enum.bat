:: Script       : windows-enum.bat
:: Description  : Batch script for local enumeration on Windows.
:: Author:      : @t0thkr1s
:: Version      : 1.0

@echo off

call :print_header "SYSTEM INFORMATION"

systeminfo

whoami /all

net config Workstation

call :print_header "NETWORK INFORMATION"

ipconfig /all

arp -A

route print

netstat -ano

call :print_header "NETWORK SHARES"

net share

call :print_header "FIREWALL INFORMATION"

netsh firewall show state

netsh firewall show config

call :print_header "ENVIRONMENTAL VARIABLES"

set

call :print_header "AVAILABLE DISKS"

wmic logicaldisk get caption,description,size,filesystem,systemname

call :print_header "FILES CONTAINING CREDENTIALS"

cd C:\ & findstr /SI /M "username" *.xml *.ini *.txt
cd C:\ & findstr /SI /M "password" *.xml *.ini *.txt

call :print_header "REGISTRY CONTAINING CREDENTIALS"

REG QUERY HKLM /F "username" /t REG_SZ /S /K
REG QUERY HKCU /F "username" /t REG_SZ /S /K

REG QUERY HKLM /F "password" /t REG_SZ /S /K
REG QUERY HKCU /F "password" /t REG_SZ /S /K

call :print_header "WIFI INFORMATION"

netsh wlan show profile

setlocal enabledelayedexpansion

call :network_profiles profiles

:next-profile
    for /f "tokens=1* delims=," %%a in ("%profiles%") do (
        call :profile_key "%%a" key
        if "!key!" NEQ "" (
            echo SSID: %%a Password: !key!
        )
        set profiles=%%b
    )
    if "%profiles%" NEQ "" goto next-profile
echo.

call :print_header "RUNNING PROCESSES"

tasklist /svc

net start

call :print_header "STARTUP TASKS"

wmic startup get caption,command,user

call :print_header "SCHEDULED TASKS"

schtasks /query /fo LIST 2>nul | findstr TaskName

call :print_header "STORED CREDENTIALS"

cmdkey /list

call :print_header "INSTALLED DRIVERS"

driverquery

exit /b 0

:profile_key <1=profile_name> <2=profile_key_out>
    setlocal

    set result=

    for /f "usebackq tokens=2 delims=:" %%a in (
        `netsh wlan show profile name^="%~1" key^=clear ^| findstr /C:"Key Content"`) do (
        set result=%%a
        set result=!result:~1!
    )
    (
        endlocal
        set %2=%result%
    )

    goto :eof

:network_profiles <1=result>
    setlocal

    set result=
   
    for /f "usebackq tokens=2 delims=:" %%a in (
        `netsh wlan show profiles ^| findstr /C:"All User Profile"`) do (
        set val=%%a
        set val=!val:~1!

        set result=%!val!,!result!
    )
    (
        endlocal
        set %1=%result:~0,-1%
    )

goto :eof

:print_header <1=title>
echo.
echo.
echo ==================== %~1 ====================
echo.
echo.
exit /b 0
