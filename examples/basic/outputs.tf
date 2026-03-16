output "vpc_id" {
  description = "VPC ID"
  value       = module.openshift_ai_roks.vpc_id
}

output "cluster_id" {
  description = "OpenShift cluster ID"
  value       = module.openshift_ai_roks.cluster_id
}

output "cluster_name" {
  description = "OpenShift cluster name"
  value       = module.openshift_ai_roks.cluster_name
}

output "cluster_ingress_hostname" {
  description = "Cluster ingress hostname"
  value       = module.openshift_ai_roks.cluster_ingress_hostname
}

output "openshift_ai_dashboard_url" {
  description = "OpenShift AI dashboard URL"
  value       = module.openshift_ai_roks.openshift_ai_dashboard_url
}

output "deployment_summary" {
  description = "Deployment summary"
  value       = module.openshift_ai_roks.deployment_summary
}