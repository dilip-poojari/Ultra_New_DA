output "namespace" {
  description = "Namespace where OpenShift AI is installed"
  value       = kubernetes_namespace.openshift_ai.metadata[0].name
}

output "operator_namespace" {
  description = "Namespace where OpenShift AI operator is installed"
  value       = var.openshift_ai_config.operator_namespace
}

output "dashboard_url" {
  description = "URL for OpenShift AI dashboard"
  value       = "https://rhods-dashboard-${var.openshift_ai_config.namespace}.apps.${var.cluster_id}.cloud.ibm.com"
}

output "installation_status" {
  description = "Status of OpenShift AI installation"
  value = {
    namespace_created       = kubernetes_namespace.openshift_ai.metadata[0].name
    operator_subscribed     = true
    data_science_cluster    = "default-dsc"
    default_project_created = kubernetes_namespace.default_ds_project.metadata[0].name
  }
}

output "notebook_images" {
  description = "List of enabled notebook images"
  value       = var.openshift_ai_config.notebook_images
}

output "model_serving_enabled" {
  description = "Whether model serving is enabled"
  value       = var.openshift_ai_config.enable_model_serving
}

output "notebook_controller_enabled" {
  description = "Whether notebook controller is enabled"
  value       = var.openshift_ai_config.enable_notebook
}

output "dashboard_enabled" {
  description = "Whether dashboard is enabled"
  value       = var.openshift_ai_config.enable_dashboard
}

output "default_project_namespace" {
  description = "Default data science project namespace"
  value       = kubernetes_namespace.default_ds_project.metadata[0].name
}

output "storage_class_name" {
  description = "Storage class used for notebooks"
  value       = kubernetes_storage_class_v1.notebook_storage.metadata[0].name
}

output "components_enabled" {
  description = "List of enabled OpenShift AI components"
  value = {
    dashboard            = var.openshift_ai_config.enable_dashboard
    workbenches          = var.openshift_ai_config.enable_notebook
    model_serving        = var.openshift_ai_config.enable_model_serving
    data_science_pipelines = true
    codeflare            = true
    ray                  = true
    kueue                = true
    training_operator    = true
    trustyai             = true
    model_registry       = true
  }
}