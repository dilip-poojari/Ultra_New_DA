variable "cluster_id" {
  description = "ID of the OpenShift cluster"
  type        = string
}

variable "openshift_ai_config" {
  description = "OpenShift AI configuration object"
  type = object({
    namespace              = string
    operator_namespace     = string
    enable_notebook        = bool
    enable_model_serving   = bool
    enable_dashboard       = bool
    notebook_images        = list(string)
  })
}

variable "storage_class_name" {
  description = "Name of the storage class to use for notebooks"
  type        = string
}