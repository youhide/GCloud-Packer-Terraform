module "us-east4" {
  source          = "../../module/stack" // ⚠️
  gcProject       = "playgroundtest-204913" // Google Project name
  gcRegion        = "us-east4" // Running region
  env             = "production" // The environment stage.
  websocketIId    = "${file("./websocket.ami")}" // WebSocket AMI
  managerIId      = "${file("./manager.ami")}" // Manager AMI
  spawnerIId      = "${file("./spawner.ami")}" // Spawner AMI
  defZone         = "us-east4-a" // The zone that instances in this group should be created in.
  websocketMType  = "f1-micro" // Websocket machine type to create.
  managerMType    = "f1-micro" // Manager machine type to create.
  spawnerMType    = "f1-micro" // Spawner machine type to create.
  websocketAPort  = "8080" // Websocket application port.
  managerAPort    = "8081" // Manager application port.
  spawnerAPort    = "8082" // Spawner application port.
}

module "southamerica-east1" {
  source          = "../../module/stack" // ⚠️
  gcProject       = "playgroundtest-204913" // Google Project name
  gcRegion        = "southamerica-east1" // Running region
  env             = "production" // The environment stage.
  websocketIId    = "${file("./websocket.ami")}" // WebSocket AMI
  managerIId      = "${file("./manager.ami")}" // Manager AMI
  spawnerIId      = "${file("./spawner.ami")}" // Spawner AMI
  defZone         = "southamerica-east1-a" // The zone that instances in this group should be created in.
  websocketMType  = "f1-micro" // Websocket machine type to create.
  managerMType    = "f1-micro" // Manager machine type to create.
  spawnerMType    = "f1-micro" // Spawner machine type to create.
  websocketAPort  = "8080" // Websocket application port.
  managerAPort    = "8081" // Manager application port.
  spawnerAPort    = "8082" // Spawner application port.
}
