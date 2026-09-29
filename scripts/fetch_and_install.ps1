param (
    [string]$TargetDir,
    [string]$Channel = "stable"
)

$ErrorActionPreference = "Stop"
$Repo = "Abled-Taha/iron_book"

# Embedded Public GPG Key
$GpgPubKey = @"
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEaotEixYJKwYBBAHaRw8BAQdAsb6OfXUDsCUVNGO2HpZMZj9NRXTMZvtGIs1Z
l8j3gtC0IEFibGVkLVRhaGEgPGFibGVkdGFoYUBnbWFpbC5jb20+iJAEExYKADgW
IQQ7EUhWFbLtuuXjIJAJlsVXaepcJwUCaotEiwIbAwULCQgHAgYVCgkICwIEFgID
AQIeAQIXgAAKCRAJlsVXaepcJ/78APoC8PG9EiLiSLC8kImz0umqZ0fkRivQs9g5
t61/EvrVowEA8efu0QK8MM6LrXkn61vT5yuZRVoErpuU6LA6+s1ggwm4OARqi0SL
EgorBgEEAZdVAQUBAQdAc4SEQjnfafFjvGKhuW4fGVbT6Q3/0d3FSoRvy0TY2hcD
AQgHiHgEGBYKACAWIQQ7EUhWFbLtuuXjIJAJlsVXaepcJwUCaotEiwIbDAAKCRAJ
lsVXaepcJ4KnAP4kiCaQoEMaZGJExpf9N8RLH6ewf1ytPvZijiqvMgVTAQEA+bCr
vOtAPzTqTIg5BP8jqXXbWI8KAn7Y0YlqCP48CA4=
=mh7+
-----END PGP PUBLIC KEY BLOCK-----
"@

# 1. Fetch Release Metadata via GitHub API
if ($Channel -eq "prerelease") {
    $ApiUrl = "https://api.github.com/repos/$Repo/releases"
    $Releases = Invoke-RestMethod `
        -Uri $ApiUrl `
        -Headers @{ "User-Agent" = "IronBook-Installer" }

    if (-not $Releases -or $Releases.Count -eq 0) {
        throw "No releases found on GitHub repository."
    }

    # GitHub returns releases newest-first.
    $TargetRelease = $Releases[0]
} else {
    $ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    $TargetRelease = Invoke-RestMethod `
        -Uri $ApiUrl `
        -Headers @{ "User-Agent" = "IronBook-Installer" }
}

# 2. Select ONLY the Windows Desktop x64 ZIP and its signature.
#
# Expected release assets:
#
#   ironbook-desktop-v0.1.0-alpha-win-x64.zip
#   ironbook-desktop-v0.1.0-alpha-win-x64.zip.asc
#
# This intentionally excludes:
#
#   ironbook-api-*-win-x64.zip
#   Linux desktop releases
#   Android releases
#   Home releases
#   Installer EXEs
#
$ZipAsset = $TargetRelease.assets |
    Where-Object {
        $_.name -like "ironbook-desktop-*-win-x64.zip"
    } |
    Select-Object -First 1

$AscAsset = $TargetRelease.assets |
    Where-Object {
        $_.name -like "ironbook-desktop-*-win-x64.zip.asc"
    } |
    Select-Object -First 1

if (-not $ZipAsset) {
    throw "Could not find the IronBook Windows Desktop x64 ZIP asset for this release."
}

if (-not $AscAsset) {
    throw "Could not find the IronBook Windows Desktop x64 ZIP signature asset for this release."
}

Write-Host "Selected Windows Desktop release:"
Write-Host "  Archive:   $($ZipAsset.name)"
Write-Host "  Signature: $($AscAsset.name)"

# 3. Setup temporary work directory
$TempFolder = Join-Path $env:TEMP "ironbook_install_$(Get-Random)"
New-Item -ItemType Directory -Path $TempFolder -Force | Out-Null

try {
    $ZipPath = Join-Path $TempFolder "ironbook.zip"
    $AscPath = Join-Path $TempFolder "ironbook.zip.asc"
    $KeyPath = Join-Path $TempFolder "pubkey.asc"

    # 4. Download release assets
    Write-Host "Downloading Windows Desktop archive..."
    Invoke-WebRequest `
        -Uri $ZipAsset.browser_download_url `
        -OutFile $ZipPath `
        -UseBasicParsing

    Write-Host "Downloading signature..."
    Invoke-WebRequest `
        -Uri $AscAsset.browser_download_url `
        -OutFile $AscPath `
        -UseBasicParsing

    [System.IO.File]::WriteAllText($KeyPath, $GpgPubKey)

    # 5. GPG Verification
    if (Get-Command "gpg" -ErrorAction SilentlyContinue) {
        $GpgHome = Join-Path $TempFolder "gnupg"
        New-Item -ItemType Directory -Path $GpgHome -Force | Out-Null

        & gpg `
            --homedir $GpgHome `
            --quiet `
            --batch `
            --import `
            $KeyPath

        & gpg `
            --homedir $GpgHome `
            --quiet `
            --batch `
            --verify `
            $AscPath `
            $ZipPath

        if ($LASTEXITCODE -ne 0) {
            throw "GPG signature verification failed!"
        }

        Write-Host "GPG signature verification successful."
    } else {
        Write-Warning "gpg command not found on Windows host. Skipping GPG verification..."
    }

    # 6. Extract binaries to target directory
    if (Test-Path $TargetDir) {
        Remove-Item -Path $TargetDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

    $ExtractTemp = Join-Path $TempFolder "extracted"

    Expand-Archive `
        -Path $ZipPath `
        -DestinationPath $ExtractTemp `
        -Force

    # Handle a single nested root directory inside the ZIP.
    $ExtractedItems = @(Get-ChildItem -Path $ExtractTemp)

    if (
        $ExtractedItems.Count -eq 1 -and
        $ExtractedItems[0].PSIsContainer
    ) {
        Move-Item `
            -Path "$($ExtractedItems[0].FullName)\*" `
            -Destination $TargetDir `
            -Force
    } else {
        Move-Item `
            -Path "$ExtractTemp\*" `
            -Destination $TargetDir `
            -Force
    }

    Write-Host "IronBook Windows Desktop installation files extracted successfully."

} finally {
    # Cleanup temporary workspace
    if (Test-Path $TempFolder) {
        Remove-Item -Path $TempFolder -Recurse -Force
    }
}
