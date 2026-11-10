<# .DOCUMENTATION This script is to check and install the Arch/Intd services and applications from a scratch stick install and after joining the STUDENTI domain

    Made by: Josh Grant
    Created on: 08/30/26
    Modified on: 11/09/26

    Architecture x64
    OS: Windows 11 26H2
    Manufactor: Dell
    Model: Precision T5820

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
    @{Name = "Nvidia App"; Loc = "\\ucsarch\apps`$\Drivers\InsNVApp.bat"; Para = "-Verbose -Edition Enterprise -Force -UseBasicParsing"; RequiresRestart = $false},
    @{Name = "Nvidia Driver"; Loc = "\\ucsarch\apps`$\Drivers\NVDriver.lnk"; Para = "-n -passive -nosplash -nofinish -noeula"; RequiresRestart = $false},
    
    #Adobe CC Latest Version Full Package
    @{Name = "Creative Cloud"; Loc = "\\ucsarch\apps`$\Adobe\Install2.cmd.lnk"; Para = "/c"; RequiresRestart = $false},
    
    # ========================================================== Autodesk Latest Version Full Package ===================================================================
    # @{Name = "Acad"; Loc = "\\ucsarch\apps`$\Autodesk\Install 2027_Everything - Silent.bat.lnk"; Para = "--offline_mode -q -o -W"; RequiresRestart = $true},
    @{Name = "Revit"; Loc = "\\ucsarch\apps`$\Autodesk\Install 2027_Everything - Silent.bat.lnk"; Para = "--offline_mode --ui_mode basic -o -W"; RequiresRestart = $true},
    
    #SketchUp Full Latest Version
    @{Name = "SketchUp"; Loc = "\\ucsarch\apps`$\Sketchup\SketchUp.lnk"; Para = "/silent,/FEATURES=fr,de,es,it,ja,scan_essentials,revit_importer"; RequiresRestart = $false},
    
    #Lumion Student Latest Version
    @{Name = "Lumion"; Loc = "\\ucsarch\apps`$\Lumion\Lumion.lnk"; Para = "--silent --silentautoexit"; RequiresRestart = $false},
    
    #Lumion Plugin for Revit Latest Version
    @{Name = "Lumion Plugin for Revit 2027"; Loc = "\\ucsarch\apps`$\Lumion\Revit_LiveSync_Plugin_Installation.bat"; Para = ""; RequiresRestart = $false}
)
$global:Pprograms = (Name = "Prusa Software" Loc = "\\ucsarch\apps$\3DPrint\Prusa\PrusaSlicer-2.9.6-setup.exe" Para = "" RequiresRestart = $false)

