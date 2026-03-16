variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region"
  type        = string
  default     = "us-south"
}

variable "resource_group_id" {
  description = "Resource group ID"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "openshift-ai"
}

variable "tags" {
  description = "List of tags"
  type        = list(string)
  default     = ["terraform", "openshift-ai", "example"]
}