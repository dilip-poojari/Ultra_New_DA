##############################################################################
# VPC Resource
##############################################################################

resource "ibm_is_vpc" "vpc" {
  name                        = var.vpc_name
  resource_group              = var.resource_group_id
  classic_access              = false
  address_prefix_management   = "auto"
  default_network_acl_name    = "${var.vpc_name}-default-acl"
  default_security_group_name = "${var.vpc_name}-default-sg"
  default_routing_table_name  = "${var.vpc_name}-default-rt"
  tags                        = var.tags
}

##############################################################################
# VPC Address Prefixes (Optional - for custom CIDR ranges)
##############################################################################

resource "ibm_is_vpc_address_prefix" "address_prefix" {
  for_each = var.custom_address_prefixes

  name = each.value.name
  zone = each.value.zone
  vpc  = ibm_is_vpc.vpc.id
  cidr = each.value.cidr
}