#!/usr/bin/env bash

# Push local ssh key to every region in AWS using AWS CLI

# Set aws_keypair_name to the EC2 key-name in each AWS Region
#   it must be unique in each region within your account
aws_keypair_name="$USER"  # or some name that is meaningful to you

# path to PUBLIC ssh key that you want pushed to AWS
publickeyfile="$HOME/.ssh/id_rsa.pub"

regions=$(aws ec2 describe-regions \
  --output text \
  --query 'Regions[*].RegionName')

for region in $regions; do
  echo $region
  aws ec2 import-key-pair \
    --region "$region" \
    --key-name "$aws_keypair_name" \
    --public-key-material "file://$publickeyfile"
done