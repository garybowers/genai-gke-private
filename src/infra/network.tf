locals {
  subnets = [
    {
      region = "europe-west1",
      cidr   = "10.4.0.0/16",
      name   = "eu-w1"
    },
  ]

}

resource "google_compute_network" "vpc" {
  name                    = "${var.prefix}-vpc"
  project                 = google_project.project.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count                    = length(local.subnets)
  name                     = "${var.prefix}-${local.subnets[count.index]["name"]}"
  project                  = google_project.project.project_id
  network                  = google_compute_network.vpc.self_link
  region                   = local.subnets[count.index]["region"]
  ip_cidr_range            = local.subnets[count.index]["cidr"]
  private_ip_google_access = true
}

resource "google_compute_firewall" "fw-default-deny" {
  project = google_project.project.project_id
  name    = "${var.prefix}-defauly-deny-all"
  network = google_compute_network.vpc.name

  deny {
    protocol = "all"
  }
  priority      = "65535"
  source_ranges = ["0.0.0.0/0"]
}
