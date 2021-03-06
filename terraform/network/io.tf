#
# Copyright 2020 Google LLC
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

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "tags" {
  default = []
}

output "tutorial-network-name" {
  value = google_compute_network.tutorial.name
}

output "tutorial-subnet-name" {
  value = google_compute_subnetwork.tutorial.name
}

output "license-server-internal-static-ip" {
  value = google_compute_address.licenser-server-address.address
}
