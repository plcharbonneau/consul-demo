# Building Demo Images

The code which built all of the images is in the `packer` directory. The Packer code is there to enable customization of the demo, and view application configuration changes as you investigate Consul.

Note: These packer template build **Public** AMI's by default.  If you want your AMIs to be private, edit the Packer templates and remove the statement `"ami_groups": ["all"]` from the end of the `amazon-ebs` `builder` block; make sure to remove the comma at the end of the preceeding line.

## Building Images

- `cd packer`
- export the region to build AMIs
  - `export AWS_REGION="us-west-2"`
- build all images:
  - `make aws`
- if building images for multiple regions
  - after building images in one region, remove `.built` files with `rm .built.aws_*`
  - export the name of the next region using the command above
  - re-run `make aws`
  - repeat as needed additional regions

## Customizing Images

- view & edit the packer templates (`.json` files in packer directory)
  - adjust variables defined at the beginning of each template
  - adjust scripts and related configuration files as necessary
- Create custom image name to avoid name-collision with default images
  - Set `AMI_PREFIX` in `Makefile` to a custom value (default is "consul-demo")
  - Set Terraform variable `ami_prefix` in `terraform.auto.tfvars` to custom value
- Set `Makefile` variables
  - `AMI_OWNER` - specifies AWS Account ID that will own the AMIs
  - `CONSUL_VER` - specifies Consul version built into AMIs
