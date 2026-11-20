# Variables

Launches a Debian 13 EC2 instance whose settings come from **input variables**
instead of hard-coded values. Demonstrates every common variable type, how
values are supplied, and how they are used in resources.

## Files

| File | Purpose |
|---|---|
| `main.tf` | Terraform/provider config and the EC2 instance, using `var.*` references |
| `variables.tf` | Variable declarations (type, description, default) |
| `terraform.tfvars.example` | Example values file. Copy to `terraform.tfvars` and edit |
| `.terraform.lock.hcl` | Locks the AWS provider version |

## Variables

| Variable | Type | Default | Used in |
|---|---|---|---|
| `aws_region` | `string` | `ap-southeast-2` | `provider "aws"` region |
| `variable_name` | `string` | `variables` | Instance `Name` tag |
| `ami_resource` | `string` | `ami-09c53fbd1ec844dff` (Debian 13, Sydney) | Instance AMI |
| `enable_feature_x` | `bool` | `false` | Not used (example) |
| `availability_zones` | `list(string)` | `["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]` | Instance AZ (`[1]` → `ap-southeast-2b`) |
| `allowed_ports` | `set(number)` | `[22, 80, 443]` | Not used yet (intended for `for_each` security group rules) |
| `instance_tags` | `map(string)` | `Environment`, `Project`, `ManagedBy` | Instance tags, merged with `Name` |
| `tfvar_example` | `string` | **none (required)** | Not used. Shows a value supplied by `terraform.tfvars` |

> `aws_region`, `ami_resource` and `availability_zones` must match: AMI IDs and
> Availability Zones only exist in their own region.

## Variable types

| Type | Example | Ordered | Duplicates | Access |
|---|---|---|---|---|
| `string` | `"t3.micro"` | – | – | `var.name` |
| `number` | `443` | – | – | `var.port` |
| `bool` | `true` / `false` | – | – | `var.enabled` |
| `list(...)` | `["a", "b", "a"]` | ✅ | ✅ allowed | `var.list[0]` |
| `set(...)` | `[22, 80, 443]` | ❌ | ❌ removed | `for_each = var.set` |
| `map(...)` | `{ Env = "dev" }` | sorted by key | keys unique | `var.map["Env"]` |

Example of using a map with `merge()` (from `main.tf`):

```hcl
tags = merge(var.instance_tags, {
  Name = var.variable_name
})
```

## Supplying values

`tfvar_example` has no default, so it **must** be given a value. The easiest
way is a `terraform.tfvars` file, which Terraform loads automatically:

```bash
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` is ignored by git (it may hold personal or secret values);
the `.example` file is committed as a template.

Values are applied in this order. **Later sources override earlier ones:**

1. `default` in `variables.tf`
2. Environment variables: `export TF_VAR_variable_name=MyInstance`
3. `terraform.tfvars`
4. `*.auto.tfvars`
5. Command line: `-var` / `-var-file`

```bash
terraform apply -var="variable_name=MyInstance"
terraform apply -var='availability_zones=["ap-southeast-2a","ap-southeast-2b"]'
terraform apply -var='instance_tags={Environment="test",Project="my-terraform-journey",ManagedBy="terraform"}'
```

A `-var` value for a map or list **replaces** the whole collection; it does not merge.

## Usage

```bash
cd variables

cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Inspect variable values interactively
terraform console
> var.availability_zones[1]
> var.instance_tags

# Clean up
terraform destroy
```

## Notes

- Variable names must be unique **within a folder** (all `.tf` files load together);
  a duplicate gives `Duplicate variable declaration`.
- Changing `availability_zone` on an existing instance **forces replacement**
  (destroy + create, new public IP). Always read the plan.
- Variables can be used in the `provider` block (e.g. `region = var.aws_region`).
