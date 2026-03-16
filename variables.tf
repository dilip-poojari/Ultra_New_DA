##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where resources will be deployed"
  type        = string
  default     = "us-south"
  validation {
    condition     = can(regex("^(us-south|us-east|eu-de|eu-gb|jp-tok|au-syd|jp-osa|eu-es|ca-tor|br-sao)$", var.region))
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "resource_group_id" {
  description = "ID of the resource group where resources will be created"
  type        = string
}

##############################################################################
# Naming Variables
##############################################################################

variable "prefix" {
  description = "Prefix for naming all resources (e.g., 'prod', 'dev', 'test')"
  type        = string
  default     = "openshift-ai"
  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*$", var.prefix))
    error_message = "Prefix must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "List of tags to apply to all resources"
  type        = list(string)
  default     = ["openshift-ai", "roks", "terraform"]
}

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_name" {
  description = "Name of the VPC (will be prefixed)"
  type        = string
  default     = "vpc"
}

variable "enable_public_gateway" {
  description = "Enable public gateway for VPC subnets"
  type        = bool
  default     = true
}

variable "number_of_addresses" {
  description = "Number of IP addresses per subnet"
  type        = number
  default     = 256
}

##############################################################################
# ROKS Cluster Variables
##############################################################################

variable "cluster_name" {
  description = "Name of the OpenShift cluster (will be prefixed)"
  type        = string
  default     = "cluster"
}

variable "openshift_version" {
  description = "OpenShift version to deploy (e.g., '4.14_openshift')"
  type        = string
  default     = "4.14_openshift"
}

variable "worker_pool_flavor" {
  description = "Machine type for worker nodes"
  type        = string
  default     = "bx2.16x64"
}

variable "workers_per_zone" {
  description = "Number of worker nodes per zone"
  type        = number
  default     = 2
  validation {
    condition     = var.workers_per_zone >= 2
    error_message = "Must have at least 2 workers per zone for HA."
  }
}

variable "disable_public_service_endpoint" {
  description = "Disable public service endpoint for cluster"
  type        = bool
  default     = false
}

variable "kms_config" {
  description = "KMS configuration for cluster encryption"
  type = object({
    instance_id      = string
    crk_id          = string
    private_endpoint = optional(bool, true)
  })
  default = null
}

##############################################################################
# ODF Storage Variables
##############################################################################

variable "odf_version" {
  description = "Version of OpenShift Data Foundation to install"
  type        = string
  default     = "4.14.0"
}

variable "odf_billing_type" {
  description = "Billing type for ODF (essentials or advanced)"
  type        = string
  default     = "advanced"
  validation {
    condition     = contains(["essentials", "advanced"], var.odf_billing_type)
    error_message = "ODF billing type must be 'essentials' or 'advanced'."
  }
}

variable "odf_cluster_encryption" {
  description = "Enable encryption for ODF storage cluster"
  type        = bool
  default     = true
}

variable "odf_storage_class_name" {
  description = "Name of the storage class to create"
  type        = string
  default     = "ocs-storagecluster-cephfs"
}

##############################################################################
# OpenShift AI Variables
##############################################################################

variable "openshift_ai_namespace" {
  description = "Namespace for OpenShift AI installation"
  type        = string
  default     = "redhat-ods-operator"
}

variable "enable_notebook_controller" {
  description = "Enable Jupyter notebook controller"
  type        = bool
  default     = true
}

variable "enable_model_serving" {
  description = "Enable model serving components (KServe/ModelMesh)"
  type        = bool
  default     = true
}

variable "enable_dashboard" {
  description = "Enable OpenShift AI dashboard"
  type        = bool
  default     = true
}

variable "notebook_images" {
  description = "List of notebook images to enable"
  type        = list(string)
  default = [
    "s2i-generic-data-science-notebook",
    "s2i-minimal-notebook",
    "s2i-tensorflow-notebook",
    "s2i-pytorch-notebook"
  ]
}

##############################################################################
# Observability Variables
##############################################################################

variable "enable_observability" {
  description = "Enable IBM Cloud Logs and Monitoring integration"
  type        = bool
  default     = false
}

variable "log_analysis_instance_id" {
  description = "ID of IBM Cloud Logs instance for logging"
  type        = string
  default     = null
}

variable "monitoring_instance_id" {
  description = "ID of IBM Cloud Monitoring instance"
  type        = string
  default     = null
}

##############################################################################
# Network Security Variables
##############################################################################

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_security_group_rules" {
  description = "Create default security group rules"
  type        = bool
  default     = true
}