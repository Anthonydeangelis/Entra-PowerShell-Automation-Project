#Requires -Version 7.4
[CmdletBinding(DefaultParameterSetName = 'Application')]
param(
    [Parameter()]
    [string] $ConfigurationPath = (Join-Path $PSScriptRoot '../config/lab.json'),

    [Parameter(ParameterSetName = 'Delegated')]
    [switch] $Delegated
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../src/EntraAutomationLab/EntraAutomationLab.psd1') -Force

$configuration = Get-LabConfiguration -Path $ConfigurationPath
if ($Delegated) {
    Connect-LabGraph -Delegated
}
else {
    $password = Read-Host 'Certificate password' -AsSecureString
    Connect-LabGraph -Configuration $configuration -CertificatePassword $password
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportPath = Join-Path $configuration.outputPath "entra-users-$stamp.csv"
$report = Export-LabUserInventory -OutputPath $reportPath
Write-Host "User inventory written to $($report.FullName)"
