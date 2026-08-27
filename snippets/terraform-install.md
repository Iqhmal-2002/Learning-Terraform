# Install Terraform on Windows
choco install terraform

# Azure CLI Install
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# Azure CLI login
az login

# Check Acc
az account show

# If you don't see subscription output, list them explicitly
az account list --output table

# Set the right subscription
az account set --subscription "<your-subscription-id>"

# Create the service principal (same as before, still works)
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"

# Set variable
$Env:ARM_CLIENT_ID = "<APPID_VALUE>"
$Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
$Env:ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
$Env:ARM_TENANT_ID = "<TENANT_VALUE>"

# Initialize Terraform using the main.tf
terraform init

# Format config file
terraform fmt

# Validate terraform
terraform validate

# Apply terraform
terraform apply

# Inspect current state
terraform show

# Review state
terraform state list

# Helpful command
terraform state

# Delete
terraform delete