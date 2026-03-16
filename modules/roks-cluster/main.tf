##############################################################################
# ROKS Cluster
##############################################################################

resource "ibm_container_vpc_cluster" "cluster" {
  name              = var.cluster_name
  vpc_id            = var.vpc_id
  flavor            = var.worker_pool_flavor
  worker_count      = var.workers_per_zone
  kube_version      = var.openshift_version
  resource_group_id = var.resource_group_id
  tags              = var.tags

  # Disable public service endpoint if required
  disable_public_service_endpoint = var.disable_public_service_endpoint

  # Enable KMS encryption if configured
  dynamic "kms_config" {
    for_each = var.kms_config != null ? [var.kms_config] : []
    content {
      instance_id      = kms_config.value.instance_id
      crk_id           = kms_config.value.crk_id
      private_endpoint = kms_config.value.private_endpoint
    }
  }

  # Multi-zone deployment
  dynamic "zones" {
    for_each = var.subnet_ids
    content {
      name      = zones.key
      subnet_id = zones.value
    }
  }

  # Wait for cluster to be ready
  wait_till = "IngressReady"

  # Entitlement for OpenShift
  entitlement = "cloud_pak"

  # Operating system
  operating_system = "REDHAT_8_64"

  # Pod and service subnets
  pod_subnet     = var.pod_subnet
  service_subnet = var.service_subnet

  # Disable outbound traffic protection
  disable_outbound_traffic_protection = false
}

##############################################################################
# Additional Worker Pools (Optional)
##############################################################################

resource "ibm_container_vpc_worker_pool" "additional_pool" {
  for_each = var.additional_worker_pools

  cluster           = ibm_container_vpc_cluster.cluster.id
  worker_pool_name  = each.value.name
  flavor            = each.value.flavor
  vpc_id            = var.vpc_id
  worker_count      = each.value.workers_per_zone
  resource_group_id = var.resource_group_id
  entitlement       = "cloud_pak"
  operating_system  = "REDHAT_8_64"

  dynamic "zones" {
    for_each = var.subnet_ids
    content {
      name      = zones.key
      subnet_id = zones.value
    }
  }

  labels = each.value.labels
  taints = each.value.taints
}

##############################################################################
# Cluster Addons
##############################################################################

# OpenShift Data Foundation addon will be managed separately
# This is a placeholder for other addons if needed

resource "ibm_container_addons" "addons" {
  cluster = ibm_container_vpc_cluster.cluster.id

  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name    = addons.value.name
      version = addons.value.version
    }
  }
}

##############################################################################
# Wait for cluster to be fully ready
##############################################################################

resource "time_sleep" "wait_for_cluster_ready" {
  depends_on = [ibm_container_vpc_cluster.cluster]

  create_duration = "5m"
}