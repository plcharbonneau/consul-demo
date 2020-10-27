# Route53 DNS records

# get zone ID for subzone
data "aws_route53_zone" "subzone" {
  name = var.route53_subzone
}

# Consul Server DNS Entry
resource "aws_route53_record" "consul_a_records" {
  count   = var.consul_servers_count
  zone_id = data.aws_route53_zone.subzone.zone_id
  name    = "consul${count.index}.${var.consul_dc}.${var.route53_subzone}"
  type    = "A"
  ttl     = "30"
  records = [aws_instance.consul[count.index].public_ip]
}

# Consul LB DNS Entry
resource "aws_route53_record" "consul_lb_a_record" {
  zone_id = data.aws_route53_zone.subzone.zone_id
  name    = "consul.${var.consul_dc}.${var.route53_subzone}"
  type    = "A"

  alias {
    name                   = aws_lb.consul_lb.dns_name
    zone_id                = aws_lb.consul_lb.zone_id
    evaluate_target_health = false
  }
}

# Webclient DNS Entry
resource "aws_route53_record" "webclient_a_records" {
  count   = var.client_webclient_count
  zone_id = data.aws_route53_zone.subzone.zone_id
  name    = "webclient${count.index}.${var.consul_dc}.${var.route53_subzone}"
  type    = "A"
  ttl     = "30"
  records = [aws_instance.webclient[count.index].public_ip]
}

# Webclient LB DNS Entry
resource "aws_route53_record" "webclient_lb_a_record" {
  zone_id = data.aws_route53_zone.subzone.zone_id
  name    = "webclient.${var.consul_dc}.${var.route53_subzone}"
  type    = "A"

  alias {
    name                   = aws_lb.webclient-lb.dns_name
    zone_id                = aws_lb.webclient-lb.zone_id
    evaluate_target_health = false
  }
}

# Listing API DNS Entry
resource "aws_route53_record" "listing_a_records" {
  count   = var.client_listing_count
  zone_id = data.aws_route53_zone.subzone.zone_id
  name    = "listing${count.index}.${var.consul_dc}.${var.route53_subzone}"
  type    = "A"
  ttl     = "30"
  records = [aws_instance.listing-api[count.index].public_ip]
}

# Product API DNS Entry
resource "aws_route53_record" "product_a_records" {
  count   = var.client_product_count
  zone_id = data.aws_route53_zone.subzone.zone_id
  name    = "product${count.index}.${var.consul_dc}.${var.route53_subzone}"
  type    = "A"
  ttl     = "30"
  records = [aws_instance.product-api[count.index].public_ip]
}

# MongoDB DNS Entry
resource "aws_route53_record" "mongo_a_records" {
  count   = var.client_db_count
  zone_id = data.aws_route53_zone.subzone.zone_id
  name    = "mongo${count.index}.${var.consul_dc}.${var.route53_subzone}"
  type    = "A"
  ttl     = "30"
  records = [aws_instance.mongo[count.index].public_ip]
}

