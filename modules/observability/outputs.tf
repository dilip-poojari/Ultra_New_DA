output "logging_enabled" {
  description = "Whether logging is enabled"
  value       = var.log_analysis_instance_id != null
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.monitoring_instance_id != null
}

output "log_analysis_instance_id" {
  description = "ID of the Log Analysis instance"
  value       = var.log_analysis_instance_id
}

output "monitoring_instance_id" {
  description = "ID of the Monitoring instance"
  value       = var.monitoring_instance_id
}

output "logging_integration_status" {
  description = "Status of logging integration"
  value = var.log_analysis_instance_id != null ? {
    enabled           = true
    instance_id       = var.log_analysis_instance_id
    private_endpoint  = true
    namespace         = "openshift-logging"
  } : null
}

output "monitoring_integration_status" {
  description = "Status of monitoring integration"
  value = var.monitoring_instance_id != null ? {
    enabled           = true
    instance_id       = var.monitoring_instance_id
    private_endpoint  = true
    user_workload_monitoring = true
  } : null
}

output "grafana_dashboards_created" {
  description = "Whether Grafana dashboards were created"
  value       = var.monitoring_instance_id != null && var.create_grafana_dashboards
}