##############################################################################
# VPC Module
##############################################################################

module "vpc" {
  source = "./modules/vpc"

  vpc_name            = local.vpc_name
  resource_group_id   = var.resource_group_id
  region              = var.region
  tags                = local.common_tags
}

##############################################################################
# Networking Module
##############################################################################

module "networking" {
  source = "./modules/networking"

  vpc_id                  = module.vpc.vpc_id
  resource_group_id       = var.resource_group_id
  region                  = var.region
  zones                   = local.zones
  subnet_config           = local.subnet_config
  enable_public_gateway   = var.enable_public_gateway
  security_group_rules    = local.default_security_group_rules
  tags                    = local.common_tags

  depends_on = [module.vpc]
}

##############################################################################
# ROKS Cluster Module
##############################################################################

module "roks_cluster" {
  source = "./modules/roks-cluster"

  cluster_name                    = local.cluster_name
  resource_group_id               = var.resource_group_id
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.networking.subnet_ids
  openshift_version               = var.openshift_version
  worker_pool_flavor              = var.worker_pool_flavor
  workers_per_zone                = var.workers_per_zone
  disable_public_service_endpoint = var.disable_public_service_endpoint
  kms_config                      = var.kms_config
  tags                            = local.common_tags

  depends_on = [module.networking]
}

##############################################################################
# Data source for cluster configuration
##############################################################################

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = module.roks_cluster.cluster_id
  resource_group_id = var.resource_group_id
  config_dir        = "${path.module}/.kube"

  depends_on = [module.roks_cluster]
}

##############################################################################
# ODF Storage Module
##############################################################################

module "odf_storage" {
  source = "./modules/odf-storage"

  cluster_id              = module.roks_cluster.cluster_id
  resource_group_id       = var.resource_group_id
  odf_version             = var.odf_version
  billing_type            = var.odf_billing_type
  cluster_encryption      = var.odf_cluster_encryption
  worker_pool_flavor      = var.worker_pool_flavor
  odf_config              = local.odf_config

  depends_on = [
    module.roks_cluster,
    data.ibm_container_cluster_config.cluster_config
  ]
}

##############################################################################
# OpenShift AI Module
##############################################################################

module "openshift_ai" {
  source = "./modules/openshift-ai"

  cluster_id              = module.roks_cluster.cluster_id
  openshift_ai_config     = local.openshift_ai_config
  storage_class_name      = module.odf_storage.storage_class_name

  depends_on = [
    module.odf_storage,
    data.ibm_container_cluster_config.cluster_config
  ]
}

##############################################################################
# Observability Module (Optional)
##############################################################################

module "observability" {
  count  = var.enable_observability ? 1 : 0
  source = "./modules/observability"

  cluster_id                = module.roks_cluster.cluster_id
  resource_group_id         = var.resource_group_id
  region                    = var.region
  log_analysis_instance_id  = var.log_analysis_instance_id
  monitoring_instance_id    = var.monitoring_instance_id

  depends_on = [module.roks_cluster]
}

##############################################################################
# Wait for cluster to be ready
##############################################################################

resource "time_sleep" "wait_for_cluster" {
  depends_on = [module.roks_cluster]

  create_duration = "5m"
}

resource "time_sleep" "wait_for_odf" {
  depends_on = [module.odf_storage]

  create_duration = "10m"
}

resource "time_sleep" "wait_for_openshift_ai" {
  depends_on = [module.openshift_ai]

  create_duration = "5m"
}