variable "cluster_id" {
  description = "ID of the OpenShift cluster"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "odf_version" {
  description = "Version of OpenShift Data Foundation to install"
  type        = string
  default     = "4.14.0"
}

variable "billing_type" {
  description = "Billing type for ODF (essentials or advanced)"
  type        = string
  default     = "advanced"
  validation {
    condition     = contains(["essentials", "advanced"], var.billing_type)
    error_message = "Billing type must be 'essentials' or 'advanced'."
  }
}

variable "cluster_encryption" {
  description = "Enable encryption for ODF storage cluster"
  type        = bool
  default     = true
}

variable "worker_pool_flavor" {
  description = "Worker pool flavor (used for resource calculations)"
  type        = string
}

variable "odf_config" {
  description = "ODF configuration object"
  type = object({
    namespace           = string
    operator_namespace  = string
    storage_class_name  = string
    billing_type        = string
    cluster_encryption  = bool
  })
}