terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }

  required_version = ">= 1.14.2"
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "lab_03" {
  # Debian 13 (official Debian AMI for ap-southeast-2).
  # AMI IDs are region-specific; change this if you change the region.
  ami           = "ami-09c53fbd1ec844dff"
  instance_type = "t3.micro"
  monitoring    = var.enable_detailed_monitoring # defined in monitoring.tf

  tags = {
    Name = "Lab-03"
  }
}

# NOTE: For AWS accounts created after July 15th, 2025, t3.micro (not t2.micro)
# is the Free Tier eligible instance type.
