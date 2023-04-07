#!/usr/bin/env bash
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eo pipefail
[ ! -z "${DEBUG:-}" ] && set -x

zone=$1
project="${2:-$GOOGLE_CLOUD_PROJECT}"

create_pingpong_instances() {
  local zone="${1:-us-central1-f}"
  local image_project="${2:-cloud-hpc-image-public}"
  local image_family="${3:-hpc-centos-7}"
  local network="tutorial"
  local subnet="tutorial"
  local scopes="https://www.googleapis.com/auth/cloud-platform"
  local instance_names="ping pong"
  local resource_policy="pingpong"
  local startup_script="--metadata-from-file=startup-script=./mpibenchmark-startup.sh"

  ############
  # c2 tests
  ############
  local machine_type="c2-standard-60"
  local network_performance_configs="--network-performance-configs=total-egress-bandwidth-tier=TIER_1"

  ##############
  # a2 tests 8g
  ##############
  #local machine_type="a2-highgpu-8g"
  #local accelerator="--accelerator=count=8,type=nvidia-tesla-a100"

  #####################
  # a2 tests ultra 8g
  #####################
  # local machine_type="a2-ultragpu-8g"
  # local accelerator="--accelerator=count=8,type=nvidia-tesla-a100"

  ##############
  # a2 tests 16g
  ##############
  #local machine_type="a2-megagpu-16g"
  #local accelerator="--accelerator=count=16,type=nvidia-tesla-a100"

  gcloud compute instances create ${instance_names} \
    --zone=${zone} \
    --image-project=${image_project} \
    --image-family=${image_family} \
    --machine-type=${machine_type} \
    --maintenance-policy=TERMINATE \
    --no-restart-on-failure \
    --resource-policies ${resource_policy} \
    --provisioning-model=STANDARD \
    --network-interface=no-address,network-tier=PREMIUM,nic-type=GVNIC,network=${network},subnet=${subnet} \
    --boot-disk-type=pd-balanced \
    --scopes=${scopes} \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    ${network_performance_configs} \
    ${accelerator} \
    ${startup_script}
}

main() {

  resource_policy="pingpong"
  region="${zone%%-[a-f]}"
  if [ "X$(gcloud compute resource-policies list --filter="name ~ ${resource_policy}" --format="value(name)")" == "X" ]; then
    gcloud compute resource-policies create group-placement ${resource_policy} \
        --collocation=COLLOCATED \
        --region=${region} \
        --project=${project}
  fi

  create_pingpong_instances ${zone} 
  #create_pingpong_instances ${zone} centos-cloud centos-7
  #create_pingpong_instances ${zone} ${project} custom-rocky-8


}
main $@

