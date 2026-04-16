#!/usr/bin/env bash
echo "Starting deployment process..."
cd ..
echo "Changing directory to infra for Terraform operations..."
cd infra
echo "Initializing Terraform..."
terraform init
echo "Terraform initialized. Validating configuration..."
terraform validate

echo "Validation successful. Proceeding to plan."
terraform plan -out=tfdestroyplan

echo "Review the plan and apply if everything looks good."
terraform destroy -auto-approve tfdestroyplan