$global:Wprograms = @(
    @{ID = "Microsoft.Edge"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Google.Chrome"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Mozilla.Firefox"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.Onedrive"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Notepad++.Notepad++"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Zoom.Zoom"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Zoom.ZoomOutlookPlugin"; Para = "--scope machine -s winget -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Zoom.ZoomSkypeForBusinessPlugin"; Para = "--scope machine -s winget -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Zoom.ZoomRemoteControl"; Para = "--scope machine -s winget -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Zoom.ZoomRooms"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.Teams"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Google.EarthPro"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "VideoLAN.VLC"; Para = "--scope machine -s winget -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.Framework.DeveloperPack_4"; Para = "--scope machine -s winget -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.Framework.Runtime"; Para = "--scope machine -s winget -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.AspNetCore.Preview"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.AspNetCore.8"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.AspNetCore.8"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.AspNetCore.9"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.AspNetCore.9"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.AspNetCore.10"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.AspNetCore.10"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.DesktopRuntime.Preview"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.DesktopRuntime.8"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.DesktopRuntime.8"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.DesktopRuntime.9"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.DesktopRuntime.9"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.DesktopRuntime.10"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.DotNet.DesktopRuntime.10"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2010.x64"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2010.x86"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2012.x64"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2012.x86"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2013.x64"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2013.x86"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2015+.x64"; Para = "--scope machine -s winget -a x64 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "Microsoft.VCRedist.2015+.x86"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"},
    @{ID = "7zip.7zip"; Para = "--scope machine -s winget -a x86 -h --accept-package-agreements --accept-source-agreements --force --verbose --disable-interactivity"}
)

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
        Write-Host "Checking for previous installations of $($this.AppName):"
        $prog64checker = [bool](Get-ChildItem -Path $env:ProgramFiles -Filter "*$($this.AppName)*" -Recurse -Directory -ErrorAction SilentlyContinue)
        $prog86checker = [bool](Get-ChildItem -Path ${env:ProgramFiles(x86)} -Filter "*$($this.AppName)*" -Recurse -Directory -ErrorAction SilentlyContinue)
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
            if ($name -eq "Nvidia App") {
                $this.Logs("Running Nvidia App installer with elevated privileges.")
                $process = Start-Process -FilePath $loc -ArgumentList $para -Wait -PassThru -ErrorAction Stop
            }
            else {
                $this.Logs("Running installer for $name.")
                $process = Start-Process -FilePath $loc -ArgumentList $para -WorkingDirectory (Split-Path -Path $loc -Parent) -Wait -PassThru -ErrorAction Stop
            }
            # $process = Start-Process -FilePath $loc -ArgumentList $para -WorkingDirectory (Split-Path -Path $loc -Parent) -Wait -PassThru -ErrorAction Stop
            if ($process.ExitCode -eq 3010) {
                $this.Logs("$name installed successfully (exit code 3010 - restart required).")
                $this.RequiresRestart = $true
            }
            elseif ($process.ExitCode -ne 0) {
                throw "Installer exited with code $($process.ExitCode)"
            }
            else {
                $this.Logs("$name installed successfully (exit code 0).")
            }
            #$this.Los("$name installed successfully (exit code 0).")
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

class WingetInstallation {
    
    [string]$AppId
    [string]$IdArgs

    # Constructor
    WingetInstallation($AppId,$IdArgs) {
        $this.AppId = $AppId
        $this.IdArgs = $IdArgs
    }

    <#
        .DOCUMENTATION This checker method will scan the machine using the 'winget' command to search to packages installed.  It will then compare the '--id' of the package to a given list and will do
        one of three things.
            1. It will find no package installed on the machine and install it from the winget repositories.
            2. It will find the package installed and will update it to the lastest version.
            3. It will find the package installed and it will see that it is to the latest version and move onto the next package in the list.
    #>
    #Winget Checker
    [void]WingetChecker() {
        $this.Logs("App Checker started for $($this.AppId)")
        Write-Host "Checking for previous installations of $($this.AppId):"
        $wingetchecker = [bool](winget list -q "$($this.AppId)" -s winget -e | Select-String -Pattern "$($this.AppId)" -Quiet)

        if (-not $wingetchecker) {
            Write-Host "Starting winget installation for $($this.AppId):"
            $this.Logs("Winget installation for $($this.AppId) has started.")
            $this.WingetInstaller($this.AppId, $this.IdArgs)
        }
        else {
            $wingetUpdateChecker = [bool](winget list --id "$($this.AppId)" -s winget -e | Select-String '\bVersion\s+Available\b' -Quiet)
            if ($wingetUpdateChecker) {
                try {
                    winget upgrade --id "$($this.AppId)" "$($this.IdArgs)"
                }
                catch {
                    $this.Logs("ERROR: Failed to update winget application.")
                    $this.ReturnResult('InstallFailed')
                }
            }
            else {
                Write-Host "$($this.AppId) is already installed and updated."
                $this.ReturnResult('AlreadyInstalled')
            }
        }
    }

    # Winget Installer
    [void]WingetInstaller([string]$id, [string]$para) {
        $id = $this.AppId
        $para = $this.IdArgs
        $this.Logs("Winget installer started for $id ($para)") #$id for the "--id" parameter of winget
        Write-Host "Starting winget command for $id"

        try {
            winget install --id $id $para
        }
        catch {
            $this.Logs("ERROR: Instatlling $id $($_.Execption.Message)")
            throw
        }
    }

