// The environment stage.
variable "env" {}

// The zone that instances in this group should be created in.
variable "defZone" {}

variable "gcProject" {}
variable "gcRegion" {}

// The application port.
variable "websocketAPort" {}
variable "managerAPort" {}
variable "spawnerAPort" {}

// The image from which to initialize this disk.
variable "websocketIId" {}
variable "managerIId" {}
variable "spawnerIId" {}

// The machine type to create.
variable "websocketMType" {}
variable "managerMType" {}
variable "spawnerMType" {}
