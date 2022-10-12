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
  
project="$(gcloud config get core/project)"
zone="${2:-us-central1-f}"

network="default"
subnet="default"
 
benchmark_fs=${5:-benchmark-fs}
node_count=2

#
# the supported options are:
# - 'c' for a c2-standard-60
# - 'h' for an a2-highgpu-8g
# - 'm' for an a2-megagpu-16g
# - 'k' for compact placement
# - 'n' for the number of nodes
#
while getopts ":chkmn:" option; do
    case $option in
        c)
            if [ "X${machine_type}" == "X" ]; then
                machine_type="c2-standard-60"
            fi
            network_performance_configs="--network-performance-configs=total-egress-bandwidth-tier=TIER_1"
            ;;
        h)
            if [ "X${machine_type}" == "X" ]; then
                machine_type="a2-highgpu-8g"
            fi
            accelerator="--accelerator=count=8,type=nvidia-tesla-a100"
            ;;
        m)
            if [ "X${machine_type}" == "X" ]; then
                machine_type="a2-megagpu-16g"
            fi
            accelerator="--accelerator=count=16,type=nvidia-tesla-a100"           
            ;;
        k)
            resource_policy_name="benchmark-cluster"
            resource_policy="--resource-policies ${resource_policy_name}"
            ;;
        n) 
            node_count=$OPTARG
            ;;
    esac
done

if [ "X${machine_type}" == "X" ]; then
    echo "Must choose a machine type [c|h|m]"
    exit 1
fi

#
# creates a Filestore instance that offers a share named "home"
# - if the CMEK_KEY environment variable is defined it is used to encrypt the share
#
create_cluster_filesystem() {
    if [[ ! -z "${CMEK_KEY}" ]]; then
        local kms_key="--kms-key=${CMEK_KEY}"
    fi

    if [[ -z "$(gcloud filestore instances list --filter="name ~ ${benchmark_fs}" --format=text)" ]]; then
        gcloud filestore instances create ${benchmark_fs} \
            --zone=${zone} \
            --file-share=name=home,capacity=3TB \
            --network=name=${network} \
            --tier=basic-ssd \
            ${kms_key}
    fi
}

# creates a cluster of instances as specified by the command options
create_cluster_instances() {
    local image_project="${3:-cloud-hpc-image-public}"
    local image_family="${4:-hpc-centos-7}"
    local scopes="https://www.googleapis.com/auth/cloud-platform"
    local metadata_files="--metadata-from-file=startup-script=./benchmark-cluster-startup.sh,node-list=./nodes.txt"
    local metadata="--metadata=enable-oslogin=TRUE,nfs-addr=$(gcloud filestore instances list --filter="name ~ benchmark-fs" --format="value(networks[0].ipAddresses)")"

    # if the CMEK_KEY environment variable is defined it is used to encrypt each instances boot disk
    if [[ ! -z "${CMEK_KEY}" ]]; then
        local boot_disk_kms_key="--boot-disk-kms-key=${CMEK_KEY}"
    fi

    # generate a node list that will end up in /var/tmp on each of the nodes; it can be used as an MPI host list
    for nno in $(seq 1 $node_count); do echo node-$(printf "%03d" $nno); done > nodes.txt
    mapfile -t nodes < nodes.txt

    # create the nodes
    gcloud compute instances create ${nodes[@]} \
        --zone=${zone} \
        --image-project=${image_project} \
        --image-family=${image_family} \
        --machine-type=${machine_type} \
        --maintenance-policy=TERMINATE \
        --no-restart-on-failure \
        --provisioning-model=STANDARD \
        --network-interface=no-address,network-tier=PREMIUM,nic-type=GVNIC,network=${network},subnet=${subnet} \
        --boot-disk-type=pd-balanced \
        --scopes=${scopes} \
        --no-shielded-secure-boot \
        --shielded-vtpm \
        --shielded-integrity-monitoring \
        --reservation-affinity=any \
        ${boot_disk_kms_key} \
        ${resource_policy} \
        ${network_performance_configs} \
        ${accelerator} \
        ${metadata} \
        ${metadata_files}
}

main() {
  region="${zone%%-[a-f]}"

  # create a resource policy, if necessary, that specifies compact placement if it was requested
  if [ ! -z "${resource_policy_name}" ]; then
    if [ -z "$(gcloud compute resource-policies list --format=text)" ] || [ "X$(gcloud compute resource-policies list --filter="name ~ ${resource_policy_name}" --format="value(name)")" == "X" ]; then
      gcloud compute resource-policies create group-placement ${resource_policy_name} \
          --collocation=COLLOCATED \
          --region=${region} \
          --project=${project}
    fi
  fi

  create_cluster_filesystem
  create_cluster_instances
}

main $@
