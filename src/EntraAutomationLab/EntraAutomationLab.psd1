@{
    RootModule        = 'EntraAutomationLab.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'f6916281-1c12-4981-bfb3-d7ff599f880e'
    Author            = 'Anthony DeAngelis'
    Description       = 'Reusable helpers for the Entra ID and PowerShell automation lab.'
    PowerShellVersion = '7.4'
    FunctionsToExport = @(
        'Get-LabConfiguration'
        'Connect-LabGraph'
        'Export-LabUserInventory'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}

