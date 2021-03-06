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

locals {
  license_server_os_image = "centos-cloud/centos-7"
  license_server_machine_type = "c2-standard-4"
}

resource "google_compute_instance" "license-server" {
  name         = "license-server"
  machine_type = local.license_server_machine_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = local.license_server_os_image

    }
    kms_key_self_link = var.cmek_self_link
  }
  metadata = {
    enable-oslogin = "TRUE"
  }

  network_interface {
    network = "tutorial"
    subnetwork = "tutorial"
    network_ip = var.license_server_internal_static_ip

    #access_config {} # ephemeral public IP... comment this out for private-only networking
  }

  #metadata_startup_script = file("provision.sh")

  service_account {
    email = var.service_account
    #scopes = ["userinfo-email", "compute-ro", "storage-full"]
    scopes = ["cloud-platform"]  # too permissive for production
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm = true
    enable_integrity_monitoring = true
  }

}
