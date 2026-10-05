# Ubuntu development host

The Proxmox-hosted Ubuntu VM is the VS Code and PowerShell development environment. Azure Automation runs the cloud runbooks; GitHub-hosted runners validate this public repository. A self-hosted execution runner is not required.

The Proxmox Terraform checkout has been moved outside this repository. Its local state and real variable files remain private. See the [homelab project](https://github.com/Anthonydeangelis/hybridhomelab) for infrastructure context.

The helper at `scripts/bootstrap-ubuntu-runner.sh` installs PowerShell with sudo and launches it; despite its filename, it does not provision a VM or register a GitHub runner. Review before use.

The optional local inventory module supports delegated or certificate authentication. Copy `config/lab.example.json` to ignored `config/lab.json` and supply your own configuration. Keep certificates outside the checkout. These examples are separate from managed-identity cloud execution and do not demonstrate scheduled reporting.
