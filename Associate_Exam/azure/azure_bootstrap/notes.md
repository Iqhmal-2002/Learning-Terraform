# This is my notes on things I used and can be referenced for the readme later

How the Terraform Resources Map Together

• azurerm_storage_account (The Service Account): This creates the overarching Azure Storage Account. Think of this as the main server or account that holds your billing, region, and security settings. It can actually host multiple services (Blobs, File Shares, Queues, and Tables).
• azurerm_storage_container (The Blob Folder): This resource specifically belongs to the Blob Storage service inside that account. It creates a top-level bucket or directory to group your files and control permissions (like whether the files inside are public or private).
• azurerm_storage_blob (The Actual File): This represents a single file (like an image, PDF, or zip file) that you are uploading into that specific container via Terraform.
