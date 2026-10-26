# Illustrated lab walkthrough

[Back to the project overview](../README.md)

I developed PowerShell scripts on an Ubuntu VM, deployed runbooks from GitHub to Azure Automation, and used managed identity to manage Entra users and groups. The completed user-creation run reads a CSV from Blob Storage and a temporary password from Key Vault.

**Result:** 25 lab users created, six department security groups populated, and 26 direct user memberships verified—including my existing account.

Start with the [code showcase](../showcase/README.md), [troubleshooting lessons](troubleshooting-lessons.md), or [screenshot gallery](screenshot-gallery.md). See [safe usage and publication notes](safety.md) before adapting scripts.

**Scope:** a completed learning lab with sanitized source snapshots and execution evidence—not a production-ready identity provisioning service. The public repository validates code only; live deployment remains separate.

**Technologies:** PowerShell · Microsoft Graph · Azure Automation · Managed Identity · Blob Storage · Key Vault · GitHub Actions/OIDC

## How it fits together

```text
Ubuntu VM / VS Code → GitHub → GitHub Actions → Azure Automation
                                                    |
                                   +----------------+----------------+
                                   |                |                |
                              Blob Storage      Key Vault      Microsoft Graph
                               CSV input        Password        Entra users
```

GitHub Actions uploads and publishes code; it does not start the runbooks. Scheduled execution, additional Azure infrastructure, and Sentinel integration are future work.

## 1. Azure foundation

I created resource group `rg-AzureAutomation` and Automation account `Ant-Automation01` in East US 2.

![Automation account in the resource group](../Images/2026-09-25/automation-resource-group.png)

I configured `Ant_Powershell_7` with PowerShell 7.6. The initial screenshot shows Az and Azure CLI available while the custom packages were importing.

![Initial PowerShell runtime configuration](../Images/2026-09-25/initial-powershell-runtime.png)

The Automation managed identity was assigned Contributor at subscription scope and Storage Blob Data Contributor on `saantmgmt001`. These broad permissions reflect the lab setup, not a least-privilege target.

![Automation identity resource and storage roles](../Images/2026-09-25/automation-storage-roles.png)

I produced an Azure resource inventory CSV and stored it in `runbookdata/inventory/`.

![Inventory CSV stored in Blob Storage](../Images/2026-09-26/inventory-csv-output.png)

## 2. GitHub deployment

I initially connected GitHub through Azure Automation's built-in source control.

![Original built-in GitHub source control](../Images/2026-09-27/original-source-control.png)

**Issue and change:** Imported runbooks used PowerShell 5.1 instead of my custom runtime. I switched to GitHub Actions so deployment explicitly assigns the intended runtime and publishes the runbooks.

I created `github-azure-ops-deploy` for GitHub authentication, configured a federated credential, and assigned Automation Contributor on the Automation account. This deployment identity is separate from the managed identity used inside runbooks.

![GitHub deployment application](../Images/2026-09-27/github-deployment-app.png)

![Deployment identity assigned Automation Contributor](../Images/2026-09-27/deployment-automation-contributor.png)

The workflow reads the client, tenant, and subscription IDs from GitHub repository secrets. Authentication uses federation rather than a stored client password.

![GitHub Actions configuration secret names](../Images/2026-09-27/github-actions-secret-names.png)

The Azure login test succeeded. This screenshot verifies authentication; the later published runbook screenshot shows the custom runtime in use.

![Successful GitHub Actions Azure login](../Images/2026-09-27/github-azure-login-success.png)

## 3. Graph permissions and runtime fix

I assigned `User.ReadWrite.All` and `Group.ReadWrite.All` to the Automation managed identity for the lab's user and group operations.

![Graph application permissions assigned to Automation](../Images/2026-09-27/graph-permissions-assigned.png)

**Issue and change:** Even with permissions assigned, the runbook could not find `Connect-MgGraph`. Permissions did not install the required module. I added Microsoft.Graph.Authentication, Microsoft.Graph.Users, and Microsoft.Graph.Groups individually to the runtime.

![Connect-MgGraph command-not-found error](../Images/2026-09-27/graph-command-not-found.png)

![Individual Graph modules being imported](../Images/2026-09-28/graph-runtime-packages.png)

## 4. Cleaned up the lab tenant

I wrote user and group cleanup functions, protected my main user from deletion, and called both functions directly without runbook parameters. I used `-WhatIf` during preview testing.

