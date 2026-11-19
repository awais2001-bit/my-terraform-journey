# Cloud-Init

Launches a Debian 13 EC2 instance that **configures itself on first boot** using
[cloud-init](https://cloudinit.readthedocs.io/). Terraform builds the infrastructure;
cloud-init installs and configures the software inside it. No manual SSH setup is needed.

After `terraform apply` (and 2–3 minutes for cloud-init to finish), the instance serves a
[MkDocs](https://www.mkdocs.org/) documentation site through Apache on port 80.

## Structure

```
cloud-init/
├── instances/
│   ├── version.tf     # Terraform and provider version constraints
│   ├── provider.tf    # AWS provider (region ap-southeast-2)
│   ├── main.tf        # EC2 instance (with user_data), key pair, security groups
│   └── outputs.tf     # Public DNS and public IP of the instance
└── scripts/
    └── apache-mkdocs.yaml   # cloud-config passed to the instance as user_data
```

## How it works

```
terraform apply
   └─► EC2 instance launches with user_data = scripts/apache-mkdocs.yaml
          └─► cloud-init runs on first boot:
                ├─ creates group dpro42-group and user "batman" (SSH key + sudo)
                ├─ writes /home/batman/hello.txt
                ├─ installs apache2 and mkdocs
                ├─ builds a starter MkDocs site
                └─ publishes it to /var/www/html and restarts Apache
```

The file is wired in via `main.tf`:

```hcl
user_data = file("../scripts/apache-mkdocs.yaml")
```

## What it creates

| Resource | Details |
|---|---|
| `aws_instance.cloud_init` | Debian 13, `t3.micro`, runs `apache-mkdocs.yaml` on first boot |
| `aws_key_pair.deployer` | Uploads the SSH public key as `aws_key` |
| `aws_security_group.allow_ssh` + rule | Inbound TCP **22** (SSH) |
| `aws_security_group.allow_http` + rule | Inbound TCP **80** (HTTP), serves the MkDocs site |
| `aws_security_group.allow_tls` + rule | Inbound TCP **443** (HTTPS) |
| `aws_security_group.egress` | All outbound traffic (needed for `apt-get install`) |

## Usage

```bash
cd cloud-init/instances

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Wait 2–3 minutes for cloud-init to install packages, then:

```bash
# View the site
open "http://$(terraform output -raw public_ip)"

# SSH as the default Debian user or the cloud-init user
ssh -i ~/.ssh/terraform-lab admin@$(terraform output -raw public_ip)
ssh -i ~/.ssh/terraform-lab batman@$(terraform output -raw public_ip)
```

### Verify cloud-init on the instance

```bash
cloud-init status --wait                       # should report: status: done
sudo tail -50 /var/log/cloud-init-output.log   # output of the runcmd steps
cat /home/batman/hello.txt                     # welcome message
```

### Clean up

```bash
terraform destroy
```

## Key concepts

- **cloud-init** runs once, on an instance's **first boot**. Rebooting does not rerun it,
  and changing `user_data` does not affect an existing instance unless
  `user_data_replace_on_change = true` is set.
- A cloud-config file **must start with exactly `#cloud-config`**, or cloud-init ignores it.
- `runcmd` commands run **as root**, in order, as a single shell script.
- `users: - default` keeps the image's default user (`admin` on Debian) alongside custom users.
- `user_data` is limited to 16 KB and is visible to anyone with EC2 read access, so
  **never put secrets in it**.

## Known limitations / next steps

- **SSH is open to the whole internet (`0.0.0.0/0`).** Restrict it to your own IP (`<your-ip>/32`).
- User `batman` has passwordless `sudo`, which is convenient for a lab but too permissive for production.
- Port 443 is open but HTTPS is not configured (no TLS certificate).
- Key pair and security group names are fixed, so this lab cannot run at the same time as
  other labs in this repo that use the same names.
