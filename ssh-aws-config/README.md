# SSH AWS Config

Launches a Debian 13 EC2 instance that you can log into over SSH with your own
key pair, with security groups for SSH, HTTP, HTTPS and outbound traffic.

## Structure

```
ssh-aws-config/
└── instances/
    ├── version.tf     # Terraform and provider version constraints
    ├── provider.tf    # AWS provider (region ap-southeast-2)
    ├── main.tf        # Key pair, EC2 instance, security groups and rules
    └── outputs.tf     # Public DNS and public IP of the instance
```

## What it creates

| Resource | Details |
|---|---|
| `aws_key_pair.deployer` | Uploads your SSH **public** key to AWS as `aws_key` |
| `aws_instance.ssh` | Debian 13, `t3.micro`, uses the `aws_key` key pair |
| `aws_security_group.allow_ssh` + ingress rule | Inbound TCP **22** (SSH) |
| `aws_security_group.allow_http` + ingress rule | Inbound TCP **80** (HTTP) |
| `aws_security_group.allow_tls` + ingress rule | Inbound TCP **443** (HTTPS) |
| `aws_security_group.egress` | All outbound traffic (IPv4 and IPv6) |

## Outputs

| Output | Description |
|---|---|
| `public_dns` | Public DNS name of the instance |
| `public_ip` | Public IP address of the instance |

## Usage

### 1. Create an SSH key pair (once)

Keep keys in `~/.ssh`, **never inside this repository**.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/terraform-lab -C "terraform-lab"
```

Put the contents of `~/.ssh/terraform-lab.pub` into the `public_key` of
`aws_key_pair.deployer` in `main.tf`. Public keys are safe to commit; private keys are not.

### 2. Deploy

```bash
cd ssh-aws-config/instances

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Connect

```bash
ssh -i ~/.ssh/terraform-lab admin@$(terraform output -raw public_ip)
```

`admin` is the default user on Debian AMIs (`ubuntu` on Ubuntu, `ec2-user` on Amazon Linux).

### 4. Optional: serve a web page

```bash
# on the instance
sudo apt update && sudo apt install -y nginx
```

Then open `http://<public_ip>` in a browser. Until a web server is installed,
the browser shows a connection error because nothing listens on port 80.

### 5. Clean up

```bash
terraform destroy
```

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `InvalidAMIID.NotFound` | AMI IDs are region-specific | Use an AMI from the provider's region |
| `not eligible for Free Tier` | `t2.micro` is not Free Tier on newer accounts | Use `t3.micro` |
| `Permission denied (publickey)` | Wrong key or username | Use `-i ~/.ssh/terraform-lab` and `admin@` |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | A new instance reused the IP | `ssh-keygen -R <public_ip>` |

## Known limitations / next steps

- **SSH is open to the whole internet (`0.0.0.0/0`).** Restrict it to your own IP (`<your-ip>/32`).
- `key_name` is a hard-coded string; referencing `aws_key_pair.deployer.key_name`
  would make the dependency explicit.
- Software is installed manually; `user_data` could install nginx automatically at boot.
