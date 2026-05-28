# Avoid continuing if a crucial step fails (similar to 'set -e' or '|| exit 1')
$ErrorActionPreference = "Stop"

function Get-WindowsArchitecture {
    # Simple check to confirm host environment context if needed
    return "windows"
}

function Test-CommandExists {
    param (
        [string]$Command
    )
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# 1. Safely handle the .env creation so it doesn't overwrite an existing file
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
    } else {
        Write-Warning "⚠️ '.env.example' not found. Skipping file copy."
    }
}

# Prompt user for confirmation safely across PowerShell hosts
Write-Host "Kindly verify the entries in '.env' file in the project directory, then press any key to continue..." -NoNewline
$null = [Console]::ReadKey($true)
Write-Host ""

# Distro/OS evaluation path
Write-Host "🪟 Running on Windows"

if (Test-CommandExists "mise") {
    Write-Host "✔ 'mise' is available. Proceeding..."
} else {
    Write-Error "❌ Error: 'mise' is not installed. Please install it to continue."
    Exit 1
}

Write-Host "📦 Installing toolchains via mise..."
try {
    # Run mise trust and install sequential commands
    & mise trust
    & mise install
} catch {
    Write-Error "❌ Error: 'mise install' failed."
    Exit 1
}

Write-Host "🚀 Running project setup tasks..."
try {
    & mise run setup
} catch {
    Write-Error "❌ Error: Project setup task failed."
    Exit 1
}

Write-Host "🎉 All setup complete!"
Exit 0