The portal screenshots show the cleanup state before rebuilding: one user remained and zero groups were listed. They show directory state, not the cleanup job history.

![Main account remaining after cleanup](../Images/2026-09-28/remaining-user.png)

![No groups remaining after cleanup](../Images/2026-09-28/groups-cleared.png)

These cleanup scripts are for a disposable lab tenant, not production.

## 5. Recreated users from a CSV

I uploaded `fake-users-25.csv` to `saantmgmt001/runbookdata/inputs/`. The runbook downloads the file to its worker and imports the rows.

![CSV input stored in Blob Storage](../Images/2026-09-28/csv-blob-input.png)

I stored the temporary lab password as `EntraPW` in Key Vault, instead of embedding it in the runbook or CSV. This screenshot shows the secret name, not its value.

![Enabled EntraPW secret in Key Vault](../Images/2026-09-28/key-vault-secret-list.png)

**Issue and fix:** I assumed Contributor access to the vault allowed the Automation identity to read secrets. Contributor manages the resource, not secret values. I assigned **Key Vault Secrets User** at the vault scope.

![Automation managed identity granted secret access](../Images/2026-09-28/key-vault-secrets-user.png)

After that change, `creatingusersfromcsv` completed using `Ant_Powershell_7`.

![Published user-creation runbook and completed job](../Images/2026-09-28/user-creation-completed.png)

Entra then showed **26 users: 25 lab users plus my existing main account**.

![26 users after CSV-driven user creation](../Images/2026-09-28/created-users.png)

## 6. Department groups and membership

I grouped users by their Department property and created six assigned security groups: Boxing, Finance, HR, IT, Marketing, and Sales. These are ordinary assigned groups populated by a script, not Entra dynamic membership groups.

![Six assigned department security groups](../Images/2026-09-28/department-security-groups.png)

I then ran `Add-User-To-Groups` in Azure Automation to match each user's department to a group display name and add missing memberships. The script checks for blank departments, missing or ambiguous matches, dynamic groups, and existing members before adding users. It only adds memberships; it does not remove old department memberships.

The job completed on Azure with **zero errors and zero warnings**, and its output recorded the user-to-group additions.

![Completed membership runbook with user addition output](../Images/2026-09-28/group-membership-job-completed.png)

I checked direct user membership counts afterward:

| Group | User members |
|---|---:|
| HR | 5 |
| Sales | 6 |
| IT | 5 |
| Finance | 5 |
| Marketing | 4 |
| Boxing | 1 |
| **Total memberships** | **26** |

The retained sample CSV contains five users in each of IT, Sales, HR, Finance, and Marketing. The final count screenshot shows Sales at six and Marketing at four, plus the existing account in Boxing. The supplied evidence does not establish the intervening department or membership changes; the CSV is not an exact snapshot of that final directory state.

![PowerShell verification of department member counts](../Images/2026-09-28/department-member-counts.png)

## Entra automation milestone complete

This completes the current Entra Automation phase: deploy runbooks from GitHub, authenticate with managed identity, reset the lab, create users from a Blob Storage CSV with a Key Vault password, create department groups, and populate and verify memberships. The evidence shows 26 users, six assigned security groups, and a completed membership job. Scheduled execution is not part of this completed milestone.

## Code behind the project

The [Azure Automation code showcase](../showcase/README.md) contains sanitized copies of the actual private-repository runbooks and supporting scripts. It connects each script to the screenshots and records the original limitations. The copies were inspected, not executed, and the broad tenant-cleanup runbook is intentionally excluded.

| Cloud script | What I built |
|---|---|
| [CSV user creation](../showcase/runbooks/creatingusersfromcsv.ps1) | Managed identity, Blob CSV input, Key Vault password retrieval, and Entra user creation. |
| [Department group creation](../showcase/runbooks/create-groups-from-users.ps1) | Creates assigned security groups from nonblank user departments. |
| [Department membership](../showcase/runbooks/Add-User-To-Groups.ps1) | Matches departments to groups and adds missing memberships with validation and logging. |
| [Azure resource inventory](../showcase/runbooks/export-inventory.ps1) | Exports Azure resources to CSV and uploads the report to Blob Storage. |
| [Graph permission setup](../showcase/setup/auto-account-graph-permissions.ps1) | Assigns the managed identity's Graph application roles. |
| [Resource setup draft](../showcase/setup/ManageAzure.ps1) | Shows the interactive storage, Key Vault, and CSV-upload setup sequence. |
| [Membership verification](../showcase/verification/check-groups.ps1) | Counts direct user members across groups. |
| [Inactive deployment example](../showcase/deployment/deploy-runbooks.yml.example) | Shows OIDC authentication and custom-runtime publishing without activating another workflow. |

