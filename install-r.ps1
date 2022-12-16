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
    [Parameter(Mandatory = $true)]
    [ValidatePattern("[0-9]\.[0-9]\.[0-9]")]
    [string]$Rversion = "4.2.2",

    [switch]$InstallRstudio,

    [switch]$InstallRtools
)

if (-not $Env:OS -match "^Windows") {
    throw "The operation is not supported on non-Windows platforms"
}

$rtoolsUrls = @{
    v40 = "https://github.com/r-windows/rtools-installer/releases/download/2022-02-06/rtools40-x86_64.exe"
    v42 = "https://cran.r-project.org/bin/windows/Rtools/rtools42/files/rtools42-5355-5357.exe"
}

if ($Rversion -lt "4.2") {
    $rtoolsIndex = "v40"
}
else {
    $rtoolsIndex = "v42"
}

$rtoolsVersion = $rtoolsIndex.Remove(0, 1).Insert(1, ".")

$rApps = [PSCustomObject]@{
    rbase = [PSCustomObject]@{
        Url = "https://cran.r-project.org/bin/windows/base/old/$Rversion/R-$Rversion-win.exe"
        Name = "R for Windows $Rversion"
    }
    rstudio = [PSCustomObject]@{
        Url = "https://download1.rstudio.org/electron/windows/RStudio-2022.12.0-353.exe"
        Name = "RStudio"
    }
    rtools = [PSCustomObject]@{
        Name = "Rtools $rtoolsVersion"
        Url = $rtoolsUrls[$rtoolsIndex]
    }
}

if (-not $InstallRstudio){
    $rApps.psobject.Properties.Remove('rstudio')
}

if (-not $InstallRtools) {
    $rApps.psobject.Properties.Remove('rtools')
}

$destdir = "$home/Downloads"

if (-not (Test-Path $destdir)) {
    $destdir = "$home/Desktop"
}

# Check whether previously installed
$regpath =  @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$allApps = Get-ItemProperty $regpath | `
            .{ process{ if ($_.DisplayName -and $_.UninstallString) { $_ } } } | `
            Select-Object DisplayName, UninstallString

$rApps| `
    ForEach-Object  {
        $objname = $_.psobject.Properties.Name
        $appname = $_.$objname.Name
        
        if ($allApps.DisplayName -match $appname) {
            Write-Output "'$appname' is already installed"
            continue
        }
        
        Write-Output "Downloading '$appname'"
        $link = $_.$objname.Url
        $downfile = Split-Path $link -Leaf 
        $instfile = Join-Path $destdir -ChildPath $downfile

        if ((Test-Path $instfile)) {
            Write-Output "'$appname' has already been downloaded"
        } 
        else {
            try {
                Start-BitsTransfer $link -Destination $destdir  
            }
            catch {
                Write-Error "The file '$appname' could not be downloaded"
            }
        }

        if (-not (Test-Path $instfile)) {
            throw "The file '$instfile' does not exist"
        }

        Write-Output "Follow prompts on wizard to install '$appname'"
        Start-Process $instfile
}

