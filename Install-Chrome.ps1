<#
.SYNOPSIS
Install Chrome locally
#>
[CmdletBinding()]
param()

Logit "Installing Chrome"

install-packageprovider chocolatey
Logit -indent "Chocolatey installed"

install-package googlechrome
Logit -indent "Chrome installed"