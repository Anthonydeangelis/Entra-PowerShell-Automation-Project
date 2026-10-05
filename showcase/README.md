# Code from the Azure Automation lab

These are sanitized snapshots of the scripts inspected in my private Azure Automation repository, including supporting working-tree scripts. They document how I built the lab; they are not newly tested production templates. Resource names, the tenant domain, subscription ID, and managed identity object ID have been replaced with placeholders. The well-known Microsoft Graph application ID is intentionally unchanged.

No scripts were executed during this documentation update. Copies preserve the original behavior and limitations; the private source files were not changed. Replace placeholders and review permissions and scope before using any script. Most of these files make real changes and do not use `-WhatIf`.

## Runbooks and evidence

| Script | What it demonstrates | Screenshot evidence |
|---|---|---|
| [Create users from CSV](runbooks/creatingusersfromcsv.ps1) | Authenticates to Azure and Graph with managed identity, retrieves the temporary password from Key Vault, downloads the Blob CSV, skips existing UPNs, and creates users requiring a password change. | [Completed job](../Images/2026-09-28/user-creation-completed.png), [26 users](../Images/2026-09-28/created-users.png) |
| [Create department groups](runbooks/create-groups-from-users.ps1) | Groups users by Department and creates mail-disabled security groups, skipping blank departments. | [Six assigned groups](../Images/2026-09-28/department-security-groups.png) |
| [Add users to groups](runbooks/Add-User-To-Groups.ps1) | Escapes filter apostrophes, requires exactly one matching group, skips dynamic groups and existing memberships, and logs additions. | [Completed membership job](../Images/2026-09-28/group-membership-job-completed.png) |
| [Export Azure inventory](runbooks/export-inventory.ps1) | Selects a subscription, exports resource details to a temporary CSV, uploads to Blob Storage, and removes the temporary local file. | [Inventory blob](../Images/2026-09-26/inventory-csv-output.png) |

The membership script is add-only: changing a user's department does not remove their old membership. The group-creation script does not check for existing groups, so reruns can create duplicates; it also uses the department directly as the mail nickname. The CSV script uses one shared temporary lab password and stops on a user-creation error; it does not remove its downloaded temporary CSV.

The inventory script's comment says it creates a missing container, but the code only queries for it. The container must already exist. Screenshot success documents the original lab run, not execution of these placeholder copies.

## Supporting scripts

- [Graph permission setup](setup/auto-account-graph-permissions.ps1): assigns `User.ReadWrite.All` and `Group.ReadWrite.All` application roles to the Automation managed identity and skips existing assignments. This is privileged, one-time administrator setup, not a runbook. It assumes an already authenticated Graph session with authority to grant those roles. It does not grant Azure RBAC roles or install modules. [Assignment evidence](../Images/2026-09-27/graph-permissions-assigned.png).
- [Resource setup notes](setup/ManageAzure.ps1): preserves the interactive sequence for creating storage, a container, and Key Vault, then uploading the CSV. This is a working draft, not an idempotent infrastructure deployment. It assumes an existing resource group and Automation account; the storage role assignment is commented out, the CSV path is private-repo-relative, and the storage location string needs review. It does not create the Key Vault secret or grant secret access.
- [Check group counts](verification/check-groups.ps1): reads direct user members of every group and returns `GroupName` and `MemberCount`. It assumes an authenticated Graph session. It excludes nested-group expansion and non-user members. [Count evidence](../Images/2026-09-28/department-member-counts.png).
- [Deployment workflow example](deployment/deploy-runbooks.yml.example): preserves the private repo's OIDC login, syntax validation, explicit runtime selection, upload, publish, and verification steps. It is deliberately outside `.github/workflows` and has an `.example` extension, so this copy does not activate deployment. It expects a root `runbooks/` directory in the deployment repository; these showcase files are nested here. It publishes all runbooks in that directory, not just changed ones, and never starts jobs or deletes runbooks. Publishing can affect future scheduled executions. Configure the three Azure ID secrets, federated identity, target placeholders, runtime, and scoped deployment role before adapting it.

## Identities used in the lab

| Identity | Recorded access | Purpose |
|---|---|---|
| GitHub deployment service principal | Automation Contributor on the Automation account; OIDC federation | Upload and publish runbooks |
| Automation managed identity | Subscription Contributor; Storage Blob Data Contributor on storage; Key Vault Secrets User on the vault | Azure resource inventory, Blob access, and secret retrieval |
| Automation managed identity | Graph application roles `User.ReadWrite.All`, `Group.ReadWrite.All` | User and group operations |
| Human operator | Storage Blob Data Owner shown in the role screenshot | Interactive storage work; the cropped screenshot does not establish the exact resource scope |

These are the recorded lab grants, not a minimum-permission recommendation. Deployment identity and runtime identity are separate. Runtime Graph/Az modules must also be available; permissions alone do not install cmdlets.

The tenant-wide deletion runbook is intentionally excluded from this showcase. Earlier local learning drafts elsewhere in the repository have minor publication-safety fixes documented in the main README; they should not be mistaken for these cloud runbooks.
