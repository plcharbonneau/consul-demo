# Outputs

# Main Cluster Region
output "main_region" {
  value = var.aws_region
}

output "main_consul_lb" {
  value = module.cluster_main.consul_lb
}

output "main_consul_servers" {
  value = module.cluster_main.consul_servers
}

output "main_webclient_lb" {
  value = module.cluster_main.webclient_lb
}

output "main_webclient_servers" {
  value = module.cluster_main.webclient_servers
}

output "main_listing_api_servers" {
  value = module.cluster_main.listing_api_servers
}

output "main_mongo_servers" {
  value = module.cluster_main.mongo_servers
}

output "main_product_api_servers" {
  value = module.cluster_main.product_api_servers
}

# Alternate Cluster Outputs
output "secondary_region" {
  value = var.aws_region_alt
}

output "secondary_consul_lb" {
  value = module.cluster_alt.consul_lb
}

output "secondary_consul_servers" {
  value = module.cluster_alt.consul_servers
}

output "secondary_webclient_lb" {
  value = module.cluster_alt.webclient_lb
}

output "secondary_webclient_servers" {
  value = module.cluster_alt.webclient_servers
}

output "secondary_listing_api_servers" {
  value = module.cluster_alt.listing_api_servers
}

output "secondary_mongo_servers" {
  value = module.cluster_alt.mongo_servers
}

output "secondary_product_api_servers" {
  value = module.cluster_alt.product_api_servers
}

# Display ssh Alias Suggestions
output "working_aliases" {
  value = <<EOF
  
  ssh aliases for repeating demo with same host fqdn (append to .bash_profile)

    alias ssh-mongo='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${module.cluster_main.mongo_servers[0]}'
    alias ssh-listing='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${module.cluster_main.listing_api_servers[0]}'
    alias ssh-webclient='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${module.cluster_main.webclient_servers[0]}'

EOF
}

# Display Demo Connection Information at end
output "working_connections" {
  value = <<EOF

  OPEN IN BROWSER TABS
    Webclient   http://${module.cluster_main.webclient_lb}
    Consul GUI  http://${module.cluster_main.consul_lb}

  CONNECT IN TERMINAL TABS:
    mongo       ssh ubuntu@${module.cluster_main.mongo_servers[0]}
    listing     ssh ubuntu@${module.cluster_main.listing_api_servers[0]}
    webclient   ssh ubuntu@${module.cluster_main.webclient_servers[0]}

EOF

}

