terraform {
  backend "gcs" {
    bucket = "devoxx-udd"
    path = "terraform.tfstate"
    # project = "bogops-148814"
  }
}

provider "google" {
  project = "bogops-148814"
  region = "europe-west1"
}

resource "google_compute_network" "default" {
  name = "devoxx-udd"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "internal" {
  name = "devoxx-internal"
  network = "${google_compute_network.default.name}"
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ssh" {
  name = "devoxx-ssh"
  network = "${google_compute_network.default.name}"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

resource "google_compute_firewall" "https-haproxy" {
  name    = "devoxx-https-haproxy"
  network = "${google_compute_network.default.name}"
  target_tags = ["haproxy"]
  source_ranges=["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "ssh-haproxy" {
  name    = "devoxx-ssh-haproxy"
  network = "${google_compute_network.default.name}"
  target_tags = ["haproxy"]
  source_ranges=["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["2289"]
  }
}

resource "google_compute_firewall" "http-haproxy" {
  name    = "devoxx-http-haproxy"
  network = "${google_compute_network.default.name}"
  target_tags = ["haproxy"]
  source_ranges=["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_instance" "haproxy" {
  name = "devoxx-haproxy"
  zone = "europe-west1-c"
  machine_type = "n1-standard-1"
  network_interface {
    network = "${google_compute_network.default.self_link}"
    access_config {
      nat_ip = "35.187.13.176"
    }
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  tags = ["haproxy"]
}

resource "google_compute_instance" "udd" {
  name = "devoxx-udd"
  zone = "europe-west1-c"
  machine_type = "n1-standard-2"
  network_interface {
    network = "${google_compute_network.default.self_link}"
    access_config {
    }
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      size = 50
    }
  }
  service_account {
    email = "devoxx-udd@bogops-148814.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_write"]
  }
  tags = ["gitlab", "clair", "notary-signer", "notary-server", "registry", "portus"]
}
