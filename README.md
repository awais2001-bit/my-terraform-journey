# My Terraform Journey

Hands-on labs from learning Terraform with AWS. Each folder is a self-contained
Terraform project with its own README.

| Folder | What it does |
|---|---|
| [instance-creation](instance-creation/) | Launches a Debian 13 EC2 instance with configurable CloudWatch monitoring |
| [security-groups](security-groups/) | Launches an EC2 instance protected by security groups for SSH, HTTPS and outbound traffic |
| [ssh-aws-config](ssh-aws-config/) | Launches an EC2 instance with your own SSH key pair, security groups and outputs, ready to SSH into |
| [cloud-init](cloud-init/) | Uses cloud-init `user_data` to automatically install Apache and publish a MkDocs site on first boot |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.14.2
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), authenticated (for example with `aws login`)

## Notes

- State files (`*.tfstate`), plan files and `*.tfvars` are excluded via `.gitignore`.
  They can contain sensitive data and should never be committed to a public repository.
- Always run `terraform destroy` when you are done with a lab to avoid charges.
