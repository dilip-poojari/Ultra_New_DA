output "storage_class_name" {
  description = "Name of the default ODF storage class"
  value       = kubernetes_storage_class_v1.rbd.metadata[0].name
}

output "cephfs_storage_class_name" {
  description = "Name of the CephFS storage class (for RWX volumes)"
  value       = kubernetes_storage_class_v1.cephfs.metadata[0].name
}

output "rbd_storage_class_name" {
  description = "Name of the RBD storage class (for RWO volumes)"
  value       = kubernetes_storage_class_v1.rbd.metadata[0].name
}

output "odf_version" {
  description = "Version of ODF installed"
  value       = var.odf_version
}

output "odf_namespace" {
  description = "Namespace where ODF is installed"
  value       = var.odf_config.namespace
}

output "odf_status" {
  description = "Status of ODF installation"
  value = {
    namespace_exists = data.kubernetes_namespace.odf_status.metadata[0].name != null
    addon_installed  = true
    storage_classes = {
      cephfs = kubernetes_storage_class_v1.cephfs.metadata[0].name
      rbd    = kubernetes_storage_class_v1.rbd.metadata[0].name
    }
  }
}

output "storage_cluster_name" {
  description = "Name of the ODF storage cluster"
  value       = "ocs-storagecluster"
}

output "encryption_enabled" {
  description = "Whether encryption is enabled for the storage cluster"
  value       = var.odf_config.cluster_encryption
}

output "billing_type" {
  description = "Billing type for ODF"
  value       = var.odf_config.billing_type
}