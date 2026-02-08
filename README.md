# Serverless SSR Terraform Module

Deploy serverless SSR applications (Nuxt.js, Next.js, Nitro) on AWS with automatic multi-region failover.

## Quick Start

### Option 1: No Custom Domain (Simplest)

Start without a domain - uses CloudFront URL:

```hcl
module "ssr" {
  source = "github.com/apitanga/serverless-ssr-module"

  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  project_name = "my-app"
}
```

**Output:** `https://d111111abcdef8.cloudfront.net`

### Option 2: Domain in Route 53 (Fully Automated)

Use your own domain with automatic DNS and SSL:

```hcl
module "ssr" {
  source = "github.com/apitanga/serverless-ssr-module"

  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  project_name      = "my-app"
  domain_name       = "example.com"
  subdomain         = "app"
  route53_managed   = true  # Domain is in Route 53
}
```

**Output:** `https://app.example.com` (automatic DNS + SSL)

### Option 3: Domain NOT in Route 53 (Manual DNS)

Use external domain (GoDaddy, Namecheap, etc.):

```hcl
module "ssr" {
  source = "github.com/apitanga/serverless-ssr-module"

  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  project_name      = "my-app"
  domain_name       = "example.com"
  subdomain         = "app"
  route53_managed   = false  # Add DNS records manually
}
```

Terraform will output DNS records to add to your domain registrar.

**[📖 Full Getting Started Guide](docs/GETTING_STARTED.md)**

---

## Features

- 🚀 **Serverless** - Lambda-based SSR, no servers to manage
- 🌍 **Multi-Region** - Automatic failover between primary and DR regions
- 🔒 **Custom Domain** - SSL/TLS via ACM, Route 53 integration
- 📦 **CI/CD Ready** - Optional IAM user for automated deployments
- 💾 **Data Layer** - DynamoDB global table included
- ⚡ **Fast Deploy** - Bootstrap code works immediately, deploy app anytime

## What You Get

```
CloudFront (Global CDN)
    ↓
Primary Region (us-east-1)     DR Region (us-west-2)
  • Lambda Function              • Lambda Function
  • S3 Buckets                   • S3 Buckets
  • DynamoDB Table               • Replicated Data
```

**[🏗️ Architecture Details](docs/ARCHITECTURE.md)**

## Documentation

- **[Getting Started](docs/GETTING_STARTED.md)** - Step-by-step deployment guide
- **[Domain Setup](docs/DOMAIN_SETUP.md)** - Migrate your domain to Route 53
- **[API Reference](docs/API.md)** - All inputs and outputs
- **[Architecture](docs/ARCHITECTURE.md)** - How it works, costs, performance
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Examples

- **[Basic Example](examples/basic/)** - Minimal single-region setup
- **[Complete Example](examples/complete/)** - All features enabled

## Requirements

- Terraform >= 1.5.0
- AWS provider ~> 5.0
- Domain in Route 53 (optional, for custom domain with automatic DNS) - [Setup Guide](docs/DOMAIN_SETUP.md)

## Related Projects

- **[serverless-ssr-app](https://github.com/apitanga/serverless-ssr-app)** - Companion Nuxt.js application template

## License

MIT

---

**Need help?** Check the [Getting Started Guide](docs/GETTING_STARTED.md) or open an issue.
