#!/usr/bin/env bash

set -e

# Push local ssh key to every region in AWS using AWS CLI

# Set aws_keypair_name to the EC2 key-name in each AWS Region
#   it must be unique in each region within your account
aws_keypair_name="${1:-$USER}"  # use 1st param or current user

# path to PUBLIC ssh key that you want pushed to AWS
publickeyfile="$HOME/.ssh/id_rsa.pub"

keydata=$(cat $publickeyfile | base64)

regions=$(aws ec2 describe-regions \
  --output text \
  --query 'Regions[*].RegionName')

for region in $regions; do
  echo $region
  aws ec2 import-key-pair \
    --region "$region" \
    --key-name "$aws_keypair_name" \
    --public-key-material "$keydata"
done