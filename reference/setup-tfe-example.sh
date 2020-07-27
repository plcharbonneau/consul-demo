#!/usr/bin/env bash

# Create TFC/TFE workspace for consul-demo
#   https://github.com/robertpeteuil/consul-demo
#
# requires TFH utility: https://github.com/hashicorp-community/tf-helper


### USER VARIABLES

# Repo settings
REPO_NAME="robertpeteuil/consul-demo"
REPO_BRANCH="terraform-0.11"

# TFC/TFE settings
TFE_ORG="my-tfe-org"
WORKSPACE_SINGLE="consul-demo-single-region"
WORKSPACE_MULTI="consul-demo-multi-region"

# Terraform Variables
PROJ_NAME="consul-demo"
TAG_OWNER="user@example.com"
TAG_REGION="NA-WEST-STRAT"
TAG_PURPOSE="Demo"
TAG_TTL="4"
AWS_SSH_KEYNAME="myuserkey"
SSH_PRI_KEY_PATH="$HOME/.ssh/id_rsa"  # Path to SSH Private Key File
# Route53 vars
#   Since this is configured to use the terraform-0.11 branch
#     AWS_ROUTE53_ZONE and TOP_DOMAIN_NAME are the required vars
#   terraform 0.12 branches use route53_subzone instead of these vars
AWS_ROUTE53_ZONE="ZZZZZZZZZZZZZZ"
TOP_DOMAIN_NAME="test.example.com"

# HIGHLY RECOMMENDED
CONSUL_ENT_LICENSE=""
# If Consul License not provided - Consul will shutdown in 30m (on all hosts)
#   If this happens, terraform destroy will fail because Consul isn't running
#   This can be remediated by manually rebooting or restart the hosts or
#     restarting the consul service on each host (including clients)
#     using the command sudo systemctl restart consul


### INTERNAL VARIABLES
TF_VER="0.12.20"
SSH_PRI_KEY=$(awk '{printf "%s\\n", $0}' $SSH_PRI_KEY_PATH)


### SINGLE-REGION-DEMO WORKSPACE
# Create workspace
tfh workspace new $WORKSPACE_SINGLE -org $TFE_ORG -terraform-version $TF_VER -working-dir "terraform/single-region-demo" -vcs-id $REPO_NAME -vcs-branch $REPO_BRANCH
# Terraform Vars
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -var "project_name=$PROJ_NAME"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -hcl-var "hashi_tags={Owner=\"$TAG_OWNER\", Region=\"$TAG_REGION\", Purpose=\"$TAG_PURPOSE\", TTL=\"$TAG_TTL\", Terraform=\"true\", TFE=\"true\", TFEWorkspace=\"$WORKSPACE_SINGLE\"}"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -var "ssh_key_name=$AWS_SSH_KEYNAME"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -var "route53_zone_id=$AWS_ROUTE53_ZONE"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -var "top_level_domain=$TOP_DOMAIN_NAME"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -svar "consul_lic=$CONSUL_LICENSE"
# Environment Vars
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -senv-var "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -senv-var "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -senv-var "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"


### MULTI-REGION-WORKSPACE
# Create workspace
tfh workspace new $WORKSPACE_MULTI -org $TFE_ORG -terraform-version $TF_VER -working-dir "terraform/multi-region-demo" -vcs-id $REPO_NAME -vcs-branch $REPO_BRANCH
# Terraform Vars
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -var "project_name=$PROJ_NAME"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_SINGLE -org $TFE_ORG -hcl-var "hashi_tags={Owner=\"$TAG_OWNER\", Region=\"$TAG_REGION\", Purpose=\"$TAG_PURPOSE\", TTL=\"$TAG_TTL\", Terraform=\"true\", TFE=\"true\", TFEWorkspace=\"$WORKSPACE_SINGLE\"}"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -var "ssh_key_name=$AWS_SSH_KEYNAME"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -var "route53_zone_id=$AWS_ROUTE53_ZONE"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -var "top_level_domain=$TOP_DOMAIN_NAME"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -svar "ssh_pri_key_data=$SSH_PRI_KEY"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -svar "consul_lic=$CONSUL_ENT_LICENSE"
# Environment Vars
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -senv-var "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -senv-var "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
tfh pushvars -overwrite-all -dry-run false -name $WORKSPACE_MULTI -org $TFE_ORG -senv-var "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
