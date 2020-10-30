# Building Demo Images

The code which built all of the images is in the `packer` directory. The Packer code is there to enable customization of the demo, and view application configuration changes as you investigate Consul.

## Packer File Layout

The AMI's can be adjusted using the following info:

- `cd packer`
  - `Makefile` - builds AMIs using Consul OSS
  - `Makefile-ent` - builds AMIs using Consul Enterprise
    - requires setting Terraform var `consul_lic`
- edit `Makefile` and adjust variables
  - `CONSUL_VER` - version of Consul to build into AMIs
  - `AMI_PREFIX` - default "consul-intro"
    - previously was "consul-demo" and used Enterprise bins
  - `AMI_OWNER` - specifies AWS AMI owner ID
- view & edit the packer templates (`.json` files)
  - adjust variables defined at the beginning of each template

## Adjust Terraform

- change Terraform code if needed
  - if custom prefix used, change `ami_prefix` variable
  - set `ami_owner` variable
  - if using Enterprise AMIs, set `consul_lic` to v2 license

## Build

The images can be built by following these steps:

- export the AWS_REGION to build AMIs
  - `export AWS_REGION="us-west-2"`
- use make to build all the aws images with command
  - `make aws` - build default Makefile
  - `make -f Makefile-ent aws` - build Enterprise makefile
- All images will be built and pushed to your AWS environment
