## Provisioner

Terraform Provisioners install software, edit files, and provision machines created with Terraform

Terraform's built-in provisioners are: local-exec, remote-exec, file  (last resort)

Preferred alternatives (not part of Terraform):
- Packer: Bake images before VM is created 
- cloud-init: uses native linux tooling at first boot, inside the VM

Terraform Provisioners are not tracked at all in the state file. Terraform passes user_data to the VM, from which the cloud-init uses when it runs on boot. State file records the user_data it passed, cloud-init returns nothing to terraform

Cloud-init is the industry standard for cross-platform cloud instance initializations. When launching a VM on a Cloud Service Provider (CSP) you'll provide a YAML or Bash script

Packer is an automated image-builder service. You provide a configuration file to create and provision the machine image and the image is delivered to the repository for use.

Provisioners is the last resort because provisioners will do something that wont be reflected in the terraform state file. Better alternative would be to use cloud-provider features like cloudinit scripts.

If something is not tracked in the terraform state, drift is more likely to happen

Terraform support for third party Provisioning tools like Chef, puppet and Saltstack was deprecated because using provisioners is already poor practice.

However, Cloud-Init does support Chef and Puppet 

## Local Exec
Execute local commands after a resource is provisioned - on the machine that runs terraform apply

Output vs Local Exec
Output will show the output results after running terraform apply

Local exec allows you to run any commands on the local machine. Commonly used to trigger Configuration Management (Ansible, Chef, Puppet)

## Local-exec details
Command (Required)
- Command to execute

working_dir
Where the command will be executed

interpreter
Entry point of the command - the local program that will run the command (Bash, Ruby, AWS CLI, PowerShell)

Environment
Key and value pair of environments variables

## Remote-exec
Execute command on target resource after a resource is provisioned (probably the VM you create)
Useful for simple stuff, but realistically production is never simple so its not really preferred, use cloud-init instead

Inline - list of command string

Script/Scripts - relative or absolute local script(s) that will be copied to the remote resource then executed in order

## File Provisioner
Source - local file we want to upload

Content - a file or folder

Destination - Where to upload the file on the remote machine

## Connection 
A connection block tells provisioner or resource how to establish a connection

ssh can connect through Bastion host

## Null resources
Placeholder for resources that have no association to provider resources

Triggers is a map of values that will cause provisioners to rerun