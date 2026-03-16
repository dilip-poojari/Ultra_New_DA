output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = { for k, v in ibm_is_subnet.subnet : k => v.id }
}

output "subnet_details" {
  description = "Detailed information about all subnets"
  value = {
    for k, v in ibm_is_subnet.subnet : k => {
      id                  = v.id
      name                = v.name
      zone                = v.zone
      ipv4_cidr_block     = v.ipv4_cidr_block
      available_ipv4_count = v.available_ipv4_address_count
      total_ipv4_count    = v.total_ipv4_address_count
      crn                 = v.crn
    }
  }
}

output "security_group_id" {
  description = "ID of the security group"
  value       = ibm_is_security_group.security_group.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = ibm_is_security_group.security_group.name
}

output "security_group_crn" {
  description = "CRN of the security group"
  value       = ibm_is_security_group.security_group.crn
}

output "public_gateway_ids" {
  description = "Map of public gateway IDs"
  value       = var.enable_public_gateway ? { for k, v in ibm_is_public_gateway.gateway : k => v.id } : {}
}

output "public_gateway_details" {
  description = "Detailed information about public gateways"
  value = var.enable_public_gateway ? {
    for k, v in ibm_is_public_gateway.gateway : k => {
      id          = v.id
      name        = v.name
      zone        = v.zone
      floating_ip = v.floating_ip
      crn         = v.crn
    }
  } : {}
}

output "network_acl_id" {
  description = "ID of the network ACL"
  value       = var.create_network_acl ? ibm_is_network_acl.network_acl[0].id : null
}