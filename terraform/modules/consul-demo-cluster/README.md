# consul-demo-cluster module

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami\_owner | AWS account which owns AMIs | string | `"753646501470"` | no |
| ami\_prefix | prefix of AMI images to use when building instances | string | `"consul-demo"` | no |
| aws\_region | Region into which to deploy | string | `"us-west-2"` | no |
| client\_db\_count | The number of client machines to create in each region | string | `"1"` | no |
| client\_listing\_count | The number of listing machines to create in each region | string | `"2"` | no |
| client\_machine\_type | The machine type (size) to deploy | string | `"t2.micro"` | no |
| client\_product\_count | The number of product machines to create in each region | string | `"2"` | no |
| client\_webclient\_count | The number of webclients to create in each region | string | `"2"` | no |
| consul\_acl\_dc | Consul ACL cluster name | string | n/a | yes |
| consul\_dc | Consul cluster DC name | string | n/a | yes |
| consul\_lic | License file content for Consul Enterprise | string | `""` | no |
| consul\_servers\_count | How many Consul servers to create in each region | string | `"3"` | no |
| hashi\_tags | Tags to apply to resources | map | `<map>` | no |
| internal\_netblock | Global netblock | string | `"10.0.0.0/8"` | no |
| project\_name | Set this, resources are given a unique name based on this | string | n/a | yes |
| route53\_zone\_id | Route 53 zone into which to place hostnames | string | n/a | yes |
| server\_machine\_type | The machine type (size) to deploy | string | `"t2.micro"` | no |
| ssh\_key\_name | Name of existing AWS ssh key | string | n/a | yes |
| top\_level\_domain | The top-level domain to put all Route53 records | string | n/a | yes |
| vpc\_netblock | The netblock for this deployment's VPC | string | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_region |  |
| consul\_acl\_dc |  |
| consul\_dc |  |
| consul\_lb |  |
| consul\_servers |  |
| consul\_servers\_private\_ip |  |
| listing\_api\_servers |  |
| mongo\_servers |  |
| product\_api\_servers |  |
| public\_subnets |  |
| vpc\_id |  |
| vpc\_netblock |  |
| vpc\_public\_route\_table\_id |  |
| webclient\_lb |  |
| webclient\_servers |  |
