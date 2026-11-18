# Instance Creation

Launches a single EC2 instance on AWS using Terraform.

## What it creates

| Resource | Details |
|---|---|
| `aws_instance.lab_03` | Debian 13, `t3.micro` (Free Tier eligible), region `ap-southeast-2` (Sydney), tagged `Name = Lab-03` |

## Files

| File | Purpose |
|---|---|
| `main.tf` | Terraform and provider configuration, and the EC2 instance |
| `monitoring.tf` | `enable_detailed_monitoring` variable that controls CloudWatch monitoring |
| `.terraform.lock.hcl` | Locks the AWS provider version |

## Inputs

| Variable | Type | Default | Description |
|---|---|---|---|
| `enable_detailed_monitoring` | `bool` | `false` | `true` = 1-minute detailed monitoring (may cost extra), `false` = free 5-minute basic monitoring |

## Usage

```bash
cd instance-creation

terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Enable detailed monitoring without editing code
terraform apply -var="enable_detailed_monitoring=true"

# Clean up when finished
terraform destroy
```

> The AMI ID is specific to `ap-southeast-2`. If you change the region,
> look up the matching Debian 13 AMI for that region.
