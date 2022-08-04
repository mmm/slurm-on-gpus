#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "gcp_project_id" {
  type    = string
  default = ""
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "googlecompute" "gcp_centos_7" {
  disk_size           = "100"
  machine_type        = "n2-standard-4"
  project_id          = "${var.gcp_project_id}"
  source_image_family = "centos-7"
  ssh_username        = "centos"
  zone                = "us-central1-f"
  network             = "default"
  #omit_external_ip    = "false"
  #use_internal_ip     = "true"
}

build {
  name                = "gnome"

  source "source.googlecompute.gcp_centos_7" {
    image_family        = "centos-7-bare"
    image_name          = "centos-7-bare-${local.timestamp}"
    image_description   = "custom centos-7 image"
  }

  #provisioner "shell" {
  #  execute_command = "chmod +x {{ .Path }}; sudo bash -c '{{ .Vars }} {{ .Path }}'"
  #  inline = [
  #    "yum install -y ansible",
  #    "mkdir -p /tmp/cottontail-install/ansible",
  #    "chown -Rf centos:centos /tmp/cottontail-install",
  #  ]
  #}
  #provisioner "file" {
  #  source = "ansible/"
  #  destination = "/tmp/cottontail-install/ansible"
  #}
  #provisioner "shell" {
  #  execute_command = "chmod +x {{ .Path }}; sudo bash -c '{{ .Vars }} {{ .Path }}'"
  #  inline = [
  #    "cd /tmp/cottontail-install/ansible",
  #    "ansible-playbook playbook.yml --connection=local --inventory-file=local.inventory",
  #  ]
  #}
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo bash -c '{{ .Vars }} {{ .Path }}'"
    scripts         = fileset(".", "scripts/*")
  }
}
