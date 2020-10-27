# REQUIRED

variable "project_name" {
  type        = string
  description = "Set this, resources are given a unique name based on this"
}

variable "hashi_tags" {
  type = map(string)

  default = {
    "TTL"     = "24"
    "Owner"   = "HashiCorpDemo"
    "Project" = "ConsulDemo001"
  }
}

variable "ssh_key_name" {
  description = "Name of existing AWS ssh key"
}

variable "route53_subzone" {
  description = "Route53 (sub)zone where host records will be created"
}

# One of these ssh_pri_key variables must be specified

variable "ssh_pri_key_file" {
  description = "File URL to Private SSH key for post provisioning config"
  default     = ""
}

variable "ssh_pri_key_data" {
  description = "Contents of Private SSH key for post provisioning config"
  default     = ""
}

# OPTIONAL

# Images in us-east-1 and us-west-2
variable "aws_region" {
  description = "Region into which to deploy"
  default     = "us-west-2"
}

variable "consul_dc" {
  description = "Consul cluster DC name"
  default     = "dc1"
}

# Region to deploy alternate cluster
variable "aws_region_alt" {
  description = "Region into which to deploy"
  default     = "us-east-1"
}

variable "consul_dc_alt" {
  description = "Alternate Consul cluster DC name"
  default     = "dc2"
}

variable "ami_owner" {
  description = "AWS account which owns AMIs"
  default     = "self"
}

variable "ami_prefix" {
  description = "prefix of AMI images to use when building instances"
  default     = "consul-demo-ent"
}

variable "consul_lic" {
  description = "License file content for Consul Enterprise"
  default     = ""
}

variable "vpc_cidr_main" {
  description = "The netblock for the main VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_alt" {
  description = "The netblock for the alt VPC"
  default     = "10.128.0.0/16"
}
