# Security Groups

Launches an EC2 instance and attaches security groups (virtual firewalls) that
control which traffic can reach it and where it can connect to.

## What it creates

| Resource | Details |
|---|---|
| `aws_instance.security_group` | Debian 13, `t3.micro`, region `ap-southeast-2` (Sydney), tagged `Name = Security-Group-Instance` |
| `aws_security_group.allow_ssh` | Security group for SSH access |
| `aws_vpc_security_group_ingress_rule.allow_ssh_ipv4` | Inbound TCP port **22** (SSH) |
| `aws_security_group.allow_tls` | Security group for HTTPS access |
| `aws_vpc_security_group_ingress_rule.allow_tls_ipv4` | Inbound TCP port **443** (HTTPS / TLS) from anywhere |
| `aws_security_group.egress` | Allows all outbound traffic (IPv4 and IPv6) |

## Traffic rules

| Direction | Port | Protocol | Source / destination | Purpose |
|---|---|---|---|---|
| Inbound | 22 | TCP | `0.0.0.0/0` | SSH (remote terminal access) |
| Inbound | 443 | TCP | `0.0.0.0/0` | HTTPS (encrypted web traffic) |
| Outbound | All | All | `0.0.0.0/0`, `::/0` | Package updates, DNS, API calls |

Port 80 (plain HTTP) is not opened, so `http://` requests are blocked.

## Key concepts

- **Security groups only allow traffic.** Anything not explicitly allowed is blocked.
- **They are stateful.** Replies to allowed traffic are automatically permitted.
- **Terraform removes AWS's default "allow all outbound" rule**, so outbound
  access must be defined explicitly (the `egress` group).
- **`vpc_security_group_ids`** attaches several groups to one instance; their rules combine.
- **CIDR notation:** `0.0.0.0/0` means every IPv4 address, `x.x.x.x/32` means exactly one address.

## Usage

```bash
cd security-groups

terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Clean up when finished
terraform destroy
```

## Known limitations / next steps

- **SSH is open to the whole internet (`0.0.0.0/0`).** For real use, restrict it
  to your own IP, for example `cidr_ipv4 = "<your-ip>/32"` (find it with
  `curl -s https://checkip.amazonaws.com`), ideally passed in as a variable.
- **No key pair is attached**, so you cannot log in over SSH yet. Add an
  `aws_key_pair` resource and set `key_name` on the instance.
- The `egress` group uses an inline `egress {}` block, while the ingress rules use
  separate `aws_vpc_security_group_*_rule` resources. Never mix both styles on
  the same security group.

> The AMI ID is specific to `ap-southeast-2`. If you change the region,
> look up the matching Debian 13 AMI for that region.
