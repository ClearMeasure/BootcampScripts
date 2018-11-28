<#
.SYNOPSIS
Install Chrome locally
#>
[CmdletBinding()]
param()

Logit "Installing Chrome"

install-packageprovider chocolatey -force
Logit -indent "Chocolatey installed"

install-package googlechrome -force
Logit -indent "Chrome installed"