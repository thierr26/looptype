@echo off

rem Copyright (C) 2016 Thierry Rascle <thierr26@free.fr>
rem MIT license. Please refer to the LICENSE file.

setlocal enabledelayedexpansion

set exit_status=0

set default_period=3

set filename=%~nx0
set filename_no_ext=%filename:~0,-4%

if "%~1"=="/?" (
    call:doc %filename_no_ext%
) else (
    if "%~1"=="/t" (
        if "%~2"=="" (
            call:error %filename_no_ext% "Missing period argument"
            set exit_status=1
        ) else (
            if "%~2"=="0" (
                call:error %filename_no_ext% "Period 0 is not allowed"
                set exit_status=1
            ) else (
                echo %2|findstr "^[0-9][0-9]*$">nul
                if errorlevel 1 (
                    call:error %filename_no_ext% "Invalid period argument"
                    set exit_status=1
                ) else (
                    set period=%2
                    if "%~3"=="" (
                        call:missing_file_arg_error
                        set exit_status=1
                    )
                    set first_file_name_arg=3
                )
            )
        )
    ) else (
        set period=%default_period%
        if "%~1"=="" (
            call:missing_file_arg_error
            set exit_status=1
        )
        set first_file_name_arg=1
    )

    if !exit_status!==0 (

        set arg_count=0
        for %%x in (%*) do (
           set /A arg_count+=1
           set "arg[!arg_count!]=%%~x"
        )

        rem Enter an infinite loop.
        :loop
            for /l %%k in (1,1,!arg_count!) do (
                if %%k geq !first_file_name_arg! (
                    type "!arg[%%k]!"
                )
            )
            timeout /t !period! >nul
        goto loop
    )
)

rem Exit the main program.
exit /b %exit_status%

:doc
    set p=%default_period%
    echo Usage
    echo.
    echo     %~1 [/t seconds] file1 [file2 ...]
    echo.
    echo     %~1 /?
    echo.
    echo Description
    echo.
    echo     Print to the command line each file provided as argument every %p%
    echo     seconds.  Another period can be specified in seconds using the /t
    echo     option.  Use Ctrl-C to stop.
    echo.
    echo     When invoked with "/?" as first argument, print the present
    echo     documentation to the command line.
goto:eof

:error
    echo %~1: %~2 1>&2
    echo Type %~1 /? for help 1>&2
goto:eof

:missing_file_arg_error
    call:error %filename_no_ext% "Missing file name argument"
goto:eof
