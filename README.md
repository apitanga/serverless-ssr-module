# Serverless SSR Terraform Module

Deploy serverless SSR applications (Nuxt.js, Next.js, Nitro) on AWS with automatic multi-region failover.

## Quick Start

```hcl
module "ssr" {
  source = "github.com/apitanga/serverless-ssr-module"

  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  project_name = "my-app"
  domain_name  = "example.com"
  subdomain    = "app"
}
```

Deploy:
```bash
terraform init
terraform apply
```

**[📖 Full Getting Started Guide](docs/GETTING_STARTED.md)**

---

## ⚠️ Important Prerequisite

**Your domain must be managed by AWS Route 53** before deploying this module.

If your domain is currently with another registrar (GoDaddy, Namecheap, Squarespace, etc.), you'll need to migrate it to Route 53 first. This typically takes 10-30 minutes.

**[📘 Domain Setup Guide](docs/DOMAIN_SETUP.md)** - Complete migration instructions

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
- **Domain in Route 53** (same AWS account) - [Setup Guide](docs/DOMAIN_SETUP.md)

## Related Projects

- **[serverless-ssr-app](https://github.com/apitanga/serverless-ssr-app)** - Companion Nuxt.js application template

## License

MIT

---

**Need help?** Check the [Getting Started Guide](docs/GETTING_STARTED.md) or open an issue.
