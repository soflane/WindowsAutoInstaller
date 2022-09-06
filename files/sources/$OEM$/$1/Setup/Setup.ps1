# TODO Set size and position window

# TODO
# TODO


#------------------------------------------   Windows Functions   ---------------------------------------------
function Install-NuGet {
    #Install NuGet Dependency
    if ((Get-PackageProvider -ListAvailable -Name NuGet)) {
        Write-Host "Version of NuGet installed = " (Get-PackageProvider -Name NuGet).version
        Write-Log -Message "Version of NuGet installed =  $((Get-PackageProvider -Name NuGet).version)" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
    }
    else {
        try {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers 
            Write-Host "Nuget installed successfully = " (Get-PackageProvider -Name NuGet).version
            Write-Log -Message "Nuget installed successfully =  $((Get-PackageProvider -Name NuGet).version)" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
        catch [Exception] {
            Write-Warning "An error occurred during NuGet installation: $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during NuGet installation : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            #exit
        }
    }
}

function Invoke-UpdateHandler {
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = 'SecondRound')]
        [Switch] $SecondRound
    )
    

    # The Reset-WUComponents -Verbose cmdlet allows you to reset all Windows Update Agent settings, re-register libraries, 
    # and restore the wususerv service to its default state.
    # -SendReport –PSWUSettings @{SmtpServer="smtp.woshub.com";From="update_alert@woshub.com";To="wsus_admin@woshub.com";Port=25}

    
    if ((get-ConfigValue("Config.install_updates")) -eq $true -or (get-ConfigValue("Config.install_drivers"))) {
        if ($SecondRound -eq $false) {
            try {
                Write-Host "Installing Windows update module.."
                Set-ExecutionPolicy Bypass -Scope Process -Force
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
                Install-Module PSWindowsUpdate -force
            }
            catch [Exception] {
                Write-Warning "An error occurred during windows update module import: $($_.Exception.Message)"
                Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during windows update module import : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                return $false
            }
        }
        else { "second round ready to dev" }
        if ((get-ConfigValue("Config.install_updates")) -eq $true) {
            try {
                Write-Host "Add Microsoft products to Windows Updates..."
                Add-WUServiceManager -MicrosoftUpdate -Confirm:$False
                Write-Host "Gathering Windows Updates..."
                if ((get-ConfigValue("Config.install_drivers")) -eq $true) {
                    #if ((Get-WURebootStatus).RebootRequired -eq $false){}
                    #Get-WindowsUpdate | Out-File c:\updatesAvailable.log
                    #TODO handle Updates errors and Logging it
                    Write-Host "Installing Windows Updates and drivers..."
                    Install-WindowsUpdate -AcceptAll -IgnoreReboot -MicrosoftUpdate | Out-File $global:logFileWinUpdate
                }
                else {
                    #Get-WindowsUpdate -NotCategory "drivers" | Out-File c:\updatesAvailable.log
                    Write-Host "Installing Windows Updates..."
                    Install-WindowsUpdate -NotCategory "drivers" -AcceptAll -IgnoreReboot -MicrosoftUpdate | Out-File $global:logFileWinUpdate
                }
                #Get-WindowsUpdate -NotCategory "drivers" | Out-File c:\updatesAvailable.log
                #Write-Host "Installing Windows Updates..."
                #Install-WindowsUpdate -NotCategory "drivers" -AcceptAll -IgnoreReboot -MicrosoftUpdate | Out-File $global:logFileWinUpdate
            }
            catch {
                Write-Warning "An error occurred during Windows Update : $($_.Exception.Message)"
                Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during Windows Update : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            }
            #if ((get-ConfigValue("Config.install_drivers")) -eq $true){
            #    try{
            #        Get-WindowsUpdate -Category "drivers" | Out-File c:\updatesAvailableDrivers.log
            #        Install-WindowsUpdate -Category "drivers" -AcceptAll -IgnoreReboot | Out-File $global:logFileDriversUpdate
            #    }catch{
            #        Write-Warning "An error occurred during Windows Update drivers installation : $($_.Exception.Message)"
            #        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during Windows Update drivers installation : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            #    }
            #}
        }
    

    }
    
}
function enable-UAC {
    #  TODO VERIFY UAC
    # 
    #$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    #$filter="ConsentPromptBehaviorAdmin|ConsentPromptBehaviorUser|EnableInstallerDetection|EnableLUA|EnableVirtualization|PromptOnSecureDesktop|ValidateAdminCodeSignatures|FilterAdministratorToken"
    #(Get-ItemProperty $path).psobject.properties | where {$_.name -match $filter} | select name,value
    try {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        if ((get-ConfigValue("Config.uac_ask_for_password")) -eq $true -and (get-ConfigValue("Config.user_password")) -ne $false) {
            New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorAdmin' -Value 3 -PropertyType DWORD -Force | Out-Null
        }
        else {
            New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorAdmin' -Value 5 -PropertyType DWORD -Force | Out-Null
        }
        New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorUser' -Value 3 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $path -Name 'EnableInstallerDetection' -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $path -Name 'EnableLUA' -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $path -Name 'EnableVirtualization' -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $path -Name 'PromptOnSecureDesktop' -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $path -Name 'ValidateAdminCodeSignatures' -Value 0 -PropertyType DWORD -Force | Out-Null
        #New-ItemProperty -Path $path -Name 'FilterAdministratorToken' -Value 0 -PropertyType DWORD -Force | Out-Null
        Write-Log -Message "UAC prompt enabled!" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        Write-Host "UAC prompt enabled!" 
    }
    catch {
        Write-Warning "An error occurred during UAC Activation. $($_.Exception.Message)"
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during UAC Activation. $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
    }
}
function install-Winget {
    try {
        $url = Get-ConfigValue('Config.VCLibs_URL')
        Add-AppxPackage $url -ForceApplicationShutdown -ErrorAction Stop 
        if ($?) {
            Write-Host "Success on VCLib"
            Write-Log -Message "Success on VCLibs installation" -Level Debug  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
        else {
            Write-Host "Error on VCLib"            
            Write-Log -Message "An unkown error occurred during VCLibs Install" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

            exit
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.ScriptStackTrace
        $FailedException = $_.Exception.GetType().FullName
        Write-Warning "An unkown error occurred during VCLibs Install : `n         $FailedException $FailedItem.`n         $ErrorMessage"  
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during VCLibs Install: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        exit
    }
    try {
        $url = Get-ConfigValue('Config.XAML_Runtime_URL')
        Add-AppxPackage $url -ForceApplicationShutdown -ErrorAction Stop
        if ($?) {
            #Log info "Installation de Microsoft.UI.Xaml Réussie" $LogFileDependencies
            Write-Host "Success on Microsoft.UI.Xaml"
            Write-Log -Message "Success on Microsoft.UI.Xaml Install." -Level Debug  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        }
        else {
            #Log error "Echec de l'installation Microsoft.UI.Xaml : Erreur inconnue" $LogFileDependencies
            Write-Host "Error on Microsoft.UI.Xaml"
            Write-Log -Message "An unkown error occurred during Microsoft.UI.Xaml Install." -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }

    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.ScriptStackTrace
        $FailedException = $_.Exception.GetType().FullName
        Write-Warning "An error occurred during Microsoft.UI.Xaml installation : `n         $FailedException $FailedItem.`n         $ErrorMessage"  
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during Microsoft.UI.Xaml Install: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        #exit
        
    }
    try {
        #Install-Package Microsoft.UI.Xaml -Force
        $url = Get-ConfigValue('Config.WinGet_URL')
        Add-AppxPackage $url -ForceApplicationShutdown -ErrorAction Stop 
        if ($?) {
            #Log info "Installation de WinGet Réussie" $LogFileDependencies
            Write-Host "Success on WinGet"
            Write-Log -Message "Success on WinGet Install." -Level Debug  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        }
        else {
            #Log error "Echec de l'installation WinGet : Erreur inconnue" $LogFileDependencies
            Write-Host "Error on WinGet"
            Write-Log -Message "An unkown error occurred during WinGet Install." -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }

    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.ScriptStackTrace
        $FailedException = $_.Exception.GetType().FullName
        Write-Warning "An error occurred during WinGet installation : `n         $FailedException $FailedItem.`n         $ErrorMessage"  
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during WinGet Install: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        #exit
        
    }
}
function Install-Choco {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    catch {
        Write-Warning "An error occurred during Chocolatey installation." 
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during Chocolatey Install: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

    }
}
function install-wsl {
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = 'SecondRound')]
        [Switch] $SecondRound
    )

    if ($SecondRound -eq $false) {
        enable-Feature Microsoft-Windows-Subsystem-Linux
        enable-Feature VirtualMachinePlatform
    }
    else {
        try {
            Write-Host "Set WSL $(get-ConfigValue("config.wsl_version")) as default"
            wsl --set-default-version (get-ConfigValue("config.wsl_version"))  
        }
        catch {
            Write-Warning "An error occurred during WSL default version setup : $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during WSL default version setup : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
        #if ((get-ConfigValue("Config.wsl_distribution")) -ne $false){
        #    ### en cours
        #    $distro = get-ConfigValue("Config.wsl_distribution")
        #    if ($global:DistributionsAvailable -contains $distro){
        #        if ($distro -eq "opensuse"){$distro = "opensuse-42"}
        #        if ($distro -eq "kali"){$distro = "kali-linux"}
        #    }
        #    
        #    try {
        #        Write-Host "Installing distribution $($distro)..."
        #        wsl --install -d $distro
        #    }
        #    catch {
        #        Write-Warning "An error occurred during Linux distribution install : $($_.Exception.Message)"
        #        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during Linux distribution install : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        #    }
        #}
               
    }
    
}
function enable-Feature {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Feature 
    )

    try {
        #Enable-WindowsOptionalFeature -FeatureName $Feature -Online -NoRestart
        Enable-WindowsOptionalFeature -FeatureName $Feature -Online -LogPath ($global:logPath + "\features.log") -NoRestart
        Write-Host "Success on $Feature Activation."
        Write-Log -Message "Success on $Feature Activation." -Level Debug  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))


    }
    catch {
        Write-Warning "An error occurred during the following feature activation : $Feature : $($_.Exception.Message)"
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during the following feature activation : $Feature : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
    }


}
function Test-CustomAnydesk {
    # TODO remove downloader
    if (Test-Path -Path C:\setup\AnyDesk.exe -PathType Leaf) {
        try {
            c:\setup\AnyDesk.exe --install "c:\Program Files (x86)\AnyDesk" --start-with-win --silent --create-shortcuts --create-desktop-icon
            if (Test-Path -Path "c:\Program Files (x86)\AnyDesk\anydesk*.exe" -PathType Leaf) {
                Write-Host "AnyDesk Custom client Successfully installed."
                Write-Log -Message "AnyDesk Custom client Successfully installed." -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                
            }
        }
        catch {
            Write-Warning "An error occurred during AnyDesk custom client installation."
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during the AnyDesk Custom client installation : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        }
    }
    elseif ((get-ConfigValue("Config.anydesk_custom_url")) -ne $false ) {
        #Invoke-WebRequest -Uri (get-ConfigValue("Config.anydesk_custom_url")) -OutFile "C:\anydesk.exe"
        $download = Invoke-WebRequest -Uri (get-ConfigValue("Config.anydesk_custom_url")) -UseBasicParsing
        $content = [System.Net.Mime.ContentDisposition]::new($download.Headers["Content-Disposition"])
        $fileName = $content.FileName
        $filePath = 'c:\' + $fileName
        $file = [System.IO.FileStream]::new($filePath, [System.IO.FileMode]::Create)
        $file.Write($download.Content, 0, $download.RawContentLength)
        $file.Close()
        try {
            if ($fileName.EndsWith('msi')) {
                $MSIArguments = @(
                    "/i"
                    ('"{0}"' -f $filePath)
                    "/qn"
                )
                Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
                if ($INSTALLED."DisplayName" -like "Anydesk*"){
                    Write-Host "AnyDesk Custom MSI client Successfully installed."
                    Write-Log -Message "AnyDesk Custom MSI client Successfully installed." -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                }else {
                    # TODO Throw error
                }
            }
            elseif ($fileName.EndsWith('exe')) {
                c:\AnyDesk.exe --install "c:\Program Files (x86)\AnyDesk" --start-with-win --silent --create-shortcuts --create-desktop-icon
                if (Test-Path -Path "c:\Program Files (x86)\AnyDesk\anydesk*.exe" -PathType Leaf) {
                    Write-Host "AnyDesk Custom client Successfully installed."
                    Write-Log -Message "AnyDesk Custom client Successfully installed." -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                }
                else {
                    # TODO Throw error
                }
            }
            else {
                # TODO Throw error
            }
            
        }
        catch {
            Write-Warning "An error occurred during AnyDesk custom client installation."
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during the AnyDesk Custom client installation : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        }
    }
    else {
        Write-Host "No Custom AnyDesk File found. Continuing..."
        Write-Log -Message "No Custom AnyDesk File found. Continuing..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

    }
}

