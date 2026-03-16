##############################################################################
# VPC Outputs
##############################################################################

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = module.vpc.vpc_name
}

output "vpc_crn" {
  description = "CRN of the created VPC"
  value       = module.vpc.vpc_crn
}

##############################################################################
# Networking Outputs
##############################################################################

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = module.networking.subnet_ids
}

output "subnet_details" {
  description = "Details of all created subnets"
  value       = module.networking.subnet_details
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.networking.security_group_id
}

output "public_gateway_ids" {
  description = "IDs of public gateways"
  value       = module.networking.public_gateway_ids
}

##############################################################################
# ROKS Cluster Outputs
##############################################################################

output "cluster_id" {
  description = "ID of the OpenShift cluster"
  value       = module.roks_cluster.cluster_id
}

output "cluster_name" {
  description = "Name of the OpenShift cluster"
  value       = module.roks_cluster.cluster_name
}

output "cluster_crn" {
  description = "CRN of the OpenShift cluster"
  value       = module.roks_cluster.cluster_crn
}

output "cluster_ingress_hostname" {
  description = "Ingress hostname for the cluster"
  value       = module.roks_cluster.ingress_hostname
}

output "cluster_master_url" {
  description = "Master URL for the cluster"
  value       = module.roks_cluster.master_url
}

output "cluster_version" {
  description = "OpenShift version of the cluster"
  value       = module.roks_cluster.cluster_version
}

output "cluster_state" {
  description = "State of the cluster"
  value       = module.roks_cluster.cluster_state
}

##############################################################################
# ODF Storage Outputs
##############################################################################

output "odf_storage_class_name" {
  description = "Name of the ODF storage class"
  value       = module.odf_storage.storage_class_name
}

output "odf_version" {
  description = "Version of ODF installed"
  value       = module.odf_storage.odf_version
}

output "odf_status" {
  description = "Status of ODF installation"
  value       = module.odf_storage.odf_status
}

##############################################################################
# OpenShift AI Outputs
##############################################################################

output "openshift_ai_namespace" {
  description = "Namespace where OpenShift AI is installed"
  value       = module.openshift_ai.namespace
}

output "openshift_ai_dashboard_url" {
  description = "URL for OpenShift AI dashboard"
  value       = module.openshift_ai.dashboard_url
}

output "openshift_ai_status" {
  description = "Status of OpenShift AI installation"
  value       = module.openshift_ai.installation_status
}

output "notebook_images" {
  description = "List of enabled notebook images"
  value       = module.openshift_ai.notebook_images
}

output "model_serving_enabled" {
  description = "Whether model serving is enabled"
  value       = module.openshift_ai.model_serving_enabled
}

##############################################################################
# Observability Outputs
##############################################################################

output "observability_enabled" {
  description = "Whether observability is enabled"
  value       = var.enable_observability
}

output "log_analysis_instance_id" {
  description = "ID of the Log Analysis instance"
  value       = var.enable_observability ? var.log_analysis_instance_id : null
}

output "monitoring_instance_id" {
  description = "ID of the Monitoring instance"
  value       = var.enable_observability ? var.monitoring_instance_id : null
}

##############################################################################
# Access Information
##############################################################################

output "cluster_access_instructions" {
  description = "Instructions for accessing the cluster"
  value = <<-EOT
    To access your OpenShift cluster:
    
    1. Log in to IBM Cloud CLI:
       ibmcloud login --apikey <your-api-key>
    
    2. Set the resource group:
       ibmcloud target -g ${var.resource_group_id}
    
    3. Download cluster configuration:
       ibmcloud oc cluster config --cluster ${module.roks_cluster.cluster_id}
    
    4. Access OpenShift console:
       ${module.roks_cluster.master_url}
    
    5. Access OpenShift AI dashboard:
       ${module.openshift_ai.dashboard_url}
  EOT
}

output "deployment_summary" {
  description = "Summary of the deployed architecture"
  value = {
    region              = var.region
    vpc_name            = local.vpc_name
    cluster_name        = local.cluster_name
    openshift_version   = var.openshift_version
    worker_nodes        = var.workers_per_zone * length(local.zones)
    storage_solution    = "OpenShift Data Foundation (ODF)"
    odf_version         = var.odf_version
    openshift_ai_enabled = true
    observability_enabled = var.enable_observability
  }
}