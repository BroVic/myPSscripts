# install-r-suite.ps1
# (c) 2021-2022 Victor Ordu / DevSolutions Ltd. All rights reserved.

<#
  .SYNOPSIS
  A PowerShell script to enable the download and installation of R 4.1.3, R Studio and Rtools40.

  .DESCRIPTION
  This script will do the following:
  1. Check whether R is installed on the system already.
  2. Download R if it is absent.
  3. Install R
  4. Add R to the PATH environment variable
#>

param(
    [string]$Rversion = "4.1.3",
    [switch]$NoInstallRstudio,
    [switch]$NoInstallRtools
)

if (-not $IsWindows) {
    Write-Error "The operation is not supported on non-Windows platforms"
    exit
}

$rUrls = @{
    rbase = "https://cran.r-project.org/bin/windows/base/old/$Rversion/R-$Rversion-win.exe"
    rstudio = "https://download1.rstudio.org/desktop/windows/RStudio-2022.07.2-576.exe"
    rtools = "https://github.com/r-windows/rtools-installer/releases/download/2022-02-06/rtools40-x86_64.exe"
}

if ($NoInstallRstudio){
    $rUrls.Remove('rstudio')
}

if ($NoInstallRtools) {
    $rUrls.Remove('rtools')
}

$destdir = "$home/Downloads"

$rUrls.Keys | ForEach-Object  {
    Write-Output "Downloading '$_'"
    $link = $rUrls[$_]
    $downfile = Split-Path $link -Leaf 
    $instfile = Join-Path $destdir -ChildPath $downfile

    if ((Test-Path $instfile)) {
        Write-Output "'$_' has already been downloaded"
    } else {
        Start-BitsTransfer $link -Destination $destdir

    }

    if (-not (Test-Path $instfile)) {
        Write-Error "The file '$instfile' does not exist"
        exit
    }

    Write-Output "Follow prompts on wizard to install '$_'"
    Start-Process $instfile
}

