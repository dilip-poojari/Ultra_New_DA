##############################################################################
# Subnets
##############################################################################

resource "ibm_is_subnet" "subnet" {
  for_each = var.subnet_config

  name                     = each.value.name
  vpc                      = var.vpc_id
  zone                     = each.value.zone
  total_ipv4_address_count = var.number_of_addresses
  resource_group           = var.resource_group_id
  public_gateway           = var.enable_public_gateway ? ibm_is_public_gateway.gateway[each.value.zone].id : null
  tags                     = var.tags
}

##############################################################################
# Public Gateways
##############################################################################

resource "ibm_is_public_gateway" "gateway" {
  for_each = var.enable_public_gateway ? toset(var.zones) : []

  name           = "${var.vpc_id}-pgw-${each.value}"
  vpc            = var.vpc_id
  zone           = each.value
  resource_group = var.resource_group_id
  tags           = var.tags
}

##############################################################################
# Security Group
##############################################################################

resource "ibm_is_security_group" "security_group" {
  name           = "${var.vpc_id}-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags
}

##############################################################################
# Security Group Rules
##############################################################################

resource "ibm_is_security_group_rule" "security_group_rule_tcp" {
  for_each = {
    for idx, rule in var.security_group_rules :
    "${rule.name}-${idx}" => rule
    if lookup(rule, "tcp", null) != null
  }

  group     = ibm_is_security_group.security_group.id
  direction = each.value.direction
  remote    = each.value.remote

  tcp {
    port_min = each.value.tcp.port_min
    port_max = each.value.tcp.port_max
  }
}

resource "ibm_is_security_group_rule" "security_group_rule_udp" {
  for_each = {
    for idx, rule in var.security_group_rules :
    "${rule.name}-${idx}" => rule
    if lookup(rule, "udp", null) != null
  }

  group     = ibm_is_security_group.security_group.id
  direction = each.value.direction
  remote    = each.value.remote

  udp {
    port_min = each.value.udp.port_min
    port_max = each.value.udp.port_max
  }
}

resource "ibm_is_security_group_rule" "security_group_rule_icmp" {
  for_each = {
    for idx, rule in var.security_group_rules :
    "${rule.name}-${idx}" => rule
    if lookup(rule, "icmp", null) != null
  }

  group     = ibm_is_security_group.security_group.id
  direction = each.value.direction
  remote    = each.value.remote

  icmp {
    type = lookup(each.value.icmp, "type", null)
    code = lookup(each.value.icmp, "code", null)
  }
}

resource "ibm_is_security_group_rule" "security_group_rule_all" {
  for_each = {
    for idx, rule in var.security_group_rules :
    "${rule.name}-${idx}" => rule
    if lookup(rule, "tcp", null) == null && lookup(rule, "udp", null) == null && lookup(rule, "icmp", null) == null
  }

  group     = ibm_is_security_group.security_group.id
  direction = each.value.direction
  remote    = each.value.remote
}

##############################################################################
# Network ACL (Optional - for additional security)
##############################################################################

resource "ibm_is_network_acl" "network_acl" {
  count = var.create_network_acl ? 1 : 0

  name           = "${var.vpc_id}-acl"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags

  # Allow all inbound traffic
  rules {
    name        = "allow-all-inbound"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    direction   = "inbound"
  }

  # Allow all outbound traffic
  rules {
    name        = "allow-all-outbound"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    direction   = "outbound"
  }
}