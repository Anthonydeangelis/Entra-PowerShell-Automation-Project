# Project milestones

The [illustrated walkthrough](lab-walkthrough.md) contains the detailed evidence; the [README](../README.md) provides the project overview. This summary records completed work, not a deployment checklist.

## Development and Azure foundation

Used an Ubuntu VM and VS Code for PowerShell development. Created an Automation account, configured a custom runtime, assigned managed identity permissions, and exported Azure resource inventory to Blob Storage.

## Deployment and troubleshooting

Switched from built-in source control to GitHub Actions to explicitly select the custom runtime. Kept deployment and runtime identities separate. Added individual Graph modules after a command-not-found error and granted Key Vault Secrets User when Contributor did not allow secret-value access.

## Entra workflow

Reset the disposable lab directory, uploaded synthetic users to Blob Storage, and retrieved the temporary password from Key Vault. The completed creation job was followed by a directory containing 26 users. Created six assigned department groups and ran the membership runbook. Its captured job shows zero errors and warnings; the count report records 26 direct user memberships.

## Public showcase

Added sanitized cloud scripts and an inactive deployment example. Excluded tenant-wide deletion. Separated Proxmox Terraform, consolidated CSV fixtures under data/, and removed an unsafe deletion exercise from an earlier learning script.

## Future work

Scheduled execution, new Azure Terraform infrastructure, and Sentinel detection and response remain future work. Infrastructure and security will have a separate project. Screenshot results describe the original lab, not execution of the sanitized copies.
