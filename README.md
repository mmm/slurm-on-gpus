# Running Slurm using GPUs on Google Cloud

Here are some example template snippets used to spin up Google Cloud resources
to run a Slurm cluster of GPUs on Google Cloud.

Please note that these are provided only as examples to help guide
infrastructure planning and are not intended for use in production. They are
deliberately simplified for clarity and lack significant details required for
production-worthy infrastructure implementation.

There are a couple of separate examples available here:

- [Simple gpu-based Slurm cluster](example-simple-gpu-cluster.md).  Just the
  basics please.

- [Hardened gpu-based Slurm cluster](example-hardened-gpu-cluster.md).  While
  "hardened" might be a strong term here, this is an example of how to build
  a gpu-based Slurm cluster that might be a little closer in line with what
  your IT Security folks want you to do.  It's an example of how to run
  a gpu-based Slurm cluster with no access to the outside world as well as
  a handful of other security-specific config variations.


## What's next

There are so many exciting directions to take to learn more about what you've
done here!

- Infrastructure.  Learn more about
  [Cloud](https://cloud.google.com/),
  [Slurm](https://slurm.schedmd.com/overview.html),
  High Performance Computing (HPC) on GCP
  [reference architectures](https://cloud.google.com/solutions/hpc/) and 
  [posts](https://cloud.google.com/blog/topics/hpc).

