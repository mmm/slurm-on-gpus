#!/bin/bash
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

export DEBIAN_FRONTEND=noninteractive

apt-get -qqy update
apt-get -qqy upgrade

apt-get -qqy install \
  build-essential

# maybe `--no-install-recommends`?

# install terraform and packer
# perhaps a better idea to mix with a hashicorp dev image?
# RUN
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository --yes "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get -qq update
apt-get -qq install -y terraform packer

# install go and deps
# perhaps a better idea to mix with a go dev image?
# RUN
#curl -O -L https://go.dev/dl/go1.19.linux-amd64.tar.gz
#rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
curl -O -L https://go.dev/dl/go1.18.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
#sed -e 's|"$|:/usr/local/go/bin"|g' -i /etc/environment
echo "export GOPATH=/usr/local/go" >> /etc/environment
echo "export PATH=\$PATH:\$GOPATH/bin" >> /etc/environment
source /etc/environment

# install hpc toolkit
# RUN
git clone https://github.com/GoogleCloudPlatform/hpc-toolkit.git
cd hpc-toolkit
git checkout v1.10.1
make
mv ghpc /usr/local/bin/
ghpc --version


apt-get -qq autoremove -y
apt-get -qq clean

rm -rf /var/lib/apt/lists/*

#"rm -f /etc/sudoers.d/90-cloud-init-users",
#"/usr/bin/gpasswd -d packer ubuntu",
#"/usr/bin/touch /var/mail/ubuntu",
#"/usr/sbin/userdel -r -f ubuntu"
