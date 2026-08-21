# 🚀 GCP GitOps Executive Demo Playbook
**Audience:** Director of Cloud / Cloud Leadership  
**Objective:** Demonstrate the operational shift from risky manual "ClickOps" to automated, auditable, keyless GitOps on Google Cloud with zero Console write access.

---

## 🎯 Executive Narrative & Value Proposition

| Old World (ClickOps & Console Access) | New World (Terraform GitOps on GCP) |
| :--- | :--- |
| Engineers make direct edits in GCP Console | **Console is Read-Only** (monitoring/observability only) |
| Configuration drift & unreviewed security risks | **Git is the Single Source of Truth** |
| Long-lived credentials / risky service account keys | **Keyless OIDC via Workload Identity Federation (WIF)** |
| "Who changed that firewall rule?" (Audit mysteries) | **Every infrastructure change is tied to a Pull Request & Commit SHA** |
| Bespoke manual deployments | **Automated peer review + Stellar-Engine-aligned blueprints** |

---

## 🎬 Step-by-Step Live Demo Track (15 Minutes)

### Act 1: The Guardrail — Showing Console Read-Only (2 Mins)
1. Open the [Google Cloud Console](https://console.cloud.google.com).
2. Switch to a standard developer/operator account (assigned `Viewer` / `Monitoring Viewer`).
3. Attempt to manually create a Cloud Storage Bucket or edit a VPC Subnet.
4. **The "Aha!" Moment:** Show the **`403 Permission Denied`** error in the console.
5. **Talking Point:** 
   > *"In our target architecture, we remove human write permissions from the cloud console entirely. This eliminates 95% of human error, accidental outages, and untracked drift."*

---

### Act 2: The Developer Flow — Opening a Pull Request (4 Mins)
1. The developer wants to deploy a new **Stellar-Engine-compliant Workload Enclave** (Encrypted Storage + Flow-Logged VPC Subnet + Least-Privilege Identity).
2. Show the GitHub repository (`fhameed1/gcp-terraform-gitops-demo`).
3. Create a new branch:
   ```bash
   git checkout -b feature/secure-workload-enclave
   ```
4. Push the branch and open a **Pull Request** into `main`.
5. **Talking Point:**
   > *"Developers don't need GCP console write permissions or cloud IAM credentials. They work entirely inside GitHub using standard pull request workflows."*

---

### Act 3: Automated Review & Keyless Verification (4 Mins)
1. Watch GitHub Actions trigger automatically on the PR.
2. Highlight the authentication step: **Keyless Workload Identity Federation (WIF)**.
   * *Talking Point:* *"Notice we have zero static GCP service account keys or JSON secrets stored in GitHub. GitHub exchanges a short-lived OIDC token with Google Cloud STS."*
3. Refresh the Pull Request after ~30 seconds:
   * Show the automated bot comment posted directly on the PR showing the **Terraform Plan**.
   * Expand the `<details>` block to review the 6 resources being added.
4. **Talking Point:**
   > *"Peer review becomes your change management board. Every team lead can inspect the exact plan before any code touches the cloud environment."*

---

### Act 4: Merge & Deployment (3 Mins)
1. Click **"Merge pull request"** and confirm the merge to `main`.
2. Go to the **Actions** tab in GitHub: observe the `Terraform Apply` workflow running.
3. Once completed (~30s), switch back to the **Google Cloud Console**:
   * Open **Cloud Storage** -> See `enclave-data-dev-...` created with compliance labels (`blueprint = stellar-engine`).
   * Open **VPC Networks** -> See `vpc-enclave-dev-...` and `sb-enclave-us-central1-dev` with flow logs active.
4. Open **Cloud Logging / Audit Logs**:
   * Filter for: `protoPayload.authenticationInfo.principalEmail="sa-terraform-cicd@vigilant-cider-502720-m5.iam.gserviceaccount.com"`
   * Show that all resources were created solely by the CI Service Account with immutable audit logs.
5. **Talking Point:**
   > *"We achieved complete deployment velocity without a single engineer logging in with admin rights."*

---

### Act 5: Clean Teardown Guarantee (2 Mins)
1. Run the automated teardown script from your terminal:
   ```bash
   ./scripts/teardown.sh
   ```
2. Explain to the Director:
   * All demo resources (VPCs, buckets, service accounts) are instantly destroyed.
   * **Result:** $0 lingering cost and zero orphaned cloud state.

---

## 🛠️ Repository Quick Reference

* **Workload Configuration:** [`terraform/main.tf`](terraform/main.tf)
* **GitHub Actions Workflows:**
  * PR Validation: [`.github/workflows/terraform-plan.yml`](.github/workflows/terraform-plan.yml)
  * Prod Apply: [`.github/workflows/terraform-apply.yml`](.github/workflows/terraform-apply.yml)
* **One-Click Teardown:** [`scripts/teardown.sh`](scripts/teardown.sh)
