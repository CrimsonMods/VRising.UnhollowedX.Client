@echo off
setlocal enabledelayedexpansion

echo Starting interop files sync script...
echo.

set "DEFAULT_INTEROP_PATH=C:\Program Files (x86)\Steam\steamapps\common\VRising\VRising_Server\BepInEx\interop"
set "LIB_PATH=%~dp0lib/net6.0"

echo Default interop path: "%DEFAULT_INTEROP_PATH%"
echo Lib path: "%LIB_PATH%"
echo.

if not exist "%LIB_PATH%" (
    echo Creating lib directory...
    mkdir "%LIB_PATH%" 2>nul
    if errorlevel 1 (
        echo Failed to create lib directory! Please check permissions.
        goto :end
    )
    echo Created lib directory at "%LIB_PATH%"
)

if exist "%DEFAULT_INTEROP_PATH%" (
    echo Default interop path found.
    set "INTEROP_PATH=%DEFAULT_INTEROP_PATH%"
) else (
    echo Default interop path not found: "%DEFAULT_INTEROP_PATH%"
    echo Please provide the path to the interop folder:
    set /p INTEROP_PATH=
    
    if not exist "!INTEROP_PATH!" (
        echo The provided path does not exist.
        goto :end
    )
)

echo.
echo Using interop path: "%INTEROP_PATH%"
echo.

set "DIFFERENT=0"
if exist "%INTEROP_PATH%\*" (
    echo Checking for differences in files...
    
    for %%F in ("%INTEROP_PATH%\*") do (
        set "FILENAME=%%~nxF"
        if exist "%LIB_PATH%\!FILENAME!" (
            fc /b "%%F" "%LIB_PATH%\!FILENAME!" >nul 2>&1
            if errorlevel 1 (
                set "DIFFERENT=1"
                echo Found difference: !FILENAME! - Different content
                goto :differences_found
            )
        ) else (
            set "DIFFERENT=1"
            echo Found difference: !FILENAME! - New file
            goto :differences_found
        )
    )
    
    echo Check completed. No differences found.
    goto :no_differences
) else (
    echo No files found in "%INTEROP_PATH%"
    goto :end
)

:differences_found
echo.
echo Differences found! Updating lib folder...

echo Emptying lib folder...
del /q "%LIB_PATH%\*" 2>nul

echo Copying new files...
xcopy /y "%INTEROP_PATH%\*" "%LIB_PATH%\" >nul 2>&1
if errorlevel 1 (
    echo Error copying files! Please check permissions and paths.
    goto :end
)

echo.
echo Update complete! Files have been copied to "%LIB_PATH%"
goto :end

:no_differences
echo.
echo No differences found. Lib folder is up to date.

:end
echo.
echo Script completed. Press any key to exit...
pause >nul
