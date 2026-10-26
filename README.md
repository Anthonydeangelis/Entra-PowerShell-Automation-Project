# Entra ID + Azure Automation Lab

I built a PowerShell workflow to create Microsoft Entra ID users from a CSV and place them into department security groups. I developed the scripts in VS Code on Ubuntu, deployed runbooks through GitHub Actions, and used an Azure Automation managed identity to access Microsoft Graph, Blob Storage, and Key Vault.

**Recorded outcome:** 25 lab users created, six department groups populated, and 26 direct user memberships verified, including my existing account. The captured membership job completed with zero errors and zero warnings.

**Technologies:** PowerShell · Microsoft Graph · Azure Automation · Managed Identity · Azure RBAC · Blob Storage · Key Vault · GitHub Actions · OIDC

[Code and permissions](showcase/README.md) · [Illustrated walkthrough](docs/lab-walkthrough.md) · [Screenshot gallery](docs/screenshot-gallery.md) · [Safety and limitations](docs/safety.md)

## What this demonstrates

| Skill | Implementation and evidence |
|---|---|
| Identity administration | [CSV provisioning](showcase/runbooks/creatingusersfromcsv.ps1) creates users with profile attributes and requires a password change at first sign-in. |
| PowerShell automation | [Department membership](showcase/runbooks/Add-User-To-Groups.ps1) checks blank departments, ambiguous group matches, dynamic groups, and existing memberships before adding users. |
| Authentication and permissions | Separate deployment and runtime identities; [documented Azure RBAC and Graph application grants](showcase/README.md#identities-used-in-the-lab). |
| Azure service integration | Runbooks read a CSV from Blob Storage, retrieve a temporary password from Key Vault, and [export resource inventory](showcase/runbooks/export-inventory.ps1) back to storage. |
| Deployment automation | [Sanitized workflow example](showcase/deployment/deploy-runbooks.yml.example) uses GitHub OIDC and explicitly assigns the custom PowerShell runtime before publishing. |
| Troubleshooting and verification | [Documented fixes](docs/troubleshooting-lessons.md) for runtime selection, missing Graph modules, and Key Vault access; job output and [member counts](showcase/verification/check-groups.ps1) verify results. |

## Architecture

```text
VS Code / Ubuntu → Private GitHub deployment repository
                              |
                     GitHub Actions + OIDC
                              |
                    Publish to Azure Automation
                              |
                Runbooks use managed identity
                 /            |              \
          Blob Storage     Key Vault     Microsoft Graph
           CSV input       Password      Users and groups
           CSV reports
```

The deployment service principal has Automation Contributor on the Automation account. The runbook managed identity has separate Azure roles and Graph application permissions. Uploading and publishing a runbook does not start it.

This portfolio repository has a validation-only workflow. The deployment example is inactive, and live deployment remains in a separate private repository.

## Results

The original lab evidence shows:

- A completed user-creation runbook and **26 directory users**: 25 synthetic users plus my existing account.
- **Six assigned security groups**: HR, Sales, IT, Finance, Marketing, and Boxing.
- A completed membership job with **zero errors and zero warnings**.
- **26 direct user memberships** in the final count report.

![Verified direct user membership counts](Images/2026-09-28/department-member-counts.png)

[Completed user-creation job](Images/2026-09-28/user-creation-completed.png) · [Created users](Images/2026-09-28/created-users.png) · [Department groups](Images/2026-09-28/department-security-groups.png) · [Membership job output](Images/2026-09-28/group-membership-job-completed.png)

The retained CSV has five users per department across five departments. The final screenshot shows a different Sales/Marketing split and the existing account in Boxing. These are evidence from different stages, not an exact replay fixture; the intervening changes are not captured. See the [data notes](data/README.md).

## Problems I worked through

1. **Runtime selection:** built-in source control imported runbooks using PowerShell 5.1. I switched to a GitHub Actions workflow that explicitly selects the custom runtime.
2. **Missing Graph cmdlets:** assigned permissions did not make `Connect-MgGraph` available. I added the individual Authentication, Users, and Groups modules to the runtime.
3. **Key Vault access:** Contributor access did not permit reading secret values. I assigned Key Vault Secrets User to the Automation identity at the vault scope.

The [walkthrough](docs/lab-walkthrough.md) preserves the setup, failures, fixes, and screenshots.

## Repository guide

- [showcase/](showcase/README.md): sanitized cloud runbooks, permission setup, membership verification, and the inactive deployment workflow.
- [scripts/](scripts/): earlier interactive learning scripts and the local inventory entry point.
- [src/EntraAutomationLab/](src/EntraAutomationLab/): reusable configuration, authentication, and inventory functions.
- [tests/unit/](tests/unit/): eight Pester checks for configuration validation, module exports, PowerShell syntax, and synthetic input.
- [data/](data/README.md): fictional practice datasets; no passwords or employee exports.
- [docs/](docs/): walkthrough, troubleshooting, safety notes, and supporting evidence.

## Validation

From the repository root, use PowerShell 7.4 or later:

```powershell
Install-Module Pester -RequiredVersion 5.7.1 -Scope CurrentUser -Force
Install-Module PSScriptAnalyzer -RequiredVersion 1.24.0 -Scope CurrentUser -Force
Invoke-Pester -Path ./tests -CI -Output Detailed
foreach ($path in './src', './scripts') {
    Invoke-ScriptAnalyzer -Path $path -Recurse -Severity Error -EnableExit
}
```

The [GitHub validation workflow](.github/workflows/validate.yml) also parses all PowerShell files, including the showcase, without executing the runbooks. It needs no Azure credentials. Tests cover the listed local behavior, not end-to-end provisioning or live permissions.

## Scope and limitations

This is a completed hands-on learning lab. The public code preserves the implementation and its limitations:

- The lab used broad permissions, including subscription Contributor; it is not a least-privilege reference deployment.
- Group creation can create duplicates on reruns. Membership processing adds missing users but does not remove old department memberships.
- Provisioning used a shared temporary lab password from Key Vault with a first-sign-in password change. Per-user password generation and secure delivery are future improvements.
- Sanitized scripts contain placeholders and have not been rerun against Azure. Review each script before adapting it; several make real directory changes.
- The tenant-wide deletion runbook is excluded. Scheduled execution, Azure Terraform infrastructure, and Sentinel integration are not completed features.

Screenshots retain lab resource names and synthetic users; sensitive identifiers have been redacted. Read the [safety notes](docs/safety.md) and [publication review](docs/publication-review.md) for the review boundaries.

## Related work

The [Hybrid Homelab](https://github.com/Anthonydeangelis/hybridhomelab) provides the development-environment context. Proxmox Terraform is maintained separately. Planned Azure infrastructure and Sentinel work will have its own infrastructure/security project.
