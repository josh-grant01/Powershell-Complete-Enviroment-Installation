<# This script is to check and install the Arch/Intd services and applications from a scratch stick install and/or after joining STUDENTI domain

Made by: Josh Grant
Created on: 08/30/26
Modified on: 08/31/26

Architecture x64
OS: Windows 11 25H2
Manufactor: Dell
Model: Presicion T5820

#>

# --- Start self-elevation check ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}
# --- End self-elevation block ---

$global:Nprograms = @(
    @{Name = "Ninite"; Loc = "\\ucsarch\apps`$\NINITE\Labs042026\Ninite 7Zip ASPNET Core Runtime 10 Installer.exe"; Para = "/silent C:\Logs\Ninite\Install.txt"; RequiresRestart = $false},
    @{Name = "Nvidia App"; Loc = "\\ucsarch\apps`$\Drivers\NVIDIA_app_v11.0.6.383.exe"; Para = "/s"; RequiresRestart = $true},
    @{Name = "Nvidia Driver"; Loc = "\\ucsarch\apps`$\Drivers\Nvidia_Stable_570_Channel\573.96-quadro-rtx-desktop-notebook-win10-win11-64bit-international-dch-whql.exe"; Para = "/s"; RequiresRestart = $true}
)
$global:Bprograms = @(
    #Adobe CC 2026 Full Package
    @{$AppName = "Adobe"; $InstallerPath = "\\artcomm\oit`$\Installers\Adobe\cc26\20260205-CC2026-SDL\Install2.cmd"; $InstallerArgs = "/c"},
    
    #Autodesk 2027 Full Package
    @{$AppName = "Autodesk"; $InstallerPath = "\\ucsarch\apps$\Autodesk\2027\"; $InstallerArgs = ""},
    
    #SketchUp Full 2026
    @{$AppName = "SketchUp 2026"; $InstallerPath = "\\ucsrch\apps`$\Sketchup\*SketchUp*"; $InstallerArgs = "/silent,/FEATURES=fr,de,es,it,ja,scan_essentials,revit_importer"}
    
    #Lumion Student 2026
    @{$AppName = "Lumion Student 2026"; $InstallerPath = "\\ucsarch\apps`$\Lumion\Lumion_2025_0_2_Student_Download.exe"; $InstallerArgs = "--silent --silentautoexit"},
    
    #Lumion Plugin for Revit 2027
    @{$AppName = "Lumion Plugin for Revit 2027"; $InstallerPath = "\\ucsarch\apps`$\Lumion\Revit_LiveSync_Plugin_Installation.bat"; $InstallerArgs = ""}
)
#$global:Sprograms = ($AppName = "Security Cert for Lumion" $InstallerPath = "\\ucsarch\apps$\" $InstallerArgs = "")
$global:Pprograms = ($AppName = "Prusa Software" $InstallerPath = "\\ucsarch\apps$\Prusa\" $InstallerArgs = "")
<#$global:Example = @(
    @{$AppName = "SketchUp 2026"; $InstallerPath = "\\ucsrch\apps`$\Sketchup\*SketchUp*"; $InstallerArgs = "/silent,/FEATURES=fr,de,es,it,ja,scan_essentials,revit_importer"}
)#>

class AppInstallation {

    [string]$AppName
    [string]$InstallerPath
    [string]$InstallerArgs
    [bool]$RequiresRestart = $false
    [bool]$WasFreshInstall = $false

    # Constructor
    AppInstallation($AppName,$InstallerPath,$InstallerArgs) {
        $this.AppName = $AppName
        $this.InstallerPath = $InstallerPath
        $this.InstallerArgs = $InstallerArgs
    }

    # Checker
    [void]Checker() {
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
        if ($status -eq 'InstallSuccess') {
            $this.WasFreshInstall = $true
        }
        Write-Host $message
        $this.Logs($message)
    }
}

<#
    .DOCUMENTATION AppInstallQueue relies on prior declaration of AppInstallation class.
#>
class AppInstallQueue {
    [System.Collections.Generic.List[AppInstallation]]$Apps
    [string]$ScriptPath

    # 300 = 5 minutes.
    [int]$RestartDelaySeconds = 20
    [string]$AutoLogonUser
    [string]$AutoLogonPassword
    [string]$AutoLogonDomain
    
    AppInstallQueue([arrary]$appDefinitions, [string]$ScriptPath) {
        $this.ScriptPath = $ScriptPath
        $this.Apps = [System.Collecctions.Generic.List[AppInstallation]]::new()

        foreach ($def in $appDefinitions) {
            $app = [AppInstallaiton]::new($def.Name, $def.Loc, $def.Para)
            if ($def.ContainsKey('RequiresRestart')) {
                $app.RequiresRestart = [bool]$def.RequiresRestart
            }
            $this.Apps.Add($app)
        }
    }

    [void]Run() {
        foreach ($app in $this.Apps) {
            Write-Host "=== Processing $($app.AppName) ==="
            try {
                $app.Checker()
            }
            catch {
                Write-Host "Queue stopped - $($app.AppName) failed: $($_.Execption.Message)"
                throw
            }
            if ($app.RequiresRestart -and $app.WasFreshInstall) {
                Write-Host "$($app.AppName) requires a restart before the installation queue can continue."
                $this.ScheduleRestartAndResume()
                return
            }
        }
        this.DisableAutoLogon()
        Write-Host "All apps in the queue completed successfully."
    }

    [void]ScheduleRestartAndResume() {
        $this.EnableAutoLogon()
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" `
            -Name "ResumeAppInstallQueue" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$($this.ScriptPath)`"" `
            -PropertyType String -Force | Out-Null
        Write-Host "Restart required - restarting in $($this.RestartDelaySeconds) seconds..."
        shutdown.exe /r /t $this.RestartDelaySeconds /c "Installation requires a restart to continue.  Your computer will restart automatically."
    }

    # Turns on unattended auto-login for the deployment account.  Called only
    # when a restart is about to happen.
    [void]EnableAutoLogon() {
        $WinLogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Net-ItemProperty -Path $WinLogonPath -Name "AutoAdminLogon" -Value "1" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $WinLogonPath -Name "DefaultUserName" -Value $this.AutoLogonUser -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $WinLogonPath -Name "DefaultPassword" -Value $this.AutoLogonPassword -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $WinLogonPath -Name "DefaultDomainName" -Value $this.AutoLogonDomain -PropertyType String -Force | Out-Null
    }

    # Turns auto-login back off and clears the stored password immediately
    [void]DisableAutoLogon() {
        $WinLogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        New-ItemProperty -Path $WinLogonPath -Name "AutoAdminLogon" -Value "0" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $WinLogonPath -Name "DefaultPassword" -Value "" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $WinLogonPath -Name "DefaultDomainName" -Value "" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $WinLogonPath -Name "DefaultUserName" -Value "" -PropertyType String -Force | Out-Null
    }

}

$queue = [AppInstallQueue]::new($Nprograms, $PSCommandPath)

# Deployment account
$queue.AutoLogonUser = ""
$queue.AutoLogonPassword = ""
$queue.AutoLogonDomain = "SLCCI"


# Does the intial check to see if computer is added to STUDENTI domain
[bool]$chkdomstat = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
if ($chkdomstat -eq $true) {}
else {}


