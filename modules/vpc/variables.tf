variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "region" {
  description = "IBM Cloud region"
  type        = string
}

variable "tags" {
  description = "List of tags"
  type        = list(string)
  default     = []
}

variable "custom_address_prefixes" {
  description = "Custom address prefixes for the VPC"
  type = map(object({
    name = string
    zone = string
    cidr = string
  }))
  default = {}
}