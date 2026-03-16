variable "vpc_id" {
  description = "ID of the VPC"
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

variable "zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "subnet_config" {
  description = "Configuration for subnets"
  type = map(object({
    name = string
    zone = string
    cidr = string
  }))
}

variable "number_of_addresses" {
  description = "Number of IP addresses per subnet"
  type        = number
  default     = 256
}

variable "enable_public_gateway" {
  description = "Enable public gateway for subnets"
  type        = bool
  default     = true
}

variable "security_group_rules" {
  description = "List of security group rules"
  type = list(object({
    name      = string
    direction = string
    remote    = string
    tcp = optional(object({
      port_min = number
      port_max = number
    }))
    udp = optional(object({
      port_min = number
      port_max = number
    }))
    icmp = optional(object({
      type = optional(number)
      code = optional(number)
    }))
  }))
  default = []
}

variable "create_network_acl" {
  description = "Create a network ACL"
  type        = bool
  default     = false
}

variable "tags" {
  description = "List of tags"
  type        = list(string)
  default     = []
}