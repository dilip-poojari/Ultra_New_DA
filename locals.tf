locals {
  # Naming conventions
  vpc_name     = "${var.prefix}-${var.vpc_name}"
  cluster_name = "${var.prefix}-${var.cluster_name}"

  # Zones for multi-zone deployment
  zones = [
    "${var.region}-1",
    "${var.region}-2",
    "${var.region}-3"
  ]

  # Common tags
  common_tags = concat(
    var.tags,
    [
      "deployment:terraform",
      "solution:openshift-ai",
      "region:${var.region}"
    ]
  )

  # Subnet configuration
  subnet_config = {
    for idx, zone in local.zones : zone => {
      name = "${local.vpc_name}-subnet-${idx + 1}"
      zone = zone
      cidr = cidrsubnet("10.0.0.0/8", 8, idx)
    }
  }

  # Worker pool configuration
  worker_pool_config = {
    for idx, zone in local.zones : zone => {
      zone            = zone
      workers_per_zone = var.workers_per_zone
    }
  }

  # ODF configuration
  odf_config = {
    namespace           = "openshift-storage"
    operator_namespace  = "openshift-storage"
    storage_class_name  = var.odf_storage_class_name
    billing_type        = var.odf_billing_type
    cluster_encryption  = var.odf_cluster_encryption
  }

  # OpenShift AI configuration
  openshift_ai_config = {
    namespace              = var.openshift_ai_namespace
    operator_namespace     = var.openshift_ai_namespace
    enable_notebook        = var.enable_notebook_controller
    enable_model_serving   = var.enable_model_serving
    enable_dashboard       = var.enable_dashboard
    notebook_images        = var.notebook_images
  }

  # Security group rules
  default_security_group_rules = var.create_security_group_rules ? [
    {
      name      = "allow-https-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 443
        port_max = 443
      }
    },
    {
      name      = "allow-http-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },
    {
      name      = "allow-openshift-api"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 6443
        port_max = 6443
      }
    },
    {
      name      = "allow-all-outbound"
      direction = "outbound"
      remote    = "0.0.0.0/0"
    }
  ] : []
}