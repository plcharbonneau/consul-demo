# Building Demo Images

The code which built all of the images is in the `packer` directory. The Packer code is there to enable customization of the demo, and view application configuration changes as you investigate Consul.

The images can be built by following these steps:

- `cd packer`
- export the AWS_REGION you want to build the images in with command
  - `export AWS_REGION="us-west-2"`
- view & edit the packer templates (`.json` files in packer directory)
  - adjust variables defined at the beginning of each template
- use make to build all the aws images with command
  - `make aws`
- All images will be built and pushed to your AWS environment
