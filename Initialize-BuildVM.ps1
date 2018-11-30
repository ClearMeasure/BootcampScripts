<#
.SYNOPSIS
run on the newly minted build box to setup the agent and install SQLExpress2017

.DESCRIPTION
To be called as part of the CustomScriptExtension of an Azure VM

.PARAMETER AccountUrl
URL to the account for the Agent

.PARAMETER PAT
PAT for the user  for the Agent

.PARAMETER SQLServicePwd
Password for the SQL Server Service

.PARAMETER SaPwd
Password for the sa SQL Server user

.PARAMETER AdminUser
User name to run the service as

.PARAMETER AdminUserPwd
Password for AdminUser

.PARAMETER Roles
Octopus Roles

.PARAMETER AgentPool
Pool for the agent, defaults to "AgentPool"

.PARAMETER InstanceName
SQL Instance name, defaults to sqlexpress2017

.PARAMETER Folder
Folder where to run this, defaults to c:\agent

.PARAMETER Environments
Octopus Environments

#>
param(
[Parameter(Mandatory)]
[string] $AccountUrl,
[Parameter(Mandatory)]
[string] $PAT,
[Parameter(Mandatory)]
[string] $SQLServicePwd,
[Parameter(Mandatory)]
[string] $SaPwd,
[Parameter(Mandatory)]
[string] $AdminUserName,
[Parameter(Mandatory)]
[string] $AdminUserPwd,
[Parameter(Mandatory)]
[string] $OctopusApiKey,
[Parameter(Mandatory)]
[string] $OctopusThumbprint,
[Parameter(Mandatory)]
[string[]] $Roles,
[Parameter(Mandatory)]
[string[]] $Environments,
[Parameter(Mandatory)]
[string] $PublicDnsName,
[Parameter(Mandatory)]
[string] $OctopusDisplayName,
[string] $AgentPool = "AgentPool",
[string] $InstanceName = "sqlexpress2017",
[string] $Folder = "c:\agent",
[switch] $SkipVsts,
[switch] $SkipSql,
[switch] $SkipTentacle,
[switch] $SkipIIS
)

Set-StrictMode -Version Latest

function LogIt {
param(
[Parameter(Mandatory)]
[string]$msg,
[switch] $indent,
[int] $lastExit = 0
)

    $indentStr = ""
    if ( $indent )
    {
        $indentStr = "    "
    }

    Add-Content -Encoding Unicode $LogFile -Value "$(Get-Date) $indentStr$msg"
    Write-Output $indentStr$msg

    if ( $lastExit )
    {
        throw "Non-zero last exit of $lastexit"
    }
}

function cloneIt {
    LogIt -indent "Cloning BootcampScripts"

    # handle issue that git writes to stderr for info messages, copied from Invoke-Git in bootcamp, that was copied from Seekatar
    $path = [System.IO.Path]::GetTempFileName()

    Invoke-Expression "git clone https://github.com/ClearMeasure/BootcampScripts.git 2> $path"
    $exit = $LASTEXITCODE
    if ( $exit -gt 0 )
    {
        Write-Error "Git exit code $exit for '$command'`n$(Get-Content $path)"
    }
    else
    {
        LogIt (Get-Content $path | Select-Object -First 1) # usually only need first line of output
    }
}

$null = mkdir $Folder -ErrorAction SilentlyContinue
Set-Location $Folder

$transcript = "$PWD\initialize-transcript-$(get-date -Format yyyyMMdd-hhmm).log"
$logFile = "$PWD\initialize-$(get-date -Format yyyyMMdd-hhmm).log"

Start-Transcript -Path $transcript

LogIt "Starting initialization at $(get-date)"
LogIt -indent "SkipVsts: $SkipVsts SkipSql: $SkipSql SkipTentacle: $SkipTentacle SkipIIS: $SkipIIS"
LogIt -indent "Running from $PSScriptRoot"
LogIt -indent "Created folder $Folder"

if ( Test-Path .\BootcampScripts )
{
    LogIt -indent ".\BootcampScripts exists, removing it"
    Remove-Item .\BootcampScripts -Recurse -Force
}

cloneIt

$ErrorActionPreference = "Stop"

try {

    $userDomain = "$env:COMPUTERNAME\$AdminUserName"

    if ( !$SkipVsts )
    {
        .\BootcampScripts\Add-VstsAgent.ps1 -LogFile $logFile -AccountUrl $AccountUrl -PAT $PAT -AdminUser $AdminUserName -AdminUserPwd $AdminUserPwd -AgentPool $AgentPool -DownloadFolder $PSScriptRoot
    }

    if ( !$SkipSql )
    {
        .\BootcampScripts\Install-SqlExpress.ps1 -LogFile $logFile -SaPwd $SaPwd -SvcPwd $SQLServicePwd -InstanceName $InstanceName -AdminUserDomain $userDomain
    }

    if ( !$SkipTentacle )
    {
        .\BootcampScripts\Install-Tentacle.ps1 -ApiKey $OctopusApiKey -Thumbprint $OctopusThumbprint -Roles $Roles -Environments $Environments -PublicDnsName $PublicDnsName -DisplayName $OctopusDisplayName
    }

    if ( !$SkipIIS )
    {
        .\BootcampScripts\Enable-IISFeature.ps1
    }

    .\BootcampScripts\Install-Chrome.ps1

    .\BootcampScripts\Set-HostValue.ps1

}
finally {
    try {
        Stop-Transcript
    } catch {}
}

