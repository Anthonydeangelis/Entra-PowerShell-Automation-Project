BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../../src/EntraAutomationLab/EntraAutomationLab.psd1'
    Import-Module $modulePath -Force
}

Describe 'Get-LabConfiguration' {
    It 'rejects a missing configuration file' {
        { Get-LabConfiguration -Path (Join-Path $TestDrive 'missing.json') } |
            Should -Throw '*Configuration file not found*'
    }

    It 'rejects malformed JSON' {
        $path = Join-Path $TestDrive 'malformed.json'
        '{invalid' | Set-Content -LiteralPath $path
        { Get-LabConfiguration -Path $path } | Should -Throw
    }

    It 'rejects an empty required value' {
        $path = Join-Path $TestDrive 'empty.json'
        @{
            tenantId = 'tenant-id'
            clientId = ' '
            certificatePath = '/tmp/certificate.pfx'
            outputPath = './output'
        } | ConvertTo-Json | Set-Content -LiteralPath $path
        { Get-LabConfiguration -Path $path } | Should -Throw '*clientId*'
    }

    It 'reads a valid configuration file' {
        $path = Join-Path $TestDrive 'lab.json'
        @{
            tenantId       = 'tenant-id'
            clientId       = 'client-id'
            certificatePath = '/tmp/certificate.pfx'
            outputPath     = './output'
        } | ConvertTo-Json | Set-Content -LiteralPath $path

        $result = Get-LabConfiguration -Path $path

        $result.tenantId | Should -Be 'tenant-id'
        $result.clientId | Should -Be 'client-id'
    }

    It 'rejects an incomplete configuration file' {
        $path = Join-Path $TestDrive 'lab.json'
        @{ tenantId = 'tenant-id' } | ConvertTo-Json | Set-Content -LiteralPath $path

        { Get-LabConfiguration -Path $path } | Should -Throw "*clientId*"
    }
}

Describe 'public showcase integrity' {
    It 'parses every PowerShell file without executing scripts' {
        $root = Join-Path $PSScriptRoot '../..'
        $files = Get-ChildItem "$root/src", "$root/scripts", "$root/showcase", "$root/tests" -Recurse -File |
            Where-Object Extension -in '.ps1', '.psm1', '.psd1'
        foreach ($file in $files) {
            $tokens = $null
            $parseErrors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseFile(
                $file.FullName, [ref]$tokens, [ref]$parseErrors)
            @($parseErrors).Count | Should -Be 0 -Because $file.Name
        }
    }

    It 'provides 25 unique synthetic usernames with required input fields' {
        $rows = @(Import-Csv (Join-Path $PSScriptRoot '../../data/fake-users-25.csv'))
        $rows.Count | Should -Be 25
        @($rows.UserName | Sort-Object -Unique).Count | Should -Be 25
        foreach ($row in $rows) {
            foreach ($field in 'UserName', 'DisplayName', 'Department', 'JobTitle', 'UsageLocation') {
                $row.$field | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'module surface' {
    It 'exports only the intended commands' {
        $commands = (Get-Command -Module EntraAutomationLab).Name
        $commands | Should -Be @(
            'Connect-LabGraph'
            'Export-LabUserInventory'
            'Get-LabConfiguration'
        )
    }
}
