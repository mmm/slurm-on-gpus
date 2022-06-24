# Storage Options

This default example creates [Google Cloud
Filestore](https://cloud.google.com/filestore/) volumes and chooses the
`BASIC_HDD` tier.  There are more performant or larger
[options](https://cloud.google.com/filestore/docs/service-tiers) available.
Set the appropriate [`tier`
value](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/filestore_instance#tier)
in the Terraform template.

You will need to request additional quota for some options.

Please note the cost for various options varies greatly.
