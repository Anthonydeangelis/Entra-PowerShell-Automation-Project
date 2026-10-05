# Project decisions and fixes

## GitHub Actions for runbook deployment

I initially used Azure Automation's built-in GitHub source control. It imported the runbooks using PowerShell 5.1 instead of my custom runtime. I switched to GitHub Actions so deployment explicitly assigns the intended runtime and publishes the runbooks.

## Microsoft Graph in the runtime

I added Microsoft.Graph to the custom runtime so my runbooks could manage Entra users and groups. However, Connect-MgGraph still wasn't recognized, and testing showed Microsoft.Graph.Authentication wasn't available in the executing runtime.

I added Microsoft.Graph.Authentication, Microsoft.Graph.Users, and Microsoft.Graph.Groups individually. The package screenshot captures them importing. Later screenshots show the intended cleanup result: my main user remains and no groups are listed. The screenshots do not include the runbook job result.

## Key Vault secret access

I gave the Automation managed identity Contributor access to the vault, but the runbook could not read the password. Contributor manages the resource, not the secret values. I assigned Key Vault Secrets User at the vault scope. The user-creation runbook then completed, and Entra showed 26 users: my main account plus 25 lab users.
