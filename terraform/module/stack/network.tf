resource "google_compute_network" "default" {
  name                    = "${var.env}-network-${var.gcRegion}"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "default" {
  name    = "${var.env}-firewall-${var.gcRegion}"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["${var.websocketAPort}", "${var.managerAPort}", "${var.spawnerAPort}"]
  }
}
