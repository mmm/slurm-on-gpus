#!/usr/bin/env bash

# mount /home from the Filestore instance with IP address specified via metadata
nfs_addr="$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nfs-addr" -H "Metadata-Flavor: Google")"

mount -t nfs -o defaults,hard,intr,_netdev ${nfs_addr}:/home /home

sleep 15

# setup hostbased authentication for MPI; this happens on every node so the interconnect graph is complete
curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/node-list" -H "Metadata-Flavor: Google" --output /var/tmp/nodes.txt

cd /etc/ssh

chmod u+s /usr/libexec/openssh/ssh-keysign

sed -i 's/#   HostbasedAuthentication no/    HostbasedAuthentication yes\n    EnableSSHkeysign yes/g' /etc/ssh/ssh_config

while IFS= read -r peer; do
    if [[ ! "^$(hostname)" =~ "${peer}" ]]; then
        # wait for the peer to be ready
        while [[ -z "$(ping ${peer} -c1 2>&1 | grep 'packets transmitted')" ]]; do sleep 2; done

        # full hostnames are required to make hostbased authentication happy
        full_peer=$(ping ${peer} -c1 | grep ^PING | cut -d' ' -f2)

        # this is the hostbased authentication magic
        ssh-keyscan ${full_peer} >> ssh_known_hosts
        echo ${full_peer} >> shosts.equiv
    fi
done < /var/tmp/nodes.txt

sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/#IgnoreRhosts yes/IgnoreRhosts no/g' /etc/ssh/sshd_config

systemctl restart sshd
