# Google Cloud Terraform GitOps Demo (Stellar-Engine Aligned)

A production-grade, keyless GitOps reference implementation on Google Cloud using **GitHub Actions**, **Workload Identity Federation (WIF)**, and **Terraform**.

## 🌟 Architecture Highlights

* **Zero Console Write Access:** Developers interact solely via Pull Requests in GitHub; console access is restricted to View/Monitoring.
* **Keyless Authentication:** Zero stored service account JSON keys. Uses OIDC Workload Identity Federation with GCP STS.
* **Automated PR Reviews:** `terraform plan` output is automatically formatted and commented on every Pull Request.
* **Stellar-Engine-Aligned:** Deploys secure enclave resources (Uniform Bucket-Level Access, CMEK/versioning, VPC Flow Logs, Private Google Access, and workload identities).
* **Zero Residual Cost / Instant Teardown:** All demo resources are lightweight and can be destroyed cleanly via `./scripts/teardown.sh`.

## 📁 Repository Structure

```
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml      # CI: Runs plan & posts PR review comments
│       └── terraform-apply.yml     # CD: Runs apply on merge to main
├── bootstrap/                      # One-time WIF & GCS state backend setup
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── terraform/                      # Workload infrastructure definition
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── scripts/
│   └── teardown.sh                 # 100% clean teardown script
└── DEMO_SCRIPT.md                  # Executive demo playbook & presentation track
```

## 🚀 Getting Started

1. **Review the Presentation Track:**
   See [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) for step-by-step presentation notes and talking points for executive meetings.

2. **Clean Teardown:**
   ```bash
   ./scripts/teardown.sh
   ```
