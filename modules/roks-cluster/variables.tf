variable "cluster_name" {
  description = "Name of the OpenShift cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet IDs by zone"
  type        = map(string)
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "openshift_version" {
  description = "OpenShift version to deploy"
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
    condition     = var.workers_per_zone >= 1
    error_message = "Must have at least 1 worker per zone."
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
    crk_id           = string
    private_endpoint = optional(bool, true)
  })
  default = null
}

variable "pod_subnet" {
  description = "Subnet for Kubernetes pods"
  type        = string
  default     = "172.30.0.0/16"
}

variable "service_subnet" {
  description = "Subnet for Kubernetes services"
  type        = string
  default     = "172.21.0.0/16"
}

variable "additional_worker_pools" {
  description = "Additional worker pools to create"
  type = map(object({
    name              = string
    flavor            = string
    workers_per_zone  = number
    labels            = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {}
}

variable "cluster_addons" {
  description = "List of cluster addons to enable"
  type = list(object({
    name    = string
    version = string
  }))
  default = []
}

variable "tags" {
  description = "List of tags"
  type        = list(string)
  default     = []
}