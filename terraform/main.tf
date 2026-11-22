terraform {
  required_providers {
    docker = { source = "kreuzwerker/docker", version = "~> 3.0.0" }
    local  = { source = "hashicorp/local" }
  }
}
provider "docker" {}

resource "docker_container" "nodes" {
  count   = 3
  name    = "node-${count.index + 1}"
  image   = "ubuntu:22.04"
  command = ["tail", "-f", "/dev/null"]
}

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [webservers]
    ${docker_container.nodes[0].name} ansible_connection=community.docker.docker ansible_python_interpreter=/usr/bin/python3
    [appservers]
    ${docker_container.nodes[1].name} ansible_connection=community.docker.docker ansible_python_interpreter=/usr/bin/python3
    [dbservers]
    ${docker_container.nodes[2].name} ansible_connection=community.docker.docker ansible_python_interpreter=/usr/bin/python3
  EOT
}
