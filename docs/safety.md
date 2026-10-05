# Safe usage and publication

This is a learning portfolio, not a production deployment kit. Read the [showcase limitations](../showcase/README.md) before adapting scripts. Creating users, assigning roles, disabling users, and changing memberships are real operations. Use a disposable test tenant and review scope, permissions, and costs.

## Public content

- Never commit real configuration, passwords, tokens, certificates, Terraform state, plans, or real variable files. Ignore rules do not replace reviewing staged content.
- The data folder contains synthetic lab fixtures. Do not replace them with real employee exports.
- Screenshot redactions cover the visible subscription ID, group object IDs, user principal names, personal account names, and selected local/GitHub identifiers. Lab tenant/resource names, synthetic users, and secret names remain for context, so these are not completely anonymous images. Originals are kept outside this repository. Redacted pixels were permanently replaced and edited PNG metadata was removed; results and unmasked pixels were preserved.
- Key Vault and GitHub settings screenshots show secret names, not values.
- Revoke or rotate any credential accidentally exposed; deleting a file alone does not erase Git history.

## Validation boundaries

The validation workflow parses PowerShell without executing runbooks, checks reusable code for analyzer errors, and runs eight Pester tests. It does not authenticate to Azure or deploy anything. Tests cover configuration loading, module exports, syntax, and the synthetic CSV fixture, not end-to-end cloud operations. The optional local certificate-login script prompts securely for its password rather than reading a plaintext environment variable.

Cloud scripts are sanitized snapshots of the private deployment repository, not a second deployment source. The workflow example is inactive. The broad tenant-deletion runbook is excluded.