The earlier local files below show interactive learning scripts and reusable reporting code. They are not identical to the cloud runbooks: the local CSV script prompts for a password, while the cloud version uses managed identity, Blob Storage, and Key Vault.

| Local file | How it works |
|---|---|
| [CSV user creation](../scripts/creatinguserscsv.ps1) | Imports CSV rows, builds UPNs, compares them with existing users, and creates missing accounts with department, job title, usage location, and a password-change requirement. |
| [Disable a user](../scripts/disablinguser.ps1) | Looks up a username, checks AccountEnabled, and disables the account only if it is enabled. The domain is still a placeholder. |
| [Department group creation](../scripts/entragroupcreation.ps1) | Skips blank departments, looks for group names containing each department, and creates assigned security groups when no match is found. It does not populate membership. |
| [Inventory entry point](../scripts/Invoke-UserInventory.ps1) | Loads configuration, chooses delegated or certificate authentication, and writes a timestamped user inventory CSV. |
| [Reusable module](../src/EntraAutomationLab/EntraAutomationLab.psm1) | Separates configuration validation, Graph authentication, and inventory export into functions. |
| [Dependency setup](../scripts/Install-Dependencies.ps1) | Installs Microsoft.Graph for the local user. Azure runtime packages are configured separately. |
| [Unit tests](../tests/unit/EntraAutomationLab.Tests.ps1) | Eight checks cover configuration validation, module exports, PowerShell syntax, and the synthetic CSV fixture. These tests do not prove the cloud runbooks work. |

The local creation/group scripts are learning drafts, not production-ready runbooks. During public-repository cleanup, the CSV script was changed to require the CSV path and domain rather than overriding the domain, and an unsafe trailing deletion exercise was removed from the group script. The group script still does not refresh its group-name list after creation and uses partial matching. Prefer the cloud showcase when following the documented lab; its own limitations are listed separately. No directory-changing scripts were executed during this review.

## Skills demonstrated

- PowerShell user lifecycle scripts and CSV processing.
- GitHub-to-Azure runbook deployment with federated authentication.
- Separate deployment and runtime identities.
- Runtime module troubleshooting.
- Blob Storage input and Key Vault secret retrieval.
- The difference between resource management permissions and data access.
- Verification through job status and the resulting Entra user list.

## Local validation

Use PowerShell 7.4 or later. These checks do not require Azure credentials and do not execute the cloud runbooks:

```powershell
Install-Module Pester -RequiredVersion 5.7.1 -Scope CurrentUser -Force
Install-Module PSScriptAnalyzer -RequiredVersion 1.24.0 -Scope CurrentUser -Force
Invoke-Pester -Path ./tests -CI -Output Detailed
foreach ($path in './src', './scripts') {
    Invoke-ScriptAnalyzer -Path $path -Recurse -Severity Error -EnableExit
}
```

The [validation workflow](../.github/workflows/validate.yml) also parses all PowerShell files, including the showcase. Passing checks establish syntax and tested behavior only, not live Azure authorization or production readiness. Historical screenshots are the evidence for the original cloud executions.

## Supporting material and next steps

The [full screenshot gallery](screenshot-gallery.md) contains 26 distinct screenshots, including additional role assignments, upload output, and the initial federated-credential configuration. Historical screenshots are not necessarily the final configuration.

The active deployment workflow is maintained in the separate Azure-Ops-Automation repository; the showcase includes an inactive, sanitized example. This repository contains PowerShell scripts, synthetic sample data, module code, tests, and evidence—not Terraform state or infrastructure deployments.

Proxmox Terraform has been separated from this repository. The planned Azure infrastructure, monitoring, and Sentinel work will belong to a separate infrastructure/security project, linked here when available. Existing homelab context is documented in [Hybrid Homelab](https://github.com/Anthonydeangelis/hybridhomelab).

This Entra automation section is complete for now. Possible future work includes scheduled reporting, Azure infrastructure with Terraform, and Sentinel monitoring. These are planned, not completed.

Screenshot privacy: solid redactions cover the subscription ID, group object IDs, user principal names, personal account names, and selected local/GitHub identifiers. Lab resource names and synthetic user names remain for context. Redactions do not change the recorded results. No secret value is displayed in the supplied Key Vault screenshot.
