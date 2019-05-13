resource "google_compute_target_pool" "spawner" {
  name = "spawner-${var.env}-pool-${var.gcRegion}"
}

resource "google_compute_forwarding_rule" "spawner" {
  name       = "spawner-${var.env}-forwarding-rule"
  target     = "${google_compute_target_pool.spawner.self_link}"
  port_range = "${var.spawnerAPort}"
}

resource "google_compute_health_check" "spawner" {
  name = "spawner-${var.env}-health-check-${var.gcRegion}"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "${var.spawnerAPort}"
  }
}

resource "google_compute_instance_group_manager" "spawner" {
  name = "spawner-${var.env}"

  base_instance_name = "spawner-${var.env}"
  instance_template  = "${google_compute_instance_template.spawner.self_link}"
  update_strategy    = "NONE"
  zone               = "${var.defZone}"

  target_pools = ["${google_compute_target_pool.spawner.self_link}"]
  target_size  = 1

  named_port {
    name = "spawner-port"
    port = "${var.spawnerAPort}"
  }

  auto_healing_policies {
    health_check      = "${google_compute_health_check.spawner.self_link}"
    initial_delay_sec = 300
  }
}

resource "google_compute_instance_template" "spawner" {
  name        = "spawner-${var.env}-template-${var.gcRegion}"
  description = "spawner Server Instance Template (${var.env})"
  depends_on = ["google_compute_network.default"]

  labels = {
    environment = "${var.env}"
  }

  instance_description = "spawner Server Instance Template (${var.env})"
  machine_type         = "${var.spawnerMType}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "${var.spawnerIId}"
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

resource "google_compute_autoscaler" "spawner" {
  name   = "spawner-${var.env}-scaler"
  zone   = "${var.defZone}"
  target = "${google_compute_instance_group_manager.spawner.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
