provider "google" {
  credentials = "${file("../../../account.json")}"
  project     = "${var.gcProject}"
  region      = "${var.gcRegion}"
}
