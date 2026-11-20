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
  region = var.aws_region
}

resource "aws_instance" "variables" {
  # Debian 13 (official Debian AMI for ap-southeast-2).
  # AMI IDs are region-specific; change this if you change the region.
  ami               = var.ami_resource
  instance_type     = "t3.micro"
  availability_zone = var.availability_zones[1] # ap-southeast-2b


  # merge() combines maps into one. The tags from var.instance_tags (map variable)
  # are added together with the Name tag. If a key appears in both, the later
  # map wins, so Name here would override a Name inside instance_tags.
  tags = merge(var.instance_tags, {
    Name = var.variable_name
  })
}

