resource "google_compute_target_pool" "manager" {
  name = "manager-${var.env}-pool-${var.gcRegion}"
}

resource "google_compute_forwarding_rule" "manager" {
  name       = "manager-${var.env}-forwarding-rule"
  target     = "${google_compute_target_pool.manager.self_link}"
  port_range = "${var.managerAPort}"
}

resource "google_compute_health_check" "manager" {
  name = "manager-${var.env}-health-check-${var.gcRegion}"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "${var.managerAPort}"
  }
}

resource "google_compute_instance_group_manager" "manager" {
  name = "manager-${var.env}"

  base_instance_name = "manager-${var.env}"
  instance_template  = "${google_compute_instance_template.manager.self_link}"
  update_strategy    = "NONE"
  zone               = "${var.defZone}"

  target_pools = ["${google_compute_target_pool.manager.self_link}"]
  target_size  = 1

  named_port {
    name = "manager-port"
    port = "${var.managerAPort}"
  }

  auto_healing_policies {
    health_check      = "${google_compute_health_check.manager.self_link}"
    initial_delay_sec = 300
  }
}

resource "google_compute_instance_template" "manager" {
  name        = "manager-${var.env}-template-${var.gcRegion}"
  description = "manager Server Instance Template (${var.env})"
  depends_on = ["google_compute_network.default"]

  labels = {
    environment = "${var.env}"
  }

  instance_description = "manager Server Instance Template (${var.env})"
  machine_type         = "${var.managerMType}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "${var.managerIId}"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "${var.env}-network-${var.gcRegion}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_autoscaler" "manager" {
  name   = "manager-${var.env}-scaler"
  zone   = "${var.defZone}"
  target = "${google_compute_instance_group_manager.manager.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
