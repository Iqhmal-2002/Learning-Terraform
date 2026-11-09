az group create --name rg-tfstate --location westus2

az storage account create --name sttfstate_iqhmal_nov_2026 --resource-group rg-tfstate --location westus2 --sku Standard_LRS --allow-blob-public-access false

az storage container-rm create --storage-account sttfstate_iqhmal_nov_2026 --resource-group rg-tfstate --name tfstate
