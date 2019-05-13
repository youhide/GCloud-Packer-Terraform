resource "google_compute_target_pool" "websocket" {
  name = "websocket-${var.env}-pool-${var.gcRegion}"
  session_affinity = "CLIENT_IP"
}

resource "google_compute_forwarding_rule" "websocket" {
  name       = "websocket-${var.env}-forwarding-rule"
  target     = "${google_compute_target_pool.websocket.self_link}"
  port_range = "${var.websocketAPort}"
}

resource "google_compute_health_check" "websocket" {
  name = "websocket-${var.env}-health-check-${var.gcRegion}"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "${var.websocketAPort}"
  }
}

resource "google_compute_instance_group_manager" "websocket" {
  name = "websocket-${var.env}"

  base_instance_name = "websocket-${var.env}"
  instance_template  = "${google_compute_instance_template.websocket.self_link}"
  update_strategy    = "NONE"
  zone               = "${var.defZone}"

  target_pools = ["${google_compute_target_pool.websocket.self_link}"]
  target_size  = 1

  named_port {
    name = "websocket-port"
    port = "${var.websocketAPort}"
  }

  auto_healing_policies {
    health_check      = "${google_compute_health_check.websocket.self_link}"
    initial_delay_sec = 300
  }
}

resource "google_compute_instance_template" "websocket" {
  name        = "websocket-${var.env}-template-${var.gcRegion}"
  description = "Websocket Server Instance Template (${var.env})"
  depends_on = ["google_compute_network.default"]

  labels = {
    environment = "${var.env}"
  }

  instance_description = "Websocket Server Instance Template (${var.env})"
  machine_type         = "${var.websocketMType}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "${var.websocketIId}"
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

resource "google_compute_autoscaler" "websocket" {
  name   = "websocket-${var.env}-scaler"
  zone   = "${var.defZone}"
  target = "${google_compute_instance_group_manager.websocket.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
