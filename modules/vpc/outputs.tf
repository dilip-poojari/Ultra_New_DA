output "vpc_id" {
  description = "ID of the VPC"
  value       = ibm_is_vpc.vpc.id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = ibm_is_vpc.vpc.name
}

output "vpc_crn" {
  description = "CRN of the VPC"
  value       = ibm_is_vpc.vpc.crn
}

output "vpc_status" {
  description = "Status of the VPC"
  value       = ibm_is_vpc.vpc.status
}

output "default_security_group_id" {
  description = "ID of the default security group"
  value       = ibm_is_vpc.vpc.default_security_group
}

output "default_network_acl_id" {
  description = "ID of the default network ACL"
  value       = ibm_is_vpc.vpc.default_network_acl
}

output "default_routing_table_id" {
  description = "ID of the default routing table"
  value       = ibm_is_vpc.vpc.default_routing_table
}