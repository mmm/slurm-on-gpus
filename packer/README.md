# Custom Image Builds


## Customize the image

Copy `variables.tfvars.template` over to `variables.tfvars` and edit the values.

I also

    export GOOGLE_CLOUD_PROJECT=<my-cool-project-name>

just for good measure.

Add ansible stuff into `ansible/`.


## Build the image

Then just run
```
make build
```

then you can see the results through something like
```
gcloud compute images list | grep <my-cool-project-name>
```

and describe it
```
gcloud compute images describe <image-name>
```


## Publish the image

Run
```
gcloud compute images add-iam-policy-binding <image_name> \
    --member='allAuthenticatedUsers' \
    --role='roles/compute.imageUser'
```

Then others can use it via the following image name:

```
projects/<my-cool-project-name>/global/images/<image-name>
```

