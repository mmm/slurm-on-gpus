### benchmark_cluster
A script to create a cluster of GCP instances with which to do MPI benchmarking

## Setup
Make the script executable with the command

```bash
chmod a+x ./benchmark_cluster.sh
```

## Usage

```bash
./benchmark_cluster.sh -c|h|m[k][n<nodes-in-cluster>] [<zone>] [<zone> <image-project>] [<zone> <image-project> <image-family>] [<zone> <image-project> <image-family> <filestore name>]
```

Creates a cluster of `n` nodes, that may be part of a compact placement group, and that share a `/home` directory mounted from a Cloud Filestore
instance. Hostbased authentication is configured between all of the nodes so that MPI commands like `mpirun` and execute across the cluster. The list
nodes is stored in the file `/var/tmp/nodes.txt` on each node.

On the command line you specify the machine type, one of:
- c: `c2-standard-60`
- h: `a2-highgpu-8g`
- m: `a2-megagpu-16g`

Whether or not you want the nodes associated with a compact placement policy using the 'k' option

The 'n' flag specifies the number of nodes in the cluster, they will be named `node-001` thru `node-00n`

Finally, you can specify the `zone`, `image-project`, `image-family`, and `filestore name` if you want something other than the defaults:
- zone: `us-central1-f`
- image-project: `cloud-hpc-image-public`
- image-family: `hpc-centos-7`
- filestore name: `benchmark-fs`

If the `CMEK_KEY` environment variable is set to the name of a KMS key, that key will be used to encrypt the node boot disks
and the NFS share.

## Example

```bash
CMEK_KEY=<kms-key>; ./benchmark_cluster.sh -ckn4
```

Creates a cluster of 4 c2-standard-60 nodes in a compact placement group.
