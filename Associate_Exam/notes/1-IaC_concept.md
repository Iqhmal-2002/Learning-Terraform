### What is IaC?

# Problem with manual
Easy to misconfigure

# IaC
Automate creating, updating and destroying
Share, version or inventory

# Popular IaC
Declarative - What you see is what you get (Explicit)
Use scripting language

Declarative (Explicit)
ARM
Azure Blueprint
Cloudformation
Cloud Deployment Manager
Terraform

Imperative (Implicit)
Less verbose than Declarative, but can do more than Declarative
Use programming language like python, ruby, javascript

AWS Cloud Development Kit (CDK)
Pulumi (AWS,  Azure, GCP, K8)

# Declarative+
Terraform is Declarative with Imperative feature
Terraform has loops, dynamic block, locals, complete data structure (maps, collections)

# Infrastructure Lifecycle
A number of clearly defined and distinct work phasesused by DevOps to plan, design, build, test, deliver, aintain and retire cloud infrastructure
Day 0, Day 1, Day 2
 
Day 0 - plan and design
Day 1 - Develope and Iterate
Day 2 - Go live and maintain

# Infrastructure Lifecycle Advantages
Reliability
IaC make changes idempotent, consistent, repeatable and predictable
Idempotent - No matter how many times you run, will always end up with the same state

Manageability
enable mutation via code
revised with minimal changes

Sensibility
Avoid financial and reputational loss of life when considering government and military dependencies on infrastructure

# Non-Idempotent vs Idempotent
Non-idempotent
Deploy config, make 2 vm, rerun the script and it will spin another 2 vm for 4 vm total

Idempotent
Spin 2 vm, edit and rerun, still on 2 vm with changes (might get destroyed and recreated)

# Provisioning, deployment vs Orchestration
Provisioning
- Prepare server with system, data and software for network operation
- Using configuration management tools like puppet, ansible, chef scrpts, powershell or cloud-init
Launch cloud service and configure it - provisioning

Deployment
Deliveriing a version of application to a provisioned server
Could be performed via AWS codepipeline, harness, github actions, circleci

Orchestration
Coordinating muktiple systems or services
Common terms when working with microservices, containers and kubernetes
Cou;d be kubernetes, salt, fabric

# Configuration drift
Unexpected change
manual adjustment of configurations
malicious actors
side affects from API, SDK, CLI

How to detect drift?
Compliance tool to detect misconfiguration: AWS Config, Azure Policies, GCP Security Health Analytics
Built in support for drift detection: AWS CloudFormation Drift Detection
Store the expected state

How to correct configuration drift?
Compliance tool can remediate misconfiguration (AWS Config)
Terrafor refresh and plan commands
Manually correction configuration (not recommended)
taking down and setting up infrastructure again

How to prevent drift?
Immutable infrastructurem always create and destroy, never reuse, Blue, Green deployment strategy
Servers are never modified after they are deployed
Baking AMI images or containers via AWS Builder or Hashicorp Packer, build server - GCP Cloud Run
Using GitOps to version control IaC, peer review every single pull request to change infrastructure

# Mutable vs Immutable Infrastructure
Mutable
Develop -> Deploy -> Configure (Cloud-init)

Immutable
Develop -> Configure (Packer) -> Deploy

In immutable, you bake an image for the deployment to refer to, instead of deploying first and then configuring it

# What is GitOps
Take IaC, use git repository for a formal process to review and accept changes to infrastructure code once accpeted and automatically trigger a deploy

# Immutable Infrastructure Guarantee
What happens if a physical hardware failure?
What if post installation script fails due to change in package?
What if I need to deploy ASAP?
Worse case scenarios:
- Accidental deletion
Compromised by malicious actor
Need to change regions
No guarentee of 1-to-1
Every time cloud init runs post deploy there could be changes due to update

Golden images:
Guarentee 1-to-1
Increased assurance of concistency and security (since 1-to-1)
Speeds up deployment (since 1-to-1)