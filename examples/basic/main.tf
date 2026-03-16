##############################################################################
# Basic Example - OpenShift AI on ROKS
##############################################################################

module "openshift_ai_roks" {
  source = "../.."

  # IBM Cloud Configuration
  ibmcloud_api_key   = var.ibmcloud_api_key
  region             = var.region
  resource_group_id  = var.resource_group_id

  # Naming
  prefix = var.prefix
  tags   = var.tags

  # VPC Configuration
  vpc_name               = "vpc"
  enable_public_gateway  = true

  # ROKS Cluster Configuration
  cluster_name                    = "cluster"
  openshift_version               = "4.14_openshift"
  worker_pool_flavor              = "bx2.16x64"
  workers_per_zone                = 2
  disable_public_service_endpoint = false

  # ODF Storage Configuration
  odf_version            = "4.14.0"
  odf_billing_type       = "advanced"
  odf_cluster_encryption = true

  # OpenShift AI Configuration
  openshift_ai_namespace     = "redhat-ods-operator"
  enable_notebook_controller = true
  enable_model_serving       = true
  enable_dashboard           = true

  # Observability (Optional - disabled in basic example)
  enable_observability = false
}