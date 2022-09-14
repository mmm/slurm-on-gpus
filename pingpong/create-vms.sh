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

project=$1
region=$2
zone=$3
resource_policy=$4
machine_type=$5

if [ "X$(gcloud compute resource-policies list --filter="name ~ ${resource_policy}" --format="value(name)")" == "X" ]; then
    gcloud compute resource-policies create group-placement ${resource_policy} \
        --collocation=COLLOCATED \
        --region=${region} \
        --project=${project}
fi

gcloud compute instances create ping pong \
    --zone=${zone} \
    --image-family=hpc-centos-7 \
    --image-project=cloud-hpc-image-public \
    --maintenance-policy=TERMINATE \
    --no-restart-on-failure \
    --resource-policies ${resource_policy} \
    --network-interface=nic-type=GVNIC \
    --network-performance-configs=total-egress-bandwidth-tier=TIER_1 \
    --network-tier=PREMIUM \
    --machine-type=${machine_type} \
    --metadata-from-file=startup-script=./mpibenchmark-startup.sh
