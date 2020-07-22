# main

# Create Unique ID to allow multiple deployments of module
locals {
  unique_proj_id = "${var.project_name}-${var.consul_dc}"
}

