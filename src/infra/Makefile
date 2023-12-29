.PHONY: plan apply destroy

apply:
	/home/gary/.local/bin/terraform apply

plan:
	/home/gary/.local/bin/terraform plan

destroy:
	/home/gary/.local/bin/terraform destroy

terraform.tfvars:
	@echo 'billing_account="$(GCP_BILLING_ACCOUNT)"' > terraform.tfvars
	@echo 'parent_folder="$(GCP_FOLDER_ID)"' >> terraform.tfvars
