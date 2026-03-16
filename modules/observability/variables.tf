variable "cluster_id" {
  description = "ID of the OpenShift cluster"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "region" {
  description = "IBM Cloud region"
  type        = string
}

variable "log_analysis_instance_id" {
  description = "ID of IBM Cloud Logs instance"
  type        = string
  default     = null
}

variable "monitoring_instance_id" {
  description = "ID of IBM Cloud Monitoring instance"
  type        = string
  default     = null
}

variable "create_grafana_dashboards" {
  description = "Create Grafana dashboards for OpenShift AI"
  type        = bool
  default     = true
}