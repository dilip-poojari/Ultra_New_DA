##############################################################################
# OpenShift Data Foundation (ODF) Addon
##############################################################################

resource "ibm_container_addons" "odf" {
  cluster           = var.cluster_id
  resource_group_id = var.resource_group_id

  addons {
    name    = "openshift-data-foundation"
    version = var.odf_version
  }

  timeouts {
    create = "1h"
    update = "1h"
  }
}

##############################################################################
# Wait for ODF to be ready
##############################################################################

resource "time_sleep" "wait_for_odf_addon" {
  depends_on = [ibm_container_addons.odf]

  create_duration = "10m"
}

##############################################################################
# ODF Storage Cluster Configuration (via Kubernetes)
##############################################################################

resource "kubernetes_namespace" "openshift_storage" {
  metadata {
    name = var.odf_config.namespace
    labels = {
      "openshift.io/cluster-monitoring" = "true"
    }
  }

  depends_on = [time_sleep.wait_for_odf_addon]
}

# Storage Cluster Custom Resource
resource "kubernetes_manifest" "storage_cluster" {
  manifest = {
    apiVersion = "ocs.openshift.io/v1"
    kind       = "StorageCluster"
    metadata = {
      name      = "ocs-storagecluster"
      namespace = var.odf_config.namespace
    }
    spec = {
      manageNodes = false
      monDataDirHostPath = "/var/lib/rook"
      storageDeviceSets = [
        {
          name  = "ocs-deviceset"
          count = 1
          dataPVCTemplate = {
            spec = {
              storageClassName = "ibmc-vpc-block-metro-retain-10iops-tier"
              accessModes      = ["ReadWriteOnce"]
              volumeMode       = "Block"
              resources = {
                requests = {
                  storage = "512Gi"
                }
              }
            }
          }
          portable = true
          replica  = 3
        }
      ]
      encryption = {
        enable = var.odf_config.cluster_encryption
      }
      flexibleScaling = true
      resources = {
        mds = {
          limits = {
            cpu    = "3"
            memory = "8Gi"
          }
          requests = {
            cpu    = "1"
            memory = "8Gi"
          }
        }
        rgw = {
          limits = {
            cpu    = "2"
            memory = "4Gi"
          }
          requests = {
            cpu    = "1"
            memory = "4Gi"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.openshift_storage,
    time_sleep.wait_for_odf_addon
  ]
}

##############################################################################
# Wait for Storage Cluster to be ready
##############################################################################

resource "time_sleep" "wait_for_storage_cluster" {
  depends_on = [kubernetes_manifest.storage_cluster]

  create_duration = "15m"
}

##############################################################################
# Storage Classes
##############################################################################

# CephFS Storage Class (for RWX volumes - notebooks)
resource "kubernetes_storage_class_v1" "cephfs" {
  metadata {
    name = "ocs-storagecluster-cephfs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner    = "openshift-storage.cephfs.csi.ceph.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "Immediate"

  parameters = {
    clusterID = "openshift-storage"
    fsName    = "ocs-storagecluster-cephfilesystem"
    pool      = "ocs-storagecluster-cephfilesystem-data0"
    "csi.storage.k8s.io/provisioner-secret-name"       = "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace"  = "openshift-storage"
    "csi.storage.k8s.io/controller-expand-secret-name" = "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" = "openshift-storage"
    "csi.storage.k8s.io/node-stage-secret-name"        = "rook-csi-cephfs-node"
    "csi.storage.k8s.io/node-stage-secret-namespace"   = "openshift-storage"
  }

  depends_on = [time_sleep.wait_for_storage_cluster]
}

# RBD Storage Class (for RWO volumes - PVCs)
resource "kubernetes_storage_class_v1" "rbd" {
  metadata {
    name = "ocs-storagecluster-ceph-rbd"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "openshift-storage.rbd.csi.ceph.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "Immediate"

  parameters = {
    clusterID = "openshift-storage"
    pool      = "ocs-storagecluster-cephblockpool"
    imageFeatures = "layering"
    "csi.storage.k8s.io/provisioner-secret-name"       = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace"  = "openshift-storage"
    "csi.storage.k8s.io/controller-expand-secret-name" = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" = "openshift-storage"
    "csi.storage.k8s.io/node-stage-secret-name"        = "rook-csi-rbd-node"
    "csi.storage.k8s.io/node-stage-secret-namespace"   = "openshift-storage"
  }

  depends_on = [time_sleep.wait_for_storage_cluster]
}

##############################################################################
# Data Sources for Status
##############################################################################

data "kubernetes_namespace" "odf_status" {
  metadata {
    name = var.odf_config.namespace
  }

  depends_on = [time_sleep.wait_for_storage_cluster]
}