#!/usr/bin/env bash

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
