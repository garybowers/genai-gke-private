locals {
  services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

resource "random_integer" "salt" {
  min = 10000
  max = 99999
}

resource "google_project" "project" {
  name                = "gen-ai-gke-demo"
  project_id          = "gen-ai-gke-demo-${random_integer.salt.result}"
  folder_id           = var.parent_folder
  billing_account     = var.billing_account
  auto_create_network = false
}

resource "google_project_service" "project_apis" {
  project = google_project.project.project_id
  count   = length(local.services)
  service = element(local.services, count.index)

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_compute_project_metadata" "oslogin" {
  project = google_project.project.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
