<#PSScriptInfo
.SYNOPSIS
    Log a message with the specified log level in output or eventlog or log file.
    https://powershelltalk.com/2021/03/09/powershell-script-best-practices-2-powershell-logging/
.VERSION 1.1.1

.AUTHOR Arun sabale

.DESCRIPTION 
 Log a message with the specified log level and additional detail like date+time, line number and message in output console or eventlog or log file. 

.EXAMPLE
            #write to log file
            Write-Log -Message 'My Warning Msg' -Level Warning -Path C:\tmp\temp.log
            #write log to eventlog
            Write-Log -Message "my info msg" -Level Information -Eventlog 
            #write log to output screen
            Write-Log -Message "my info msg" -Level Information -output
#> 

function Write-Log {
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = 'output')]
        [parameter(Mandatory = $false, ParameterSetName = 'Eventlog')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'path')]
        [String] $Message,

        [Parameter(Mandatory = $false, ParameterSetName = 'output')]
        [parameter(Mandatory = $false, ParameterSetName = 'Eventlog')]
        [Parameter(Mandatory = $false, ParameterSetName = 'path')]
        [ValidateSet('Verbose', 'Information', 'Warning', 'Error', 'Debug')]
        [String] $Level = "Information",

        [Parameter(Mandatory = $false, ParameterSetName = 'output')]
        [Switch] $output,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'path')]
        [string] $path,

        [Parameter(Mandatory = $false)]
        [string] $setting,

        [Parameter(Mandatory = $false, ParameterSetName = 'Eventlog')]
        [Switch] $Eventlog
    )
    if ($setting -ne $false) {$DebugPreference = "Continue"}
    if ($Level -eq 'Warning') { $global:logCounter.warnings++ }
    if ($Level -eq 'Error') { $global:logCounter.errors++ }

    [string]$MessageTimeStamp = (Get-Date).ToString('yyyy-MM-dd - HH:mm:ss')
    $Message1 = "[Line $($MyInvocation.ScriptLineNumber)] : $Message"
            
    # Output to log file
    if ($path) {
        $Line = $MessageTimeStamp + " | " + $env:ComputerName + " | " + $Env:Username + " | [" + $Level.ToUpper() + "] " + $Message1
        switch ($Level) {
            'Verbose' { 
                if ($setting.ToLower() -eq 'verbose') { $Line | Out-File -FilePath $Path -Append }
                break
            }
            'debug' { 
                if ($setting -ne $true) { $Line | Out-File -FilePath $Path -Append }
                break
            }
            Default {
                $Line | Out-File -FilePath $Path -Append 
            }
        }
        
        
    }
    # Output to event log
    if ($Eventlog -eq $true) {
        if ($Level -eq 'Verbose') {
            $EntryType = 'Information'
        }
        else {
            $EntryType = $Level
        }                
        Write-EventLog -LogName 'Windows PowerShell' -Source 'PowerShell' -EventId 0 -Category 0 -EntryType $EntryType -Message $Message1
    }

    # Output to console
    if ((!$path) -and $Eventlog -eq $false) {
        switch ($Level) {
            'Debug' {Write-Debug -Message $Message1}
            'Verbose' { Write-Verbose -Message $Message1 }
            'Information' { try { Write-Output  $Message1 } catch { Write-Host $Message1 } }
            'Warning' { Write-Warning -Message $Message1 }
            'Error' { Write-Error -Message $Message1 }
                    
        }
    }
}