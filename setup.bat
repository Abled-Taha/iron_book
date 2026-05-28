@echo off
setlocal enabledelayedexpansion

:: 1. Safely handle .env creation
if not exist .env (
    if exist .env.example (
        copy .env.example .env >nul
    ) else (
        echo ⚠️ '.env.example' not found. Skipping file copy.
    )
)

:: Prompt user for confirmation (Old school batch style)
echo Kindly verify the entries in '.env' file in the project directory.
set /p "="<nul"&pause"
echo.

echo 🪟 Running on Windows (Batch Mode)

:: 2. Check if mise is installed
where mise >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Error: 'mise' is not installed. Please install it to continue.
    exit /b 1
)

echo ✔ 'mise' is available. Proceeding...
echo 📦 Installing toolchains via mise...

:: 3. Set matching local data/cache directories using the current directory path (%CD%)
set "MISE_DATA_DIR=%CD%\.mise"
set "MISE_STATE_DIR=%CD%\.mise\state"
set "MISE_CACHE_DIR=%CD%\.mise\cache"

:: Run mise trust and install
call mise trust
if %errorlevel% neq 0 goto :failed

call mise install
if %errorlevel% neq 0 goto :failed

echo 🚀 Running project setup tasks...
call mise run setup
if %errorlevel% neq 0 goto :failed

echo 🎉 All setup complete!
exit /b 0

:failed
echo ❌ Error: Setup or toolchain installation failed.
exit /b 1
