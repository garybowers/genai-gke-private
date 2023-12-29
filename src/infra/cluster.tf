locals {
  region = "europe-west1"
  whitelist_ips = [
    {
      cidr_block   = google_compute_subnetwork.subnet[0].ip_cidr_range
      display_name = "local cidr"
    }
  ]
}

data "google_compute_zones" "zones" {
  project = google_project.project.project_id
  region = local.region
}

resource "random_shuffle" "zone" {
  input        = data.google_compute_zones.zones.names 
  result_count = 1
}


resource "random_id" "postfix" {
  byte_length = 4
}

resource "google_artifact_registry_repository" "registry" {
  project       = google_project.project.project_id
  location      = local.region
  repository_id = "main-repo"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "registry-member" {
  project    = google_artifact_registry_repository.registry.project
  repository = google_artifact_registry_repository.registry.name
  location   = google_artifact_registry_repository.registry.location
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_service_account" "service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-cluster1-gke-${random_id.postfix.hex}"
  display_name = "${var.prefix}-cluster1-gke-${random_id.postfix.hex}"
}

resource "google_project_iam_member" "service_account_log_writer" {
  project = google_project.project.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "service_account_metric_writer" {
  project = google_project.project.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "service_account_monitoring_viewer" {
  project = google_project.project.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_container_cluster" "cluster" {
  project  = google_project.project.project_id
  name     = "${var.prefix}-${random_id.postfix.hex}"
  location = random_shuffle.zone.result[0] 

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet[0].self_link

  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_endpoint = "true"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "192.168.1.0/28"
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = local.whitelist_ips
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = lookup(cidr_blocks.value, "display_name", null)
      }
    }
  }
  
  workload_identity_config {
    workload_pool = "${google_project.project.project_id}.svc.id.goog"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  deletion_protection = false
}
