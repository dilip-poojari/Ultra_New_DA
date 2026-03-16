##############################################################################
# IBM Cloud Logs Integration
##############################################################################

resource "ibm_ob_logging" "logging_instance" {
  count = var.log_analysis_instance_id != null ? 1 : 0

  cluster           = var.cluster_id
  instance_id       = var.log_analysis_instance_id
  private_endpoint  = true
}

##############################################################################
# IBM Cloud Monitoring Integration
##############################################################################

resource "ibm_ob_monitoring" "monitoring_instance" {
  count = var.monitoring_instance_id != null ? 1 : 0

  cluster           = var.cluster_id
  instance_id       = var.monitoring_instance_id
  private_endpoint  = true
}

##############################################################################
# OpenShift Logging Configuration
##############################################################################

resource "kubernetes_namespace" "openshift_logging" {
  count = var.log_analysis_instance_id != null ? 1 : 0

  metadata {
    name = "openshift-logging"
    labels = {
      "openshift.io/cluster-monitoring" = "true"
    }
  }
}

resource "kubernetes_manifest" "cluster_logging_operator_group" {
  count = var.log_analysis_instance_id != null ? 1 : 0

  manifest = {
    apiVersion = "operators.coreos.com/v1"
    kind       = "OperatorGroup"
    metadata = {
      name      = "cluster-logging"
      namespace = "openshift-logging"
    }
    spec = {
      targetNamespaces = ["openshift-logging"]
    }
  }

  depends_on = [kubernetes_namespace.openshift_logging]
}

resource "kubernetes_manifest" "cluster_logging_subscription" {
  count = var.log_analysis_instance_id != null ? 1 : 0

  manifest = {
    apiVersion = "operators.coreos.com/v1alpha1"
    kind       = "Subscription"
    metadata = {
      name      = "cluster-logging"
      namespace = "openshift-logging"
    }
    spec = {
      channel             = "stable"
      name                = "cluster-logging"
      source              = "redhat-operators"
      sourceNamespace     = "openshift-marketplace"
      installPlanApproval = "Automatic"
    }
  }

  depends_on = [kubernetes_manifest.cluster_logging_operator_group]
}

##############################################################################
# OpenShift Monitoring Configuration
##############################################################################

resource "kubernetes_config_map" "cluster_monitoring_config" {
  count = var.monitoring_instance_id != null ? 1 : 0

  metadata {
    name      = "cluster-monitoring-config"
    namespace = "openshift-monitoring"
  }

  data = {
    "config.yaml" = yamlencode({
      enableUserWorkload = true
      prometheusK8s = {
        retention = "15d"
        volumeClaimTemplate = {
          spec = {
            storageClassName = "ibmc-vpc-block-metro-retain-10iops-tier"
            resources = {
              requests = {
                storage = "100Gi"
              }
            }
          }
        }
      }
      alertmanagerMain = {
        volumeClaimTemplate = {
          spec = {
            storageClassName = "ibmc-vpc-block-metro-retain-10iops-tier"
            resources = {
              requests = {
                storage = "20Gi"
              }
            }
          }
        }
      }
    })
  }
}

resource "kubernetes_config_map" "user_workload_monitoring_config" {
  count = var.monitoring_instance_id != null ? 1 : 0

  metadata {
    name      = "user-workload-monitoring-config"
    namespace = "openshift-user-workload-monitoring"
  }

  data = {
    "config.yaml" = yamlencode({
      prometheus = {
        retention = "15d"
        volumeClaimTemplate = {
          spec = {
            storageClassName = "ibmc-vpc-block-metro-retain-10iops-tier"
            resources = {
              requests = {
                storage = "50Gi"
              }
            }
          }
        }
      }
    })
  }
}

##############################################################################
# ServiceMonitor for OpenShift AI
##############################################################################

resource "kubernetes_manifest" "openshift_ai_service_monitor" {
  count = var.monitoring_instance_id != null ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "openshift-ai-metrics"
      namespace = "redhat-ods-operator"
      labels = {
        "app.kubernetes.io/name" = "openshift-ai"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/part-of" = "rhods-operator"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
          path     = "/metrics"
        }
      ]
    }
  }
}

##############################################################################
# Grafana Dashboard for OpenShift AI (Optional)
##############################################################################

resource "kubernetes_config_map" "openshift_ai_dashboard" {
  count = var.monitoring_instance_id != null && var.create_grafana_dashboards ? 1 : 0

  metadata {
    name      = "openshift-ai-dashboard"
    namespace = "openshift-monitoring"
    labels = {
      "grafana_dashboard" = "1"
    }
  }

  data = {
    "openshift-ai-dashboard.json" = jsonencode({
      title = "OpenShift AI Metrics"
      panels = [
        {
          title = "Notebook Sessions"
          type  = "graph"
          targets = [
            {
              expr = "sum(notebook_sessions_total)"
            }
          ]
        },
        {
          title = "Model Serving Requests"
          type  = "graph"
          targets = [
            {
              expr = "rate(model_serving_requests_total[5m])"
            }
          ]
        }
      ]
    })
  }
}