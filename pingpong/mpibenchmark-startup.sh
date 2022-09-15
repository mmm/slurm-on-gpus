#!/usr/bin/env bash

#yum update -y

# install benchmarking stuff
yum install -y mpich-3.2 mpitests-mpich32 iperf3

# setup hostbased authentication for MPI; note this depends on the nodes being named 'ping' and 'pong'
cd /etc/ssh

chmod u+s /usr/libexec/openssh/ssh-keysign

sed -i 's/#   HostbasedAuthentication no/    HostbasedAuthentication yes\n    EnableSSHkeysign yes/g' /etc/ssh/ssh_config

if [[ "$(hostname -f)" =~ ^ping ]]; then 
    peer=$(hostname -f | sed 's/^ping\(.*\)/pong\1/g')
else
    peer=$(hostname -f | sed 's/^pong\(.*\)/ping\1/g')
fi

ssh-keyscan ${peer} >> ssh_known_hosts

echo ${peer} >> shosts.equiv

sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/#IgnoreRhosts yes/IgnoreRhosts no/g' /etc/ssh/sshd_config

systemctl restart sshd
