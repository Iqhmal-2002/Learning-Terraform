• Use OIDC (OpenID Connect) instead of static secrets: Configure GitHub Actions to authenticate to Azure (via Federated Credentials) and AWS (via IAM OIDC Identity Provider) without hardcoding long-lived access keys or client secrets. Mentioning OIDC in an interview is an instant green flag.
• Modularize your HCL: Put your Azure and AWS deployments into reusable Terraform modules (e.g., /modules/azure-network, /modules/aws-vpc) rather than dumping everything into one giant main.tf.
• Add a lightweight app or telco-style simulator: Deploy a small containerized C# or Python worker/API onto the infrastructure you spin up (like Azure Container Apps or AWS ECS) to show end-to-end application delivery.

---

## Added by Claude (2026-11-17), things to look into

### State hygiene (bootstrap phase)
• Enable blob versioning + soft delete on the tfstate storage account, so a corrupted/deleted state file is recoverable.
• Look up how state locking works for each backend: azurerm uses blob leases, HCP handles it for you. Know what happens when a lock gets stuck (`terraform force-unlock`).
• Commit `.terraform.lock.hcl`, never commit `*.tfstate`. Know why each.
• Decide where the bootstrap's own state lives (local / HCP / migrated into its own container) and write the reason in the README.

### Code quality
• Variables + `.tfvars` instead of hardcoded names/locations. Storage account names are globally unique, so think about how you generate them.
• Outputs from one config consumed by another: look into `terraform_remote_state` and the `tfe_outputs` data source (for HCP).
• Tagging: `default_tags` in the AWS provider; look for the Azure equivalent pattern.

### CI pipeline (GitHub Actions)
• On pull request: `terraform fmt -check`, `terraform validate`, `tflint`, and `terraform plan` (post plan output as a PR comment).
• On merge to main: `terraform apply`. This is where the OIDC idea above actually gets used.
• Security scan: look into `trivy config` (tfsec was merged into it) or `checkov`.
• For HCP workspaces: understand CLI-driven vs VCS-driven workflow and pick one deliberately.

### Cost control
• Budgets + alerts in both clouds (`azurerm_consumption_budget_*`, `aws_budgets_budget`).
• Habit: `terraform destroy` workload configs when not actively working on them. Bootstrap stays up (it's cheap).
• Optional: `infracost` in the PR pipeline to show cost diff per change.

### Presentation
• README with an architecture diagram and a short "decisions" section: why two backends, why OIDC, why these services.
• Optional: scheduled `terraform plan` in CI for drift detection.

### Rough 4-month phasing
1. Month 1: bootstrap done properly + first Azure workload config using the azurerm backend + first AWS config using HCP.
2. Month 2: refactor into modules, variables/outputs, tagging.
3. Month 3: GitHub Actions pipeline with OIDC to both clouds, linting + security scan.
4. Month 4: small app on top, budgets, README + diagram.