    <## Logs
    [void]Logs([string]$message) {
        $logDir = Join-Path $env:ProgramData "Logs\$($this.AppId)"
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
            'AlreadyInstalled' {"$($this.AppId) is already installed and verified."}
            'InstallSuccess' {"$($this.AppId) was installed successfully."}
            'InstallFailed' {"$($this.AppId) installation failed."}
            default {"$($this.AppId): unrecognized status '$status'."}
        }
        if ($status -eq 'InstallSuccess') {
            $this.WasFreshInstall = $true
        }
        Write-Host $message
        $this.Logs($message)
    }#>
}

class WingetInstallQueue {
    [System.Collections.Generic.List[WingetInstallation]]$Apps
    [string]$ScriptPath

    WingetInstallQueue([array]$appDefinitions, [string]$ScriptPath) {
        $this.ScriptPath = $ScriptPath
        $this.Apps = [System.Collections.Generic.List[WingetInstallation]]::new()

        foreach ($def in $appDefinitions) {
            $app = [WingetInstallation]::new($def.ID, $def.Para)
            $this.Apps.Add($app)
        }
    }

    [void]Run() {
        foreach ($app in $this.Apps)  {
            Write-Host "=== Processing $($app.AppName) ==="
            try {
                $app.WingetChecker
            }
            catch {
                Write-Host "Queue stopped - $($app.AppName) failed: $($_.Execption.Message)"
                throw
            }
        }
        Write-Host "All Winget apps installed successfully!"
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
    AppInstallQueue([array]$appDefinitions, [string]$ScriptPath) {
        $this.ScriptPath = $ScriptPath
        $this.Apps = [System.Collections.Generic.List[AppInstallation]]::new()

        foreach ($def in $appDefinitions) {
            $app = [AppInstallation]::new($def.Name, $def.Loc, $def.Para)
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
                $this.RemoveResumeTask()
                throw
            }
            if ($app.RequiresRestart -and $app.WasFreshInstall) {
                Write-Host "$($app.AppName) requires a restart before the installation queue can continue."
                $this.ScheduleRestartAndResume()
                return
            }
        }
        $this.RemoveResumeTask()
        Write-Host "All apps in the queue completed successfully!"
        pause
    }

    [void]ScheduleRestartAndResume() {
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$($this.ScriptPath)`""
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)

        Register-ScheduledTask -TaskName "ResumeAppInstallationQueue" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        Write-Host "Restart required - restarting in $($this.RestartDelaySeconds) seconds..."
        shutdown.exe /r /t $this.RestartDelaySeconds /c "Installation requires a restart to continue.  Your computer will restart automatically."
    }

    [void]RemoveResumeTask() {
        Unregister-ScheduledTask -TaskName "ResumeAppInstallationQueue" -Confirm:$false -ErrorAction SilentlyContinue
    }

}

# Does the intial check to see if computer is added to STUDENTI domain
[bool]$chkdomstat = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
if ($chkdomstat -eq $true) {
    $queue1 = [WingetInstallQueue]::new($Wprograms, $PSCommandPath)
    $queue2 = [AppInstallQueue]::new($Nprograms, $PSCommandPath)
    $queue1.Run()
    $queue2.Run()
}
else {
    Write-Host "Please join a SLCC domain first before running this script."
    throw
}

<#[string]CompName = (Get-WmiObject -Class Win32_ComputerSystem).Name
[String]$CompInt = "TB305C01"
[string]$CompInt2 = "TB305C02"
[array]CompComp = $CompInt, $CompInt2

foreach($comp in $CompComp) {
    $index = $this.compName.IndexOf($comp)
    if ($index -ge 0) {
        $queue3 = [AppInstallQueue]::new($Pprograms, $PSCommandPath)
        $queue3.Run()
    }
    else {
        $this.Logs("Computer: $CompName does not require Prusa software")
    }
}#>