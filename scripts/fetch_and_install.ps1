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
    $Releases = Invoke-RestMethod -Uri $ApiUrl -Headers @{ "User-Agent" = "IronBook-Installer" }

    if (-not $Releases -or $Releases.Count -eq 0) {
        throw "No releases found on GitHub repository."
    }
    # Grab the most recent release object (top item)
    $TargetRelease = $Releases[0]
} else {
    $ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    $TargetRelease = Invoke-RestMethod -Uri $ApiUrl -Headers @{ "User-Agent" = "IronBook-Installer" }
}

# 2. Filter Assets Specifically for Windows x64 ZIP and ASC Signature
$ZipAsset = $TargetRelease.assets | Where-Object { $_.name -like "*win-x64*.zip" -and -not ($_.name -like "*.asc") } | Select-Object -First 1
$AscAsset = $TargetRelease.assets | Where-Object { $_.name -like "*win-x64*.zip.asc" } | Select-Object -First 1

if (-not $ZipAsset) {
    throw "Could not find a valid win-x64 .zip asset for this release."
}
if (-not $AscAsset) {
    throw "Could not find a valid win-x64 .zip.asc signature asset for this release."
}

# 3. Setup Temp Work Directory
$TempFolder = Join-Path $env:TEMP "ironbook_install_$(Get-Random)"
New-Item -ItemType Directory -Path $TempFolder -Force | Out-Null

try {
    $ZipPath = Join-Path $TempFolder "ironbook.zip"
    $AscPath = Join-Path $TempFolder "ironbook.zip.asc"
    $KeyPath = Join-Path $TempFolder "pubkey.asc"

    # Download Assets
    Invoke-WebRequest -Uri $ZipAsset.browser_download_url -OutFile $ZipPath -UseBasicParsing
    Invoke-WebRequest -Uri $AscAsset.browser_download_url -OutFile $AscPath -UseBasicParsing
    [System.IO.File]::WriteAllText($KeyPath, $GpgPubKey)

    # 4. GPG Verification (if gpg command line utility exists on system)
    if (Get-Command "gpg" -ErrorAction SilentlyContinue) {
        $GpgHome = Join-Path $TempFolder "gnupg"
        New-Item -ItemType Directory -Path $GpgHome -Force | Out-Null

        & gpg --homedir $GpgHome --quiet --batch --import $KeyPath
        & gpg --homedir $GpgHome --quiet --batch --verify $AscPath $ZipPath

        if ($LASTEXITCODE -ne 0) {
            throw "GPG signature verification failed!"
        }
    } else {
        Write-Warning "gpg command not found on Windows host. Skipping GPG verification..."
    }

    # 5. Extract Binaries to Target Directory
    if (Test-Path $TargetDir) {
        Remove-Item -Path $TargetDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

    $ExtractTemp = Join-Path $TempFolder "extracted"
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractTemp -Force

    # Handle single nested root directory inside ZIP if present
    $SubDirs = Get-ChildItem -Path $ExtractTemp
    if ($SubDirs.Count -eq 1 -and $SubDirs[0].PSIsContainer) {
        Move-Item -Path "$($SubDirs[0].FullName)\*" -Destination $TargetDir -Force
    } else {
        Move-Item -Path "$ExtractTemp\*" -Destination $TargetDir -Force
    }

} finally {
    # Cleanup Work Directory
    if (Test-Path $TempFolder) {
        Remove-Item -Path $TempFolder -Recurse -Force
    }
}
