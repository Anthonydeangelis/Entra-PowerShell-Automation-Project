Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-LabConfiguration {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path = (Join-Path $PSScriptRoot '../../config/lab.json')
    )

    $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Configuration file not found: $resolvedPath. Copy config/lab.example.json to config/lab.json first."
    }

    $configuration = Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
    foreach ($requiredProperty in 'tenantId', 'clientId', 'certificatePath', 'outputPath') {
        if (-not $configuration.PSObject.Properties[$requiredProperty] -or
            [string]::IsNullOrWhiteSpace([string] $configuration.$requiredProperty)) {
            throw "Configuration property '$requiredProperty' is required."
        }
    }

    return $configuration
}

function Connect-LabGraph {
    [CmdletBinding(DefaultParameterSetName = 'Application')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Application')]
        [pscustomobject] $Configuration,

        [Parameter(ParameterSetName = 'Application')]
        [securestring] $CertificatePassword,

        [Parameter(Mandatory, ParameterSetName = 'Delegated')]
        [switch] $Delegated
    )

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

    if ($Delegated) {
        Connect-MgGraph -Scopes @('User.Read.All', 'Group.Read.All') -NoWelcome
        return
    }

    $certificatePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        [string] $Configuration.certificatePath
    )
    if (-not (Test-Path -LiteralPath $certificatePath -PathType Leaf)) {
        throw "Graph application certificate not found: $certificatePath"
    }

    $certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
        $certificatePath,
        $CertificatePassword
    )

    Connect-MgGraph `
        -TenantId $Configuration.tenantId `
        -ClientId $Configuration.clientId `
        -Certificate $certificate `
        -NoWelcome
}

function Export-LabUserInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $OutputPath
    )

    Import-Module Microsoft.Graph.Users -ErrorAction Stop

    $resolvedOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    $outputDirectory = Split-Path -Parent $resolvedOutputPath
    if (-not (Test-Path -LiteralPath $outputDirectory)) {
        $null = New-Item -ItemType Directory -Path $outputDirectory -Force
    }

    Get-MgUser -All -Property @(
        'id'
        'displayName'
        'userPrincipalName'
        'accountEnabled'
        'userType'
        'createdDateTime'
    ) | Select-Object Id, DisplayName, UserPrincipalName, AccountEnabled, UserType, CreatedDateTime |
        Export-Csv -LiteralPath $resolvedOutputPath -NoTypeInformation -Encoding utf8

    return Get-Item -LiteralPath $resolvedOutputPath
}

Export-ModuleMember -Function Get-LabConfiguration, Connect-LabGraph, Export-LabUserInventory

