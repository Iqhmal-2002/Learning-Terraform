# Terraform Lifecycle
1) Write or update configuration file
2) init
3) plan
4) validate
5) apply -> destroy (branch)

# Change Automation
Change management - standarad approach to apply change, resolving conflicts brought about by change. 
In IaC, change management is procedure that will be followed when resources are modified and applied via configuration script

Change automation - a way of automatically creating a consistent, systematic and predictable way of manageing change request vie controls and policies

Terraform ue change automation in the form of execution plans and resource graphs to apply and review complex changesets

ChangeSet - a collection of commit that represents changes made to a versioning history. IaC uses ChangeSet so you can se what has changed by who over time
This helps avoid many possible human errors

Execution plan
manual review of what will be added, changed ir destroyed before applying the changes using terraform apply

Visualizing Execution Plan
- Can see the graph by using terraform graph command. Will output a GraphViz file

# Resource Graph
Resource node
Resource meta node
Provider configuration node
Point is so that things are done in order because declarative only specify the end result, and this is how it builds towards that result

# Use Cases
1) IaC for Exotic Providers
- Open source so any API can be used
2) Multi tier applications
- Easy to divide large and complex applications into isolate scripts (modules)
3) Disposable Environment
- Easily standup an environment for software demo or temporary development environment
4) Resource schedulers 
- Can be used to dynamic schedule docker containers, hadoop, spart and other software tools
5) multi cloud deployment 
- Cloud agnostic and allow single configuration to be used to manage multiple providers

# Terraform Core and Plugins
Terraform Core - use remote procedure calls (RPC) to communicate with Terraform Plugins
Terraform Plugins - Expose an implementation for a specific service or provisioner

# Book
Terraform Up and Running - if you ever need extra resource (Probably never)

# Terraform Best Practice
https://www.terraform-best-practices.com/

This is just good practice to know about 

# Terraform Install
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform

One of the options that I chose was using chocolatey on windows

# Where to find code stuff?
Terraform Registry is your blood