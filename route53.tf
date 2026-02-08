# Route53 DNS Configuration
# Simple A record (alias) to CloudFront - failover handled by CloudFront Origin Groups
#
# Route53 resources are only created if:
# 1. domain_name is set
# 2. route53_managed = true (domain is hosted in Route53)
#
# For domains NOT in Route53, set route53_managed = false and manually add DNS records

# Route53 Zone (data source - only if domain is in Route53)
data "aws_route53_zone" "main" {
  count        = local.enable_route53 ? 1 : 0
  provider     = aws.primary
  name         = var.domain_name
  private_zone = false
}

# Simple DNS Record pointing to CloudFront
# CloudFront Origin Groups handle all failover logic (Primary Lambda → DR Lambda, Primary S3 → DR S3)
resource "aws_route53_record" "main" {
  count    = local.enable_route53 ? 1 : 0
  provider = aws.primary
  zone_id  = data.aws_route53_zone.main[0].zone_id
  name     = local.full_domain
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false # CloudFront handles origin health
  }
}

# ACM Certificate for Custom Domain (must be in us-east-1 for CloudFront)
resource "aws_acm_certificate" "main" {
  provider          = aws.primary
  count             = local.enable_custom_domain ? 1 : 0
  domain_name       = local.full_domain
  validation_method = "DNS"

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-${local.full_domain}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate Validation via Route53 (automatic - only if domain in Route53)
resource "aws_route53_record" "cert_validation" {
  provider = aws.primary
  for_each = local.enable_route53 ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main[0].zone_id
}

resource "aws_acm_certificate_validation" "main" {
  provider                = aws.primary
  count                   = local.enable_route53 ? 1 : 0
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