function Invoke-AppHandler ($app) {
    #Anydesk password 
    # TODO get and send ID somewhere along with hostname https://support.anydesk.com/knowledge/command-line-interface-for-windows#client-commands
    if ($app.toLower().Contains("anydesk")) {
        if (get-ConfigValue("Config.anydesk_password")) {
            if (Test-Path -Path "C:\Program Files (x86)\AnyDesk\AnyDesk.exe") {
                Write-Host "setting Anydesk.exe PASSWORD"
                #cmd /c “C:\Program Files (x86)\AnyDesk\AnyDesk.exe” --start-with-win --update-auto
        (echo (get-ConfigValue("Config.anydesk_password")) | cmd /c "C:\Program Files (x86)\AnyDesk\AnyDesk.exe" --set-password) 
    
            }
            ElseIf (Test-Path -Path "C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe") {
                Write-Host "setting Anydesk MSI PASSWORD"
                #cmd /c “C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe” --start-with-win --update-auto
        (echo (get-ConfigValue("Config.anydesk_password")) | cmd /c "C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe" --set-password)
            }   
        }
        
    }
    #--------------#
    #     PLEX     #
    #--------------#
    if ($app.toLower().Contains("plex")) {
        if (Test-Path -Path "C:\program files\plex\plex\plex.exe") {
            #bypass FW
            try {
                New-NetFirewallRule -DisplayName "Plex-init" -Direction Inbound -Program "C:\program files\plex\plex\plex.exe" -Action Allow
            }
            catch {
                Write-Warning "An error occurred during plex firewall set. [$($_.Exception.GetType().FullName)]" 
                Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during plex firewall set.: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            }
        }
    }
    #--------------#
    #    Disord    #
    #--------------#
    if ($app.toLower().Contains("discord")) {
        # I have to check the registry key 7
        Write-Host "DISCOOOOORD"
    }
    #--------------#
    #    TEAMS     #
    #--------------#
    if ($app.toLower().Contains("office") -or $app.toLower().Contains("microsoft.teams")) {
        # Disable teams from startup
    }

}
function Invoke-AppInstaller {
    # orphan parameter -SecondRound for choco apps install 
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = 'SecondRound')]
        [Switch] $SecondRound
    )
    
    if ($SecondRound -eq $false) {
        # Check and Install custom AnyDesk Client
        # directly from url
        Test-CustomAnydesk
        #Install WSL if wanted
        if ((get-ConfigValue("config.wsl")) -eq $true) {
            Install-wsl
        }
        #Install WinGet if wanted
        if ((get-ConfigValue("config.winget")) -eq $true) {
            Write-Host "Installing WinGet..."
            Write-Log -Message "Installing WinGet..." -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            install-Winget
        }
        else {
            Write-Host "Skipping WinGet Installation..."
            Write-Log -Message "Skipping WinGet Installation..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            #Start-Sleep 20 
        }
        #Install chocolatey if wanted
        if ((get-ConfigValue("config.chocolatey")) -eq $true) {
            Install-Choco
        }
        else {
            Write-Host "Skipping Chocolatey Installation..."
            Write-Log -Message "Skipping Chocolatey Installation..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            #Start-Sleep 20 
        }        
        # Install WinGet Applications
        if ((get-ConfigValue("config.winget")) -eq $true) {
            $Stoploop = $false
            [int]$Retrycount = "0"
            do {
                try {
                    Write-Host "Installing WinGet Apps..."
                    Write-Log -Message "Installing WinGet Apps..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    foreach ( $node in (get-ConfigValue("wingetApps")).Split(";") ) {
                        write-host "Try to install $node ..."
                        Write-Log -Message "Try to install $node ..." -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                        if ($node -ne "") {
                            $global:installs.nb++
                            $listApp = winget search --accept-source-agreements --source "winget" --id $node 
                            if ([String]::Join("", $listApp).Contains($node)) {
                                winget install  --silent --accept-package-agreements --accept-source-agreements --id $node
                                if ([String]::Join("", (winget list --id $node)).Contains($node)) {
                                    Write-host "Installed :  $node"
                                    Write-Log -Message "Installed :  $node" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                                    $global:installs.success++
                                    $null = Invoke-AppHandler ($node)
                                    $Stoploop = $false
                                }
                                
                                else {
                                    $global:installs.errors++
                                    Write-Host "Install error : $line"
                                    Write-Log -Message "Install error : $line" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                                    $global:InstallErrors.add($node)
                                }
                            }
                            else {
                                $global:installs.skipped++
                                Write-host "Not installed :  $node : NOT FOUND"
                                Write-Log -Message "Not installed :  $node : NOT FOUND" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))                        
                                $global:InstallSkipped.add($node)
                            }
                    
                        }
                    }#End Foreach
                    Write-Host "Winget apps install Job completed"
                    Write-Host "Winget store apps is not available yet. Skipping.."
                    #Write-Host "Installing WinGet STORE Apps..."

                    # TODO Accept Store licence agreement if wanted    
                    #foreach ( $node in (get-ConfigValue("winStoreApps")).Split(";") ) {
                    #    write-host "Try to install STORE app $node ..."
                    #    Write-Log -Message "Try to install STORE app $node ..." -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    #    if ($node -ne "") {
                    #        $global:installs.nb++
                    #        $listApp = winget search --source msstore --accept-source-agreements --source "winget" --id $node 
                    #        if ([String]::Join("", $listApp).Contains($node)) {
                    #            winget install  --silent --accept-package-agreements --accept-source-agreements --id $node
                    #            if ([String]::Join("", (winget list --id $node)).Contains($node)) {
                    #                Write-host "Installed STORE app :  $node"
                    #                Write-Log -Message "Installed STORE app :  $node" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    #                $global:installs.success++
                    
    
                    #                
                    #                
                    #            }
                    #            else {
                    #                $global:installs.errors++
                    #                Write-Host "Install STORE app error : $line"
                    #                Write-Log -Message "Install STORE app error : $line" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    #                $global:InstallErrors.add($node)
                    #            }
                    #        }
                    #        else {
                    #            $global:installs.skipped++
                    #            Write-host "Not installed STORE app :  $node : NOT FOUND"
                    #            Write-Log -Message "Not installed STORE app :  $node : NOT FOUND" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))                        
                    #            $global:InstallSkipped.add($node)
                    #        }
                    #
                    #    }
                    #}#End Foreach
                    $Stoploop = $true
                    Write-Log -Message "Winget STORE apps install Job completed" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            

                }
                catch [System.Management.Automation.CommandNotFoundException] {
                    if ($Retrycount -gt 3) {
                        Write-Warning "Could not invoke WinGet after 3 retries."
                        Write-Log -Message "[$($_.Exception.GetType().FullName)] Could not invoke WinGet after 3 retries : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                        $Stoploop = $true
                    }
                    else {
                        $Retrycount = $Retrycount + 1
                        Write-Host "Winget seems to be not installed, SHOULD BE (Shame on you)! installing..."
                        Write-Log -Message "Winget seems to be not installed, SHOULD BE (Shame on you)! installing..." -Level Warning  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                        Install-WinGet
                    }
                }
                catch {
                    Write-Warning "Not handled Exception (error)"
                    Write-Log -Message "[$($_.Exception.GetType().FullName)] Not handled Exception : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        
                    $Stoploop = $true
                }
            }While ($Stoploop -eq $false)
            
        }

        
        #try {
        #    Set-ItemProperty -ErrorAction Stop -type String -Name "script.init" -Path "$($global:RegPath)$($global:Regname)" -Value "true"
        #    Write-Host "reboot key set"
        #}
        #catch {
        #    Write-Warning "An error occurred during reboot registry key set." 
        #    Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        #}
        #END First round
    }
    #BEGIN second round
    else {
        Write-Host "Starting invoke second round App installer..."
        Write-Log -Message "Starting invoke second round App installer..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        if ((get-ConfigValue("config.wsl")) -eq $true) {
            Install-wsl -SecondRound
        }
        else {
          
  
        }
        #Install Chocolatey apps if asked
        if ((get-ConfigValue("config.chocolatey")) -eq $true) {
            Write-Host "Installing Chocolatey Apps..."
            Write-Log -Message "Installing Chocolatey Apps..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            $apps = get-ConfigValue("chocoApps")
            try {
                if ($apps.Chars($apps.Length - 1) -eq ";") { $apps = ($apps.TrimEnd(";")) }
                if ($apps.length -gt 2) {
                    choco install -y --log-file=$global:logFileAppsInstaller $apps | Out-File -Append -Encoding oem -FilePath ($global:logPath + "\choco-raw.log")
                }
                else {
                    Write-Host "No apps selected, Skipping Chocolatey apps..."
                    Write-Log -Message "No apps selected, Skipping Chocolatey apps..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                }
                
                
                

            }
            catch {
                Write-Warning "An error occurred during Chocolatey apps installation : $($_.Exception.Message)"
                Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during Chocolatey apps installation : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            }

        }
        else {
            Write-Host "Skipping Chocolatey apps..."
            Write-Log -Message "Skipping Chocolatey apps..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
    
    
    }

    

    
}
function set-installSummary {
    $text = ""
    foreach ( $node in $global:InstallErrors ) {
        $text = $text + ";" + $node
    }
    set-ConfigValue -paramName "installErrors" -paramValue $text
    $text = ""
    foreach ( $node in $global:InstallSkipped ) {
        $text = $text + ";" + $node
    }
    set-ConfigValue -paramName "installSkipped"       -paramValue ($text).toString()
    set-ConfigValue -paramName "installs.nb" -paramValue ($global:installs.nb)
    set-ConfigValue -paramName "installs.nb.toInstall" -paramValue ($global:installs.success)
    set-ConfigValue -paramName "installs.nb.skipped" -paramValue ($global:installs.errors)
    set-ConfigValue -paramName "installs.nb.errors" -paramValue ($global:installs.skipped)
    set-ConfigValue -paramName "log.warnings" -paramValue ($global:logCounter.warnings)
    set-ConfigValue -paramName "log.errors" -paramValue ($global:logCounter.errors)
}
function get-installSummary {
    $apps = get-ConfigValue('installErrors').Split(";")
    foreach ( $app in $apps ) {
        $global:InstallErrors.add($app)
    }
    $apps = get-ConfigValue('installSkipped').Split(";")
    foreach ( $app in $apps ) {
        $global:InstallSkipped.add($app)
    }
    $global:installs.nb = get-ConfigValue('installs.nb')
    $global:installs.success = get-ConfigValue('installs.nb.toInstall')
    $global:installs.errors = get-ConfigValue('installs.nb.skipped')
    $global:installs.skipped = get-ConfigValue('installs.nb.errors')
    $global:installs.warnings = get-ConfigValue('log.warnings')
    $global:installs.errors = get-ConfigValue('log.errors')

}
function Invoke-SettingsWorker {
    
    #TODO Etirer/remplir/...          https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsDesktop::Wallpaper
    #TODO Folder diaporama
    # Copy wallpapers in c:\users\public\pictures is not a bad idea : https://community.spiceworks.com/topic/2093627-ps-to-change-wallpaper-for-all-users-and-center-the-image

    # Set hostname
    try {
        if ((get-ConfigValue("Config.hostname")) -ne $false) {
            Rename-Computer -NewName (get-ConfigValue("Config.hostname")) -Force
            Write-Host "Renamed hostname"
        }
    }
    catch {
        Write-Warning "An error occurred during hostname set : [$($_.Exception.GetType().FullName)]" 
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during hostname set : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
    }
    # Set Wallpaper
    try {
        if ( (get-ConfigValue("Windows.wallpaper_path")) -ne $false ) {
            # Check if path exist
            if (Test-Path -Path (get-ConfigValue("Windows.wallpaper_path")) -PathType Leaf) {
                Set-ItemProperty -ErrorAction Stop -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value (get-ConfigValue("Windows.wallpaper_path"))
                rundll32.exe user32.dll, UpdatePerUserSystemParameters
            }
            #elseif (Test-Path -Path (get-ConfigValue("Windows.wallpaper_path"))) {
            #    $check = get-ConfigValue("Windows.wallpaper_path")
            #    if ($check -notmatch '\\$'){$check += '\*'}else{$check += '*'}
            #    if (Test-Path -Path $check -include *.png,*.jpg,*.jpeg){
            #        # Set Wallpaper slideshow
            #    }
            #}
        }
    }
    catch {
        Write-Warning "An error occurred during wallpaper set : [$($_.Exception.GetType().FullName)]" 
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during wallpaper set : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
    }try {
        if ( (get-ConfigValue("Windows.edge_alt_tab")) -ne $false ) {
            if ( (get-ConfigValue("Windows.edge_alt_tab")).toLower() -eq 'disable' ) {
                if (-Not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced)) {
                    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Force
                    write-host "Explorer\Advanced not created. Creating..."
                }
                Set-ItemProperty -ErrorAction Stop -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name MultiTaskingAltTabFilter -value 3       
            }
        }
    }
    catch {
        Write-Warning "An error occurred during alt tab edge behavior set : [$($_.Exception.GetType().FullName)]" 
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during alt tab edge behavior set : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
    }
    # If Operating System is Windows 10
    if ((Get-WmiObject -class Win32_OperatingSystem).Caption.Contains('Windows 10')) {
        Write-Host "WINDOWS 10 DETECTED"
        # Set taskbar settings (news&interest, search)
        try {
            switch ( get-ConfigValue("Windows.SearchBoxTaskbar").ToLower() ) {
                off {
                    Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force
                    Write-Host "Set Search box mode into NO"
                    Write-Log -Message "Set Search box mode into NO" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                
                }
                button {
                    Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 1 -Type DWord -Force
                    Write-Host "Set Search box mode into Button"
                    Write-Log -Message "Set Search box mode into Button" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                }
                bar {
                    Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 2 -Type DWord -Force
                    Write-Host "Set Search box mode into Bar"
                    Write-Log -Message "Set Search box mode into Bar" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    
                }
                default {
                    Write-Host "Skipping search box setting..."
                }
            }
        }
        catch {
            Write-Warning "An error occurred during taskbar search box set : [$($_.Exception.GetType().FullName)]" 
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during taskbar search box set : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
        try {
            if ((get-ConfigValue("Windows.NewsAndInterest")) -ne $false -and (get-ConfigValue("Windows.NewsAndInterestMouseHover")) -ne $false ) {
                # Set Windows news & interest appearance 
                #$TestKey = Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds
                if (-Not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds)) {
                    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds -Force
                }
                if (-Not (Test-Path -Path "registry::HKEY_USERS\$($userSID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds")) {
                }
                switch ( get-ConfigValue("Windows.NewsAndInterest").ToLower() ) {
                    text {
                        Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds -Name ShellFeedsTaskbarViewMode -Value 0 -Type DWord -Force
                        Write-Host "news and interest Shows icon and text"
                        Write-Log -Message "news and interest Shows icon and text" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    }
                    icon {
                        Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds -Name ShellFeedsTaskbarViewMode -Value 1 -Type DWord -Force
                        Write-Host "news and interest Shows icon only"
                        Write-Log -Message "news and interest Shows icon only" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    }
                    off {
                        Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds -Name ShellFeedsTaskbarViewMode -Value 2 -Type DWord -Force
                        Write-Host "news and interest Hide News and Interests"
                        Write-Log -Message "news and interest Hide News and Interests" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    }
                    default {
                        Write-Host "Skipping news and interest setting..."
                    }
                }
                # Set Windows news & interest open on mouse hover
                switch ( get-ConfigValue("Windows.NewsAndInterestMouseHover").ToLower() ) {
                    off {
                        Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds -Name ShellFeedsTaskbarOpenOnHover -Value 0 -Type DWord -Force
                        Write-Host "news and interest mouseover OFF"
                        Write-Log -Message "news and interest mouseover OFF" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    }
                    on {
                        Set-ItemProperty -ErrorAction Stop -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds -Name ShellFeedsTaskbarOpenOnHover -Value 1 -Type DWord -Force
                        Write-Host "news and interest mouseover ON"
                        Write-Log -Message "news and interest mouseover ON" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
                    }
                    default {
                        Write-Host "Skipping news and interest mouseover setting..."
                    }
                }
            }
        }
        catch {
            Write-Warning "An error occurred during news and interest set : [$($_.Exception.GetType().FullName)]" 
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during news and interest set : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
            
    }#end If WIN 10
    # Change username
    if ((get-ConfigValue("Config.user_name")) -ne $false) {
        $UserAccount = Get-LocalUser -Name "$($env:UserName)"
        try {
            #Rename-LocalUser -Name "$($env:UserName)" -NewName (get-ConfigValue("Config.user_name"))
            $UserAccount | Rename-LocalUser -NewName (get-ConfigValue("Config.user_name"))
            if ((get-ConfigValue("Config.user_fullname")) -ne $false) {
                #Set-LocalUser -name "$($env:UserName)" -fullname (get-ConfigValue("Config.user_fullname"))
                $UserAccount | Set-LocalUser -fullname (get-ConfigValue("Config.user_fullname"))
            }
            else {
                $UserAccount | Set-LocalUser -fullname (get-ConfigValue("Config.user_name"))
            }  
        }
        catch {
            Write-Warning "An error occurred during username change : $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during username change : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
    }
    # Set password 
    if ((get-ConfigValue("Config.user_password")) -ne $false) {
        try {
            #if ((get-ConfigValue("Config.user_name")) -ne $false) {
            #    $UserAccount = Get-LocalUser -Name "$($env:UserName)"
            #}else {
            #    $UserAccount = Get-LocalUser -Name "$($env:UserName)"
            #}
            $plain_password = get-ConfigValue("Config.user_password")
            $Password = ConvertTo-SecureString $plain_password -AsPlainText -Force
            $UserAccount | Set-LocalUser -Password $Password
        }
        catch {
            Write-Warning "An error occurred during user password change : $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during user password change : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
        try {
            Set-ItemProperty -ErrorAction Stop -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 0 -Type DWord -Force
        }
        catch {
            Write-Warning "An error occurred during user autologon disable  : $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during user autologon disable : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        }
    }
    # TODO Disable Autolog DONE
    # disable automatic login if password
}

function set-Wireless {
    if ( (get-ConfigValue("Network.connect")) -eq $true ) {
        Write-Host "Trying to connect to wifi..."
        $guid = New-Guid
        $HexArray = (get-ConfigValue("Network.ssid")).ToCharArray() | foreach-object { [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($_)) }
        $HexSSID = $HexArray -join ""
        @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$(get-ConfigValue("Network.ssid"))</name>
    <SSIDConfig>
        <SSID>
            <hex>$($HexSSID)</hex>
            <name>$(get-ConfigValue("Network.ssid"))</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>$(get-ConfigValue("Network.authentication"))</authentication>
                <encryption>$(get-ConfigValue("Network.encryption"))</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$(get-ConfigValue("Network.password"))</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
    <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
        <enableRandomization>false</enableRandomization>
        <randomizationSeed>1451755948</randomizationSeed>
    </MacRandomization>
</WLANProfile>
"@ | out-file "$($ENV:TEMP)\$guid.SSID"
        netsh wlan add profile filename="$($ENV:TEMP)\$guid.SSID" user=all
        remove-item "$($ENV:TEMP)\$guid.SSID" -Force    
    }
    
}
function Invoke-BitlockerScript {}

#------------------------------------------  Gui/Console Related  ---------------------------------------------
function Show-TimerGUI($time, $MainWindowTitle, $MainWindowMsg) {
    $nums = 1..$time
    $null = Start-Job -Name 'sleep-window' -argumentlist $MainWindowTitle, $MainWindowMsg {
        #Add-Type -AssemblyName System.Windows.Forms
        [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
        [System.Windows.Forms.MessageBox]::Show($args[1], $args[0], 0)
    }
    
    $index = 0
    foreach ($num in $nums) {
        $index++
        Write-Progress -Activity 'sleep-window' -PercentComplete ($index / $nums.count * 100)
    
        if ((Receive-Job -Name 'sleep-window').value -eq 'ok') {
            break
        }
    
        Start-Sleep 1
    }

    #Closing window
    
    Get-Process | Where-Object { $_.MainWindowTitle -eq $MainWindowTitle } | Stop-Process -Force
    Remove-Job -Force -Name 'sleep-window'
}
function Set-ConsoleSizeAndPosition {
    param (
        [int]$X,
        [int]$Y,
        [int]$W,
        [int]$H    
    )
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")] 
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int W, int H); '
    
    $consoleHWND = [Console.Window]::GetConsoleWindow();
    #$consoleHWND
    [Console.Window]::MoveWindow($consoleHWND, $X, $Y, $W, $H);
}
#----------------------------------------- END Gui/Console Related --------------------------------------------
#------------------------------------------ PRE CHECKS/INIT FUNCT ---------------------------------------------
function Set-LogFolder {
    if (Test-Path -Path $global:logPath) {
        Write-Host "Log folder already created"
        
    }
    else {
        Write-Host "Creating log folder..."
        $null = New-Item -Type Directory -Path $global:logPath -Force
        if ((get-ConfigValue("Config.debug")) -ne $false) {
            Write-Host "Creating log folder..."
            $path = $global:logPath + "\DEBUG"
            $null = New-Item -Type Directory -Path $path -Force
        }
    }
}
function Get-Requirements {
    try {
        # PSM1/PS1 files import
        $global:depsPath + "*" | Get-ChildItem -include '*.psm1' | Import-Module -Global -ErrorAction Stop -Force
        # import powershell-yaml
        $path = $ENV:PSModulePath.Split(";")[0] + "\powershell-yaml"
        if (Test-Path -Path $path) {
            Import-Module powershell-yaml -Global -ErrorAction Stop -Force 
        
        }
        else {
            #Import deps psm1 files
            Expand-Archive "c:\setup\deps\powershell-yaml.*.zip" -DestinationPath C:\tmp\powershell-yaml -Force
            Copy-Item -Recurse C:\tmp\powershell-yaml $ENV:PSModulePath.Split(";")[0] -Force
            $policy = Get-ExecutionPolicy
            Set-ExecutionPolicy -ExecutionPolicy ByPass -Force
            Import-Module C:\tmp\powershell-yaml -Global -ErrorAction Stop -Force 
            Set-ExecutionPolicy -ExecutionPolicy $policy -Force
            ##https://michlstechblog.info/blog/powershell-install-a-nupkg-module-offline/
            Write-Log -Message "Folder created, importing from local drive" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        }
        # Done
        Write-Log -Message "LOCAL Modules Import successful" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        Write-Host "LOCAL Modules Import successful"

    }
    catch {
        Write-Warning "An error occurred during LOCAL Modules Import : $($_.Exception.Message)"
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during LOCAL Modules Import : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        exit
    }
}
function Get-Requirements-online {
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = 'SecondRound')]
        [Switch] $SecondRound
    )
    
    if ($SecondRound -eq $false) {
        #Import deps psm1 files
        try {
            $global:depsPath + "*" | Get-ChildItem -include '*.psm1' | Import-Module -Global -ErrorAction Stop -Force 
            Write-Log -Message "PSM Modules Import successful (Requirements-online-function)" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            Write-Host "PSM Modules Import successful (Requirements-online-function)"

        }
        catch {
            Write-Warning "An error occurred during PSM Modules Import (Requirements-online-function) : $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during PSM Modules Import (Requirements-online-function): $Feature : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            exit
        }
        Install-NuGet
        #Install PSGallery necessery modules
        if (Get-Module -ListAvailable -Name powershell-yaml) {
            Write-Host "Version of powershell-yaml installed = " (Get-InstalledModule -Name powershell-yaml).version
            Write-Log -Message "Version of powershell-yaml installed =  $((Get-InstalledModule -Name powershell-yaml).version)" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        
        }
        else {
            try {
                Install-Module -Name powershell-yaml -Force  
                Write-Host "powershell-yaml installed successfully = " (Get-InstalledModule -Name powershell-yaml).version
                Write-Log -Message "powershell-yaml installed successfully =  $((Get-InstalledModule -Name powershell-yaml).version)" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))


            }
            catch [Exception] {
                Write-Warning "An error occurred during ONLINE module import: $($_.Exception.Message)"
                Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during ONLINE module import : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
 
                exit
            }
        }
    }
    else {
        #Import deps psm1 files
        try {
            $global:depsPath + "*" | Get-ChildItem -include '*.psm1' | Import-Module -Global -ErrorAction Stop -Force 
            Write-Log -Message "Modules LOCAL Import successful after reboot" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            Write-Host "Modules LOCAL Import successful after reboot."

        }
        catch {
            Write-Warning "An error occurred during LOCAL Modules Import after reboot: $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during LOCAL Modules Import after reboot: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            exit
        }
    }
    


}
function Get-YamlFile {
    if (Test-Path -Path ".\config.yaml" -PathType Leaf) { $yamlPath = ".\config.yaml" }
    if (Test-Path -Path "c:\setup\config.yaml" -PathType Leaf) { $yamlPath = "c:\setup\config.yaml" }
    if (Test-Path -Path "c:\config.yaml" -PathType Leaf) { $yamlPath = "c:\config.yaml" }
    
    try {
        [string[]]$fileContent = Get-Content -ErrorAction Stop $yamlPath
        Write-Host "YAML Import successful"
        Write-Log -Message "YAML Import successful" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))


    }
    catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning "Specified YAML file not found, trying default one."
        try {
            [string[]]$fileContent = Get-Content -ErrorAction Stop "C:\config.yaml"
            Write-Host "YAML Import successful2"
            Write-Log -Message "YAML Import successful" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        }
        catch [System.Management.Automation.ItemNotFoundException] {
            Write-Warning "An error occurred during YAML import: $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during YAML import: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            #$_.Exception.GetType().FullName
            exit
        }
        
    }
    catch {
        Write-Warning "An error occurred during YAML import: $($_.Exception.Message)"
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during YAML import: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        exit
    }
    
    $content = ''
    foreach ($line in $fileContent) { $content = $content + "`n" + $line }
    $global:yaml = ConvertFrom-YAML $content
  
}
function Add-RegPath {
    # Function add Registry key folder
    $tries = 0
    while ($tries -lt 2) {
        try {
            Set-ItemProperty -ErrorAction Stop -Name init -Path "$($global:RegPath)$($global:Regname)" -Value done
            Write-Host "Registry key created!"
            Write-Log -Message "Registry key created!" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

            $tries = 3;

        } 
        catch [System.Management.Automation.ItemNotFoundException] {
            $tries = $tries + 1
            Write-Host "Creating registry path..."
            Write-Log -Message "Creating registry path..." -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

            try {
                $null = New-Item -Path $global:RegPath -Name $global:Regname -Force
                Set-ItemProperty -ErrorAction Stop -Name init -Path  "$($global:RegPath)$($global:Regname)" -Value created
                Write-Host "Registry key already created!"
                Write-Log -Message "Registry key already created!" -Level Debug  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

                $tries = 3
            }
            catch {
                Write-Warning "Creating registry path Error...  $($_.Exception.Message)"
                Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during registry path creation: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

            }
            
        }
        catch { 
            $tries = $tries + 1
            Write-Warning "Creating registry path unkown Error...  $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An unkown error occurred during registry path creation: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

        }
    }
}
function Remove-RegPath {
    try {
        Remove-Item -Path "$($global:RegPath)$($global:Regname)" -Recurse
        Write-Host "Registry key Deleted!"
        Write-Log -Message "Registry key already Deleted!" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))


    }
    catch {
        Write-Warning "An unkown error occurred during registry deletion...  $($_.Exception.Message)"
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An unkown error occurred during registry deletion: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

    }

}
function set-Config {
    $winget = ""
    $winstore = ""
    $chocolatey = ""
    foreach ($section in $global:yaml.GetEnumerator()) {
        if (-Not $section.name.EndsWith('Apps')) {
            foreach ($line in $section.value.GetEnumerator()) {
                try {
                    #Write-Host "$($line.name) ---------- $($line.value)"
                    Set-ItemProperty -ErrorAction Stop -type String -Name "$($section.name).$($line.name)" -Path "$($global:RegPath)$($global:Regname)" -Value $line.Value
                    #Write-Host "Config Variables successsfully inserted in registry"
                }
                catch {
                    Write-Warning "An error occurred during registry variables initalization :  $($_.Exception.Message)"
                    Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during registry variables initalization : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

                     
                }
            }
        }
        else {
            foreach ($line in $section.value) {
                if ($section.name.StartsWith('winget')) { $winget = $winget + $line + ";" }
                if ($section.name.StartsWith('winStore')) { $winstore = $winstore + $line + ";" }
                if ($section.name.StartsWith('choco')) { $chocolatey = $chocolatey + $line + ";" }
            }
        
        
        }
    
    

        try {
            if ($section.name.StartsWith('winget')) { $valueToSet = $winget }
            if ($section.name.StartsWith('winStore')) { $valueToSet = $winstore }
            if ($section.name.StartsWith('choco')) { $valueToSet = $chocolatey }
            if ($section.name.EndsWith('Apps')) {
                Set-ItemProperty -ErrorAction Stop -type String -Name "$($section.name)" -Path "$($global:RegPath)$($global:Regname)" -Value $valueToSet
            }
    
        }
        catch {
            Write-Warning "An error occurred during registry APPS variables initalization :  $($_.Exception.Message)"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during registry APPS variables initalization : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

            
        }
    }
    write-host "Config Saved in registry"
}
function Test-UpLink {
    $x = Get-WmiObject -class Win32_NetworkAdapterConfiguration `
        -filter DHCPEnabled=TRUE |
    Where-Object { $_.DefaultIPGateway -ne $null }
    if ( ($x | Measure-Object).count -gt 0 ) { return $true }else { return $false }
    
}
function wait-for-network ($tries) {
    while (1) {
        if ( (Test-UpLink) -eq $true ) {
            break
        }
        if ( $tries -gt 0 -and $try++ -ge $tries ) {
            throw "Network unavaiable after $try tries."
            Write-Warning "NO NETWORK CONNECTION, ABORTING..."
            Write-Log -Message "NO NETWORK CONNECTION, ABORTING..." -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            exit

        }
        Write-Warning "No Network. Please connect computer to internet."
        Write-Host "Trying back in 30 seconds..."
        if ($try -eq 1) {
            Write-Host "FIrst Try is 1"
            set-Wireless
            Show-TimerGUI 10 "Connection." "Is it conencted?"
        }
        else {
            Show-TimerGUI 30 "No Network." "Please connect computer to internet and wait for 30 seconds or click OK"
        }
        
    }
}
function Invoke-InitSetupScript {
    # https://ss64.com/nt/powercfg.html
    #Powercfg /Change monitor-timeout-ac 60
    Powercfg /Change standby-timeout-ac 0
}
function Invoke-EndSetupScript {
    #
    
    
    Enable-UAC
    set-ConfigValue -paramName "script.init" -paramValue "finish"
    Powercfg /Change standby-timeout-ac 120
    Set-LogCount
    
    #https://docs.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
}
#------------------------------------------ END PRE CHECKS/INIT FUNCT ---------------------------------------------

#------------------------------------------ COMMON funct ----------------------------------------------------------
function set-ConfigValue($paramName, $paramValue) {
    #param
    #(
    #    [Parameter(Mandatory = $true, ParameterSetName = 'paramName')]
    #    $paramName,
    #    [Parameter(Mandatory = $true, ParameterSetName = 'paramValue')]
    #    $paramValue
    #
    #)
    try { 
        Set-ItemProperty -ErrorAction Stop -type String -Name "$($paramName)" -Path "$($global:RegPath)$($global:Regname)" -Value $paramValue
    }
    catch {
        Write-Warning "An error occurred during registry key write: $paramName :  $($_.Exception.Message)"
        Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during registry key write: $paramName : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        
        # write-host $_.Exception.GetType().FullName
    }
    
}
function get-ConfigValue($paramName) {
    $output = ''
    try { 
        $output = Get-ItemPropertyValue -ErrorAction Stop -Path "$($global:RegPath)$($global:Regname)" -Name $paramName
        if ($output.toLower() -eq 'true' -Or $output.toLower() -eq 'yes') { return $true }
        if ($output.toLower() -eq 'false' -Or $output.toLower() -eq 'no') { return $false }
        return $output
    }
    catch {
        #if ($paramName.toLower() -eq "script.init") { 
        #    Write-Warning "An error occurred during registry key init script retrival: $paramName. Can be normal in some case. Check log in case of doubt"
        #    Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during registry key init script retrival: $paramName : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        #    return $false 
        #}
        #if ($paramName.toLower() -eq "script.init" -Or $paramName.toLower().Contains("anydesk_") -Or $paramName.toLower().Contains("windows") -Or $paramName.toLower() -eq "config.debug" -Or $paramName.toLower() -eq "Config.hostname" -Or $paramName.toLower() -eq "Config.user_password") { return $false }
        if ($paramName.toLower() -eq "config.vclibs_url" -Or $paramName.toLower() -eq "config.winget_URL" -Or $paramName.toLower() -eq "config.xaml_runtime_url" ) { 
            Write-Warning "An error occurred during registry key retrival: $paramName. Can be normal in some case. Check log in case of doubt"
            Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during registry key retrival: $paramName : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
            return $false 
        }
        if ($paramName.toLower() -eq "config.install_updates") { return $true }
        else { return $false }
        
        # write-host $_.Exception.GetType().FullName
    }
    
}
function set-LogCount {
    #param(
    #    [Parameter(Mandatory=$true)]
    #    [String]$Path
    #)
    if (-not (get-ConfigValue("script.init"))){

    }

    $path = $global:logFile 
    $line = "======================================  Summary  ======================================"
    $line | Out-File -FilePath $global:logFile -Append
    if (-not (get-ConfigValue("script.init"))){
        $line = "                                       First run"
        $line | Out-File -FilePath $global:logFile -Append 
    }
    if ([int]$global:logCounter.warnings -eq 0 -And [int]$global:logCounter.errors -eq 0) {
        $line = "                       Everything happened like a charm."
        $line | Out-File -FilePath $global:logFile -Append
    }
    else {
        $line = "                Nombre d'erreurs   :                                       " + $global:logCounter.errors
        $line | Out-File -FilePath $global:logFile -Append
        $line = "                Nombre de warnings :                                       " + $global:logCounter.warnings
        $line | Out-File -FilePath $global:logFile -Append
        $line = "REPORT This file to dev@ayoute.be"
        $line | Out-File -FilePath $global:logFile -Append
    }
    $line = "============================================================================================"
    $line | Out-File -FilePath $global:logFile -Append
   
    
}
function Set-ConsoleSizeAndPosition {
    param (
        [int]$X,
        [int]$Y,
        [int]$W,
        [int]$H    
    )
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")] 
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int W, int H); '
    
    $consoleHWND = [Console.Window]::GetConsoleWindow();
    #$consoleHWND
    [Console.Window]::MoveWindow($consoleHWND, $X, $Y, $W, $H);
}

#------------------------------------------ END COMMON funct ------------------------------------------------------

#------------------------------------------        INIT            ---------------------------------------------
function init {
    ## Save the current execution policy...
    #$currPolicy = Get-ExecutionPolicy
    ## ... and temporarily set the policy to 'Bypass' for this process.
    #Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    ## Restore the previous execution policy for this process.
    #Set-ExecutionPolicy -Scope Process -ExecutionPolicy $currPolicy -Force
    [string]$global:Regname = "Soflane"
    [string]$global:RegPath = "HKLM:\Software\"
    [String]$global:logPath = $env:USERPROFILE + "\Desktop\Logs" 
    [String]$global:logFile = $global:logPath + "\Soflane-script.log"
    [String]$global:logFileAppsInstaller = $global:logPath + "\AppsInstaller.log"
    [String]$global:logFileWinUpdate = $global:logPath + "\WindowsUpdate.log"
    #[String]$global:logFileDriversUpdate = $global:logPath + "\Drivers.log"
    [hashtable]$global:logCounter = @{ nb = 0; errors = 0; warnings = 0 }
    [hashtable]$global:installs = @{ nb = 0; toMake = 0; errors = 0; success = 0; skipped = 0 }
    [System.Collections.ArrayList]$global:InstallErrors = @()
    [System.Collections.ArrayList]$global:InstallSkipped = @() 
    $global:yaml = $null
    $global:DistributionsAvailable = @("ubuntu", "opensuse-42", "opensuse", "debian", "kali", "kali-linux", "sles-12", "Ubuntu-16.04", "Ubuntu-18.04", "Ubuntu-20.04")

    if (Test-Path -Path "c:\setup\deps\*.psm1" -type leaf ) {
        [string]$global:depsPath = "C:\setup\deps\"
    } elseif (Test-Path -Path ".\*.psm1" -type leaf) {
        [string]$global:depsPath = ".\"
    }


    if (-not (get-ConfigValue("script.init"))) {
        Write-Host "Initializing Script..."
        invoke-InitSetupScript
        Set-LogFolder
        if ( (Test-UpLink) -eq $true ) { Get-Requirements-online } else { Get-Requirements }
        Add-RegPath
        Get-YamlFile
        set-Config
        wait-for-network(10)
        Invoke-UpdateHandler
        Invoke-AppInstaller 
        set-installSummary
        # Reboot registry key insertion
        set-ConfigValue -paramName "script.init" -paramValue $true
        Start-Sleep 3
        Write-Host "reboot follow up key set"

        
    }
    else {
        if ( (Test-UpLink) -eq $true ) { Get-Requirements-online -SecondRound } else { Get-Requirements -SecondRound }
        wait-for-network(3)
        get-installSummary
        write-Host "Second round is starting..."
        Write-Log -Message "Second round is starting..." -Level Information  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        Invoke-AppInstaller -SecondRound
        #Windows Settings
        Invoke-UpdateHandler -SecondRound
        Invoke-SettingsWorker 
        Invoke-EndSetupScript
    }
}
#------------------------------------------      END INIT        ---------------------------------------------



#------------------------------------------        Main            ---------------------------------------------

Set-ConsoleSizeAndPosition 550 150 800 500
Write-Host @"
Welcome to Soflane's Windows unattended script
I hope you filled the yaml file
Otherwise it will fail


PRESS ANY KEY TO START THE MAGIC
"@
TIMEOUT 90
init
if ((get-ConfigValue("Config.debug")) -ne $false ) {
    #cmd /c Pause
    Write-Log -Message "PAUSE CHECK" -Level Verbose  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
    TIMEOUT 90
}

if ((get-ConfigValue("script.init")).Contains('finish')) {
    
    if ((get-ConfigValue("Config.debug")) -ne $false ) {
        Write-Log -Message "Don't forget to delete reg keys ;-)" -Level Debug  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
        Write-Host "SELF DESTROY"
        TIMEOUT 5
    }
    Remove-RegPath
}
#------------------------------------------        END MAIN            ---------------------------------------------



#Write-Warning "An error occurred during YAML import: $($_.Exception.Message)"
#Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred during YAML import: $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))

#Write-Log -Message "[$($_.Exception.GetType().FullName)] An error occurred : $($_.Exception.Message) - $($_.ScriptStackTrace)" -Level Error  -Path $global:logFile -Setting (get-ConfigValue("Config.debug"))
