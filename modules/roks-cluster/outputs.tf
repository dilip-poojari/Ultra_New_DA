output "cluster_id" {
  description = "ID of the OpenShift cluster"
  value       = ibm_container_vpc_cluster.cluster.id
}

output "cluster_name" {
  description = "Name of the OpenShift cluster"
  value       = ibm_container_vpc_cluster.cluster.name
}

output "cluster_crn" {
  description = "CRN of the OpenShift cluster"
  value       = ibm_container_vpc_cluster.cluster.crn
}

output "ingress_hostname" {
  description = "Ingress hostname for the cluster"
  value       = ibm_container_vpc_cluster.cluster.ingress_hostname
}

output "master_url" {
  description = "Master URL for the cluster"
  value       = ibm_container_vpc_cluster.cluster.master_url
}

output "cluster_version" {
  description = "OpenShift version of the cluster"
  value       = ibm_container_vpc_cluster.cluster.kube_version
}

output "cluster_state" {
  description = "State of the cluster"
  value       = ibm_container_vpc_cluster.cluster.state
}

output "public_service_endpoint_url" {
  description = "Public service endpoint URL"
  value       = ibm_container_vpc_cluster.cluster.public_service_endpoint_url
}

output "private_service_endpoint_url" {
  description = "Private service endpoint URL"
  value       = ibm_container_vpc_cluster.cluster.private_service_endpoint_url
}

output "worker_pools" {
  description = "Information about worker pools"
  value = {
    default = {
      id     = ibm_container_vpc_cluster.cluster.id
      flavor = ibm_container_vpc_cluster.cluster.flavor
      count  = ibm_container_vpc_cluster.cluster.worker_count
    }
    additional = {
      for k, v in ibm_container_vpc_worker_pool.additional_pool : k => {
        id     = v.id
        name   = v.worker_pool_name
        flavor = v.flavor
        count  = v.worker_count
      }
    }
  }
}

output "resource_group_id" {
  description = "Resource group ID of the cluster"
  value       = ibm_container_vpc_cluster.cluster.resource_group_id
}

output "vpc_id" {
  description = "VPC ID of the cluster"
  value       = ibm_container_vpc_cluster.cluster.vpc_id
}

output "ingress_secret" {
  description = "Ingress secret name"
  value       = ibm_container_vpc_cluster.cluster.ingress_secret
  sensitive   = true
}

output "albs" {
  description = "Application Load Balancers"
  value       = ibm_container_vpc_cluster.cluster.albs
}