# Create Instances

# Deploy Consul Cluster
data "aws_ami" "consul" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["${var.ami_prefix}-consul-server-*"]
  }
}

resource "random_pet" "cluster" {
  length = 1
  keepers = {
    ami_id = data.aws_ami.consul.id
  }
}

resource "aws_instance" "consul" {
  ami                         = random_pet.cluster.keepers.ami_id
  count                       = var.consul_servers_count
  instance_type               = var.server_machine_type
  key_name                    = var.ssh_key_name
  subnet_id                   = element(aws_subnet.public.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.svr_default.id, aws_security_group.consul_server.id]
  iam_instance_profile        = aws_iam_instance_profile.consul_iam_profile.name
  user_data_base64            = base64encode(var.consul_lic)

  tags = merge(var.hashi_tags,
    { "Name" = "${local.unique_proj_id}-consul-server" },
    { "role" = "consul-server" },
    { "consul-cluster-name" = replace("consul-cluster-${local.unique_proj_id}-${random_pet.cluster.id}", " ", "", ) },
    { "consul-cluster-dc-name" = var.consul_dc },
    { "consul-cluster-acl-dc-name" = var.consul_acl_dc },
  )
}

# Deploy Webclient servers
data "aws_ami" "webclient" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["${var.ami_prefix}-webclient-*"]
  }
}

resource "aws_instance" "webclient" {
  ami                         = data.aws_ami.webclient.id
  count                       = var.client_webclient_count
  instance_type               = var.client_machine_type
  key_name                    = var.ssh_key_name
  subnet_id                   = element(aws_subnet.public.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.svr_default.id]
  iam_instance_profile        = aws_iam_instance_profile.consul_iam_profile.name

  tags = merge(var.hashi_tags,
    { "Name" = "${local.unique_proj_id}-webclient-server-${count.index}" },
    { "role" = "webclient-server" },
    { "consul-cluster-name" = replace("consul-cluster-${local.unique_proj_id}-${random_pet.cluster.id}", " ", "", ) },
    { "consul-cluster-dc-name" = var.consul_dc },
    { "consul-cluster-acl-dc-name" = var.consul_acl_dc },
  )

  depends_on = [aws_instance.consul]
}

# Deploy Listing API Servers
data "aws_ami" "listing-api" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["${var.ami_prefix}-listing-server-*"]
  }
}

resource "aws_instance" "listing-api" {
  ami                         = data.aws_ami.listing-api.id
  count                       = var.client_listing_count
  instance_type               = var.client_machine_type
  key_name                    = var.ssh_key_name
  subnet_id                   = element(aws_subnet.public.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.svr_default.id]
  iam_instance_profile        = aws_iam_instance_profile.consul_iam_profile.name

  tags = merge(var.hashi_tags,
    { "Name" = "${local.unique_proj_id}-listing-api-server-${count.index}" },
    { "role" = "listing-api-server" },
    { "consul-cluster-name" = replace("consul-cluster-${local.unique_proj_id}-${random_pet.cluster.id}", " ", "", ) },
    { "consul-cluster-dc-name" = var.consul_dc },
    { "consul-cluster-acl-dc-name" = var.consul_acl_dc },
  )

  depends_on = [aws_instance.consul]
}

# Deploy Product API Servers
data "aws_ami" "product-api" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["${var.ami_prefix}-product-*"]
  }
}

resource "aws_instance" "product-api" {
  ami                         = data.aws_ami.product-api.id
  count                       = var.client_product_count
  instance_type               = var.client_machine_type
  key_name                    = var.ssh_key_name
  subnet_id                   = element(aws_subnet.public.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.svr_default.id]
  iam_instance_profile        = aws_iam_instance_profile.consul_iam_profile.name

  tags = merge(var.hashi_tags,
    { "Name" = "${local.unique_proj_id}-product-api-server-${count.index}" },
    { "role" = "product-api-server" },
    { "consul-cluster-name" = replace("consul-cluster-${local.unique_proj_id}-${random_pet.cluster.id}", " ", "", ) },
    { "consul-cluster-dc-name" = var.consul_dc },
    { "consul-cluster-acl-dc-name" = var.consul_acl_dc },
  )

  depends_on = [aws_instance.consul]
}

# Deploy MongoDB Server
data "aws_ami" "mongo" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["${var.ami_prefix}-mongodb-*"]
  }
}

resource "aws_instance" "mongo" {
  ami                         = data.aws_ami.mongo.id
  count                       = var.client_db_count
  instance_type               = var.client_machine_type
  key_name                    = var.ssh_key_name
  subnet_id                   = element(aws_subnet.public.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.svr_default.id]
  iam_instance_profile        = aws_iam_instance_profile.consul_iam_profile.name

  tags = merge(var.hashi_tags,
    { "Name" = "${local.unique_proj_id}-mongo-server-${count.index}" },
    { "role" = "mongo-server" },
    { "consul-cluster-name" = replace("consul-cluster-${local.unique_proj_id}-${random_pet.cluster.id}", " ", "", ) },
    { "consul-cluster-dc-name" = var.consul_dc },
    { "consul-cluster-acl-dc-name" = var.consul_acl_dc },
  )

  depends_on = [aws_instance.consul]
}

