@echo off
setlocal enabledelayedexpansion

REM Simple Log Server Docker Run Script for Windows

set IMAGE_NAME=simple-log-server
set CONTAINER_NAME=simple-log-server
set PORT=3333

echo Simple Log Server Docker Runner
echo ==================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker is not running. Please start Docker first.
    pause
    exit /b 1
)

REM Handle command line arguments
if "%1"=="build" goto build_image
if "%1"=="run" goto run_with_logs
if "%1"=="basic" goto run_basic
if "%1"=="interactive" goto run_interactive
if "%1"=="stop" goto stop_container
if "%1"=="logs" goto view_logs
if "%1"=="status" goto show_status

REM Interactive mode
:menu
echo.
echo Choose an option:
echo 1) Build image
echo 2) Run (basic)
echo 3) Run with persistent logs
echo 4) Run interactive
echo 5) Stop container
echo 6) View logs
echo 7) Show status
echo 8) Exit
echo.
set /p choice="Enter your choice [1-8]: "

if "%choice%"=="1" goto build_image
if "%choice%"=="2" goto run_basic_menu
if "%choice%"=="3" goto run_with_logs_menu
if "%choice%"=="4" goto run_interactive_menu
if "%choice%"=="5" goto stop_container_menu
if "%choice%"=="6" goto view_logs_menu
if "%choice%"=="7" goto show_status_menu
if "%choice%"=="8" goto exit_script

echo Invalid option. Please choose 1-8.
goto menu

:build_image
echo Building Docker image...
docker build -t %IMAGE_NAME% .
if errorlevel 1 (
    echo Failed to build image
    pause
    exit /b 1
) else (
    echo Image built successfully!
)
if "%1"=="build" exit /b 0
goto menu

:run_basic
echo Starting container (basic mode)...
call :stop_container_silent
docker run -d --name %CONTAINER_NAME% -p %PORT%:3333 %IMAGE_NAME%
if errorlevel 1 (
    echo Failed to start container
) else (
    echo Container started successfully!
    echo Server available at: http://localhost:%PORT%
)
if "%1"=="basic" exit /b 0
goto menu

:run_basic_menu
call :run_basic
goto menu

:run_with_logs
echo Starting container with persistent logs...
if not exist logs mkdir logs
call :stop_container_silent
docker run -d --name %CONTAINER_NAME% -p %PORT%:3333 -v "%cd%/logs:/app/logs" %IMAGE_NAME%
if errorlevel 1 (
    echo Failed to start container
) else (
    echo Container started with persistent logs!
    echo Server available at: http://localhost:%PORT%
    echo Logs will be saved to: ./logs
)
if "%1"=="run" exit /b 0
goto menu

:run_with_logs_menu
call :run_with_logs
goto menu

:run_interactive
echo Starting container in interactive mode...
call :stop_container_silent
docker run -it --name %CONTAINER_NAME% -p %PORT%:3333 -v "%cd%/logs:/app/logs" %IMAGE_NAME%
if "%1"=="interactive" exit /b 0
goto menu

:run_interactive_menu
call :run_interactive
goto menu

:stop_container
echo Stopping and removing container...
docker stop %CONTAINER_NAME% >nul 2>&1
docker rm %CONTAINER_NAME% >nul 2>&1
echo Container stopped and removed
if "%1"=="stop" exit /b 0
goto menu

:stop_container_menu
call :stop_container
goto menu

:stop_container_silent
docker stop %CONTAINER_NAME% >nul 2>&1
docker rm %CONTAINER_NAME% >nul 2>&1
goto :eof

:view_logs
echo Container logs:
docker logs %CONTAINER_NAME%
if "%1"=="logs" exit /b 0
goto menu

:view_logs_menu
call :view_logs
pause
goto menu

:show_status
echo Container status:
docker ps -a --filter "name=%CONTAINER_NAME%"
if "%1"=="status" exit /b 0
goto menu

:show_status_menu
call :show_status
pause
goto menu

:exit_script
echo Goodbye!
exit /b 0
