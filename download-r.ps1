# download-r.ps1

# Copyright (c) DevSolutions 2018. All rights reserved.

## Download and install R-3.4.3 for Windows

## Where to put the downloaded file (plus verification)
$destfolder = '.\Downloads'
function Check-Root
{
  $flag = Test-Path $destfolder
}

## Source URL plus name of installer
$rexeurl = 'https://cloud.r-project.org/bin/windows/base/R-3.4.3-win.exe'
$installer = Split-Path $rexeurl -Leaf

## Start from users home directory
cd $HOME

## Create a 'Downloads' folder if it doesn't already exist
$isRoot = Check-Root

if ($isRoot)
{
  Write-Output "'Downloads' folder already exists"
}
else
{
  Write-Output "Creating a 'Downloads' directory in "
  New-Item -ItemType d $destfolder

  $isRoot = Check-Root

  if ($isRoot)
  {
    Write-Output $destfolder " successfully created."
  }
  else
  {
    Write-Error "Could not create the destination folder"
  }
}

## Get nominal details of the installation file; check for 
## pre-existing file and download it if needed
$execPath = Join-Path -Path $destfolder -ChildPath $installer
$isExec = Test-Path -Path $execPath

if ($isExec)
{
  Write-Output "The installer already exists. Aborting download."
}
else
{
  Start-BitsTransfer -Source $rexeurl -Destination $destfolder

  if ($isExec)
  {
    Write-Output "The file has been successfully downloaded"
  }
}

## Launch the installer and continue interactively
Start-Process $execPath