##############################################################################
# OpenShift AI Namespace
##############################################################################

resource "kubernetes_namespace" "openshift_ai" {
  metadata {
    name = var.openshift_ai_config.namespace
    labels = {
      "openshift.io/cluster-monitoring" = "true"
      "opendatahub.io/dashboard"        = "true"
    }
  }
}

##############################################################################
# OpenShift AI Operator Subscription
##############################################################################

resource "kubernetes_manifest" "operator_group" {
  manifest = {
    apiVersion = "operators.coreos.com/v1"
    kind       = "OperatorGroup"
    metadata = {
      name      = "rhods-operator-group"
      namespace = var.openshift_ai_config.namespace
    }
    spec = {
      targetNamespaces = [var.openshift_ai_config.namespace]
    }
  }

  depends_on = [kubernetes_namespace.openshift_ai]
}

resource "kubernetes_manifest" "rhods_subscription" {
  manifest = {
    apiVersion = "operators.coreos.com/v1alpha1"
    kind       = "Subscription"
    metadata = {
      name      = "rhods-operator"
      namespace = var.openshift_ai_config.namespace
    }
    spec = {
      channel             = "stable"
      name                = "rhods-operator"
      source              = "redhat-operators"
      sourceNamespace     = "openshift-marketplace"
      installPlanApproval = "Automatic"
    }
  }

  depends_on = [kubernetes_manifest.operator_group]
}

##############################################################################
# Wait for Operator to be ready
##############################################################################

resource "time_sleep" "wait_for_operator" {
  depends_on = [kubernetes_manifest.rhods_subscription]

  create_duration = "5m"
}

##############################################################################
# DataScienceCluster Custom Resource
##############################################################################

resource "kubernetes_manifest" "data_science_cluster" {
  manifest = {
    apiVersion = "datasciencecluster.opendatahub.io/v1"
    kind       = "DataScienceCluster"
    metadata = {
      name = "default-dsc"
      labels = {
        "app.kubernetes.io/name"       = "datasciencecluster"
        "app.kubernetes.io/instance"   = "default"
        "app.kubernetes.io/part-of"    = "rhods-operator"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      components = {
        # Dashboard
        dashboard = {
          managementState = var.openshift_ai_config.enable_dashboard ? "Managed" : "Removed"
        }
        # Workbenches (Notebooks)
        workbenches = {
          managementState = var.openshift_ai_config.enable_notebook ? "Managed" : "Removed"
        }
        # Model Serving
        modelmeshserving = {
          managementState = var.openshift_ai_config.enable_model_serving ? "Managed" : "Removed"
        }
        kserve = {
          managementState = var.openshift_ai_config.enable_model_serving ? "Managed" : "Removed"
          serving = {
            ingressGateway = {
              certificate = {
                type = "SelfSigned"
              }
            }
            managementState = "Managed"
            name            = "knative-serving"
          }
        }
        # Data Science Pipelines
        datasciencepipelines = {
          managementState = "Managed"
        }
        # Code Server (VS Code)
        codeflare = {
          managementState = "Managed"
        }
        # Ray
        ray = {
          managementState = "Managed"
        }
        # Kueue (Job queueing)
        kueue = {
          managementState = "Managed"
        }
        # Training Operator
        trainingoperator = {
          managementState = "Managed"
        }
        # TrustyAI (Model monitoring)
        trustyai = {
          managementState = "Managed"
        }
        # Model Registry
        modelregistry = {
          managementState = "Managed"
        }
      }
    }
  }

  depends_on = [time_sleep.wait_for_operator]
}

##############################################################################
# Default Data Science Project (Namespace)
##############################################################################

resource "kubernetes_namespace" "default_ds_project" {
  metadata {
    name = "rhods-notebooks"
    labels = {
      "opendatahub.io/dashboard"              = "true"
      "modelmesh-enabled"                     = "true"
      "opendatahub.io/generated-namespace"    = "true"
    }
    annotations = {
      "openshift.io/description" = "Default namespace for OpenShift AI notebooks and models"
      "openshift.io/display-name" = "Data Science Project"
    }
  }

  depends_on = [kubernetes_manifest.data_science_cluster]
}

##############################################################################
# Notebook Image Streams
##############################################################################

resource "kubernetes_manifest" "notebook_imagestream" {
  for_each = toset(var.openshift_ai_config.notebook_images)

  manifest = {
    apiVersion = "image.openshift.io/v1"
    kind       = "ImageStream"
    metadata = {
      name      = each.value
      namespace = var.openshift_ai_config.namespace
      labels = {
        "opendatahub.io/notebook-image" = "true"
        "component.opendatahub.io/name" = each.value
      }
    }
    spec = {
      lookupPolicy = {
        local = true
      }
      tags = [
        {
          name = "latest"
          annotations = {
            "opendatahub.io/notebook-software" = "[{\"name\":\"Python\",\"version\":\"v3.9\"}]"
            "opendatahub.io/notebook-python-dependencies" = "[]"
            "openshift.io/imported-from" = "quay.io/opendatahub/workbench-images"
          }
          from = {
            kind = "DockerImage"
            name = "quay.io/opendatahub/workbench-images:jupyter-datascience-ubi9-python-3.9-latest"
          }
          referencePolicy = {
            type = "Source"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.data_science_cluster]
}

##############################################################################
# Storage Configuration for Notebooks
##############################################################################

resource "kubernetes_storage_class_v1" "notebook_storage" {
  metadata {
    name = "rhods-notebook-storage"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner    = "openshift-storage.cephfs.csi.ceph.com"
  reclaim_policy         = "Retain"
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

  depends_on = [kubernetes_manifest.data_science_cluster]
}

##############################################################################
# Wait for OpenShift AI to be fully ready
##############################################################################

resource "time_sleep" "wait_for_openshift_ai" {
  depends_on = [
    kubernetes_manifest.data_science_cluster,
    kubernetes_namespace.default_ds_project
  ]

  create_duration = "5m"
}