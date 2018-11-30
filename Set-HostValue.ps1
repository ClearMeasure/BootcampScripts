<#
.SYNOPSIS
Set values in the hosts file so tests will work since domain name is used in auth callback
#>
[CmdletBinding(SupportsShouldProcess)]
param(
[string] $TestWebServer = "cmbootcamptestweb.clear-measure.com",
[string] $StagingWebServer = "cmbootcampstagingweb.clear-measure.com"
)

Set-StrictMode -Version Latest

$fname = (Join-Path $env:windir "system32\drivers\etc\hosts" )
$hosts = Get-Content $fname -Raw
$saveIt = $false
if ( !$hosts.Contains($TestWebServer) )
{
    $hosts += "`r`n# added for Bootcamp testing`r`n127.0.0.1 $TestWebServer`r`n"
    LogIt "Adding $TestWebServer to hosts file"
    $saveIt = $true
}
if ( !$hosts.Contains($StagingWebServer) )
{
    $hosts += "`r`n# added for Bootcamp testsing`r`n127.0.0.1 $StagingWebServer`r`n"
    LogIt "Adding $StagingWebServer to hosts file"
    $saveIt = $true
}
if ( $saveIt -and $PSCmdlet.ShouldProcess($fname, "Add mappings" ) )
{
    Set-Content $fname -Value $hosts
}
