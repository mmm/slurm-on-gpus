# PingPong 

Script to create a pair of Compute Engine instances, named "ping" and "pong", with which to do simple MPI benchmarking

## Usage

The command:

```bash
./create-vms.sh PROJECT REGION ZONE RESOURCE_POLICY MACHINE_TYPE
```

Creates the instance `ping` and `pong` with IPERF3, MPICH 3.2, and the associated OSU microbenchmarks installed.
If the named resource policy does not exist it will be created. You can delete the nodes at anytime and leave the 
resource policy in place so that it can be reused. The startup script also configures hostbased authentication so 
that MPI works between nodes. You may need to do a manual `ssh` to establish a fingerprint; after that no prompts 
should appear.

## Benchmarking

The OSU microbenchmarks are in /usr/lib64/mpich3.2/bin. Their names all begin with `mpitest`.

To run a benchmark use the command:

```bash
/usr/lib64/mpich3.2/bin/mpirun -hosts ping,pong /usr/lib64/mpich3.2/bin/TEST_NAME
```
