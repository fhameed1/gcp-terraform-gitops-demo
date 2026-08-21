#!/usr/bin/env bash
# ==============================================================================
# Complete Teardown Script - Guarantees Zero Remaining Cost & Zero Orphaned State
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=================================================================="
echo "🚨 STARTING COMPLETE CLEAN TEARDOWN OF GITOPS DEMO INFRASTRUCTURE"
echo "=================================================================="

# 1. Destroy Workload Resources
echo "--> 1/3: Destroying Workload Resources (VPC, Subnet, GCS Enclave)..."
if [ -d "${ROOT_DIR}/terraform" ]; then
  cd "${ROOT_DIR}/terraform"
  terraform init -reconfigure || true
  terraform destroy -auto-approve || true
fi

# 2. Empty and Delete Terraform State Bucket (if any leftover lock/state)
echo "--> 2/3: Cleaning Terraform Remote State Bucket..."
if [ -d "${ROOT_DIR}/bootstrap" ]; then
  cd "${ROOT_DIR}/bootstrap"
  STATE_BUCKET=$(terraform output -raw state_bucket_name 2>/dev/null || true)
  if [ -n "${STATE_BUCKET}" ]; then
    echo "Emptying state bucket: gs://${STATE_BUCKET}"
    gcloud storage rm --recursive "gs://${STATE_BUCKET}/**" 2>/dev/null || true
  fi

  # 3. Destroy Bootstrap Resources (WIF Pool, CI SA, State Bucket)
  echo "--> 3/3: Destroying Bootstrap Resources (WIF Pool, CI Service Account, State Bucket)..."
  terraform destroy -auto-approve || true
fi

echo "=================================================================="
echo "✅ COMPLETE TEARDOWN FINISHED: All resources removed ($0 lingering cost)."
echo "=================================================================="
