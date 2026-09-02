<# This script is to check and install the Arch/Intd services and applications from a scratch stick install and/or after joining STUDENTI domain

Made by: Josh Grant
Created on: 08/30/26
Modified on: 08/31/26

Architecture x64
OS: Windows 11 25H2
Manufactor: Dell
Model: Presicion T5820

#>

$global:Nprograms = @(
    @{Name = "Ninite"; Path = "\\ucsarch\apps$\Ninite"; Arguments = ""},
    @{Name = "Nvidia App"; Path = "\\ucsarch\apps$\Nvidia"; Arguments = ""},
    @{Name = "Nvidia Driver"; Path = "\\ucsarch\apps$\Nvidia"; Arguments = ""}
)
$global:Bprograms = @(
    @{$AppName = "Adobe CC"; $InstallerPath = "\\artcomm\oit$\Installers\Adobe\cc26\"; $InstallerArgs = ""},
    @{Name = "Autodesk"; Path = "\\ucsarch\apps$\Autodesk\2027\"; Arguments = ""},
    @{Name = "SketchUp 2026"; Path = "\\ucsarch\apps$\SketchUp\"; Arguments = ""},
    @{Name = "Lumion Student 2026"; Path = "\\ucsarch\apps$\Lumion\"; Arguments = ""},
    @{Name = "Lumion Plugin for Revit 2027"; Path = "\\ucsarch\apps$\Lumion\"; Arguments = ""}
)
$global:Sprograms = (Name = "Security Cert for Lumion" Path = "\\ucsarch\apps$\" Arguments = "")
$global:Pprograms = (Name = "Prusa Software" Path = "\\ucsarch\apps$\Prusa\" Arguments = "")
$global:Example = @(
    @{$AppName = "SketchUp 2026"; $InstallerPath = "%userprofile%\Downloads"; $InstallerArgs = ""}
)

class AppInstallation {

    [string]$AppName
    [string]$InstalllerPath
    [string]$InstallerArgs

    # Constructor
    AppInstallation($AppName,$InstallerPath,$InstallerArgs) {
        $this.AppName = $AppName
        $this.InstallerPath = $InstallerPath
        $this.InstallerArgs = $InstallerArgs
    }

    # Checker
    Checker() {
        $this.Logs("App Checker started for $($this.AppName)")
        $prog64checker = [bool](Get-ChildItem -Path $env:ProgramFiles -Filter "*$($this.AppName)*" -Recurse -Directory -ErrorAction SilentlyContinue)
        $prog86checker = [bool](Get-ChildItem -Path $env:ProgramFiles(x86) -Filter "*$($this.AppName)*" -Recurse -Directory -ErrorAction SilentlyContinue)
        $progdatachecker = [bool](Get-ChildItem -Path $env:ProgramData -Filter "*$($this.AppName)*" -Recurse -Directory -ErrorAction SilentlyContinue)
        $this.Logs("Results - Program Files check = $prog64checker, Program Files (x86) check = $prog86checker, Program Data check = $progdatachecker")

        if ($prog64checker -or $prog86checker) {
            $verified = $this.Verifier()
            if ($verified) {
                $this.ReturnResult('AlreadyInstalled')
            }
            else {
                $this.Logs("Matching folder found but no matching executable - treating as not installed.")
                $this.Installer($this.AppName, $this.InstallerPath, $this.InstallerArgs)
            }
        }
        elseif (-not $prog64checker -and -not $prog86checker -and -not $progdatachecker) {
            $this.Installer($this.AppName, $this.InstallerPath, $this.InstallerArgs)
        }
        else {
            $progdataPath = Join-Path $env:ProgramData $this.AppName
            Write-Host "Found existing data for $($this.AppName) in ProgramData:"
            tree.com "$prodataPath" /F
            $deleteAnswer = (Read-Host "Delete this directory? (y/n)").Trim()
            $continueAnswer = (Read-Host "Continue with install? (y/n)").Trim()

            if ($continueAnswer -notmatch '^(y|yes)$') {
                $this.Logs("User declined to continue at the ProgramData prompt. Stopping.")
                exit 1
            }

            if ($deleteAnswer -match '^(y|yes)$') {
                $this.Logs("Deleting leftover directory: $prodataPath")
                Remove-Item -Path $prodataPath -Recurse -Force -Verbose
            }
            $this.Installer($this.AppName, $this.InstallerPath, $this.InstallerArgs)
        }
    }

    # Verifier
    [bool]Verifier() {
        $exeMatch = Get-ChildItem -Path $env:ProgramFiles, ${env:ProgramFiles(x86)} -Filter "$($this.AppName)*.exe" -Recurse -File -ErrorAction SilentlyContinue
        return [bool]$exeMatch
    }

    # Installer
    [void]Installer([string]$name, [string]$loc, [string]$para) {
        $this.Logs("Installer started for $name ($loc $para)")

        try {
            $process = Start-Process -FilePath $loc -ArgumentList $para -Wait -PassThru -ErrorAction Stop
            if ($process.ExitCode -ne 0) {
                throw "Installer exited with code $($process.ExitCode)"
            }
            this.Los("$name installed successfully (exit code 0).")
            $this.ReturnResult('InstallSuccess')
        }
        catch {
            $this.Logs("ERROR installing $name : $($_.Execption.Message)")
            $this.ReturnResult('InstallFailed')
            throw
        }
    }

    # Logs
    [void]Logs([string]$message) {
        $logDir = Join-Path $env:ProgramData "Logs\$($this.AppName)"
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        $logFile = Join-Path $logDir "install.log"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp - $message" | Out-File -FilePath $logFile -Append -Encoding utf8
    }

    # Return Result
    [void]ReturnResult([string]$status) {
        $message = switch ($status) {
            'AlreadyInstalled' {"$($this.AppName) is already installed and verified."}
            'InstallSuccess' {"$($this.AppName) was installed successfully."}
            'InstallFailed' {"$($this.AppName) installation failed."}
            default {"$($this.AppName): unrecognized status '$status'."}
        }
        Write-Host $message
        $this.Logs($message)
    }

    <#function mainmethod{
        $chkdomstat

    }
    function  chkdomstat{
        [boolean]$domainstatus = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
        if ($domainstatus -eq 'true') {call joindomain}
        else {call installapps}
    }
    function joindomain{
        Write-Host "You successfully went to the joindomain method"
    }
    function installapps{
        write-Host "You successfully went to the installapps method"
    }#>
}

# Does the intial check to see if computer is added to STUDENTI domain
$chkdomstat = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
if ($chkdomstat -eq "true") {Write-Host "Went to join domain"}
else {Write-Host "Went to install apps"}


