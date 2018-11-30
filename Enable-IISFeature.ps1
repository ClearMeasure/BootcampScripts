<#
.SYNOPSIS
Install IIS on a server
#>
[CmdletBinding()]
param()

$features = "IIS-WebServerRole",
"IIS-WebServer",
"IIS-CommonHttpFeatures",
"IIS-Security",
"IIS-RequestFiltering",
"IIS-StaticContent",
"IIS-DefaultDocument",
"IIS-DirectoryBrowsing",
"IIS-HttpErrors",
"IIS-ApplicationDevelopment",
"IIS-NetFxExtensibility45",
"IIS-ISAPIExtensions",
"IIS-ISAPIFilter",
"IIS-ASPNET45",
"IIS-HealthAndDiagnostics",
"IIS-HttpLogging",
"IIS-BasicAuthentication",
"IIS-WindowsAuthentication",
"IIS-Performance",
"IIS-HttpCompressionStatic",
"IIS-WebServerManagementTools",
"IIS-ManagementConsole",
"IIS-ManagementScriptingTools",
"IIS-ManagementService",
"IIS-IIS6ManagementCompatibility",
"IIS-Metabase"

Logit "Disabling Default Web Site" # since our app uses port 80
Import-Module WebAdministration
Stop-Website 'Default Web Site'

Logit "Enabling IIS Features"
$i = 0
$RestartNeeded = $false
foreach ( $feature in $features )
{
    Logit -indent $feature
    $result = Enable-WindowsOptionalFeature -online -FeatureName $feature
    $RestartNeeded = $RestartNeeded -and $result.RestartNeeded
    $i += 1
}
$RestartNeeded