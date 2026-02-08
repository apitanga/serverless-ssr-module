# Route53 DNS Configuration
# Simple CNAME/Alias to CloudFront - failover handled by CloudFront Origin Groups
#
# Note: For dev environment, you can skip Route53 and use CloudFront domain directly
# For prod, ensure the Route53 zone exists or create one

# Route53 Zone (data source - only if zone exists)
data "aws_route53_zone" "main" {
  count        = var.environment == "prod" ? 1 : 0
  provider     = aws.primary
  name         = var.domain_name
  private_zone = false
}

# Simple DNS Record pointing to CloudFront
# CloudFront Origin Groups handle all failover logic (Primary Lambda → DR Lambda)
resource "aws_route53_record" "main" {
  count    = var.environment == "prod" ? 1 : 0
  provider = aws.primary
  zone_id  = data.aws_route53_zone.main[0].zone_id
  name     = local.domains.primary
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false # CloudFront handles origin health
  }
}

# ACM Certificate for CloudFront (must be in us-east-1)
resource "aws_acm_certificate" "main" {
  provider          = aws.primary
  count             = var.environment == "prod" ? 1 : 0
  domain_name       = local.domains.primary
  validation_method = "DNS"

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate Validation - only in prod with Route53 zone
resource "aws_route53_record" "cert_validation" {
  provider = aws.primary
  for_each = var.environment == "prod" ? {
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
  count                   = var.environment == "prod" ? 1 : 0
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ACM Certificate for Custom Domain (DNS validation via external provider like Squarespace)
# Note: This certificate requires manual DNS validation - see outputs for validation records
resource "aws_acm_certificate" "custom_domain" {
  provider = aws.primary # Must be us-east-1 for CloudFront
  count    = var.custom_domain != "" ? 1 : 0

  domain_name       = var.custom_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name   = "${local.app_name}-custom-domain"
    Domain = var.custom_domain
  })
}
