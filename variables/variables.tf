variable "aws_region" {
  description = "AWS region to deploy into. AMI IDs and Availability Zones are region-specific, so change ami_resource and availability_zones too if you change this."
  type        = string
  default     = "ap-southeast-2"
}

variable "variable_name" {
  description = "Description of the variable"
  type        = string
  default     = "variables"
}

#terraform apply -var "variable_name=MyInstance"
#to rename the instance
#default is not required, but if you want to change the name of the instance, you can pass a value for this variable when running terraform apply.


variable "ami_resource" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-09c53fbd1ec844dff" # Debian 13 (official Debian AMI for ap-southeast-2)
}


variable "enable_feature_x" {
  description = "Enable feature X"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Collection types: list, set and map
# ---------------------------------------------------------------------------

# LIST: an ordered collection. Duplicates are allowed, and items are accessed
# by index (starting at 0).
#   var.availability_zones[0]      -> "ap-southeast-2a"
#   length(var.availability_zones) -> 3
variable "availability_zones" {
  description = "Availability Zones in ap-southeast-2, in order of preference"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

# SET: an unordered collection of UNIQUE values. Duplicates are removed
# automatically and there is no index (var.allowed_ports[0] is an error).
# Commonly used with for_each, e.g. one security group rule per port:
#   for_each  = var.allowed_ports
#   from_port = each.value
variable "allowed_ports" {
  description = "Inbound TCP ports to allow (22 = SSH, 80 = HTTP, 443 = HTTPS)"
  type        = set(number)
  default     = [22, 80, 443]
}

# MAP: key = value pairs. Keys are unique strings; values must all be the same type.
#   var.instance_tags["Environment"] -> "dev"
#   tags = var.instance_tags         -> applies every tag at once
variable "instance_tags" {
  description = "Tags to apply to the EC2 instance"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "my-terraform-journey"
    ManagedBy   = "terraform"
  }
}


#tfvar_example = "This is an example of a variable with no default value, set in terraform.tfvars"
variable "tfvar_example" {
  description = "Example of a variable with no default value"
  type        = string
}

# Overriding collection values on the command line:
#   terraform apply -var='availability_zones=["ap-southeast-2b"]'
#   terraform apply -var='allowed_ports=[22,443]'
#   terraform apply -var='instance_tags={Environment="prod",Owner="awais"}'


