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
  tutorial_service_account_roles = [
    "roles/compute.instanceAdmin.v1",
    "roles/compute.instanceAdmin", # Beta
    "roles/compute.storageAdmin",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

data "google_project" "project" {}

resource "google_service_account" "tutorial_service_account" {
  account_id   = "tutorial-service-account"
  display_name = "tutorial-service-account"
}

# resource "google_service_account_iam_binding" "admin-account-iam" {
#   service_account_id = google_service_account.tutorial_service_account.id
#   role               = "roles/iam.serviceAccountUser"

#   members = var.tutorial-service-account-users
# }

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(local.tutorial_service_account_roles)

  project = data.google_project.project.name
  member  = "serviceAccount:${google_service_account.tutorial_service_account.email}"
  role   = each.value
}

resource "google_kms_key_ring" "tutorial_keyring" {
  name     = "tutorial-keyring"
  location = "global"
}

resource "google_kms_crypto_key" "tutorial_cmek" {
  name            = "tutorial-cmek"
  key_ring        = google_kms_key_ring.tutorial_keyring.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.tutorial_cmek.id
  role          = "roles/owner"

  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}

resource "google_kms_key_ring_iam_binding" "key_ring" {
  key_ring_id = google_kms_key_ring.tutorial_keyring.id
  role        = "roles/owner"

  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}
