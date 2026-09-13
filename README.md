# terraform-aws-ssr-storage

[![Terraform Validation](https://github.com/pomo-studio/terraform-aws-ssr-storage/actions/workflows/terraform.yml/badge.svg)](https://github.com/pomo-studio/terraform-aws-ssr-storage/actions/workflows/terraform.yml)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-844FBA?logo=terraform)](https://registry.terraform.io/modules/pomo-studio/ssr-storage/aws)

[Changelog](CHANGELOG.md)

The S3 buckets behind a server-rendered site: your built front-end assets, and the deployment packages your Lambdas run from.

## When to use it

Create the S3 buckets a delivered site needs: one for built static assets, read by CloudFront, and per-region buckets for Lambda deployment packages. Everything is private and versioned, and the assets bucket replicates to the second region when you enable DR.

Use it for any site that serves built assets through a CDN and deploys functions from S3. It is not specific to server rendering, and it is the storage layer of the [Serverless SSR blueprint](https://registry.terraform.io/modules/pomo-studio/serverless-ssr/aws).

## Quickstart

```hcl
module "storage" {
  source  = "pomo-studio/ssr-storage/aws"
  version = "~> 0.2"

  providers = {
    aws    = aws.primary
    aws.dr = aws.dr
  }

  app_name       = "my-app"
  account_id     = data.aws_caller_identity.current.account_id
  primary_region = "us-east-1"
  dr_region      = "us-west-2"
  enable_dr      = true

  cloudfront_oai_canonical_user_id = module.cloudfront_support.oai_s3_canonical_user_id

  common_tags = { Project = "my-app" }
}
```

## What it creates

| Bucket | Holds |
|---|---|
| Static assets | Built front-end files, read by CloudFront |
| Static assets (DR) | A replica in your second region, for failover |
| Lambda deployments | Deployment packages for the primary region |
| Lambda deployments (DR) | Deployment packages for the second region |

Nothing is public. CloudFront reads the assets through an origin access identity, and the bucket policy grants that identity and nobody else.

## Design decisions

- **Predictable bucket names.** The names carry no random suffix, so an IAM policy can scope to them: `<app_name>-static-<account_id>`, `<app_name>-static-<account_id>-dr`, and `<app_name>-lambda-deployments-<account_id>-<region>`. Because the static names carry no region, `app_name` must be unique within the account.
- **Versioning is always on**, because replication requires it. Old object versions stay after a delete.
- **Both providers are required**, even when `enable_dr` is false. Terraform resolves provider aliases before it knows whether you wanted the second region, so point both at the same place if you only want one.
- **Empty before you destroy.** Because versioning is on, you have to delete all object versions before Terraform can remove a bucket.

## Examples

- [Basic](examples/basic/)

## Reference

<details>
<summary>Reference</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.64.0 |
| <a name="provider_aws.dr"></a> [aws.dr](#provider\_aws.dr) | 6.64.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.lambda_deployments_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.lambda_deployments_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.static_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.static_assets_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.static_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.static_assets_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.static_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.static_assets_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.static_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_versioning.lambda_deployments_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.lambda_deployments_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.static_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.static_assets_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account id | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Normalized app name for resource naming | `string` | n/a | yes |
| <a name="input_cloudfront_oai_canonical_user_id"></a> [cloudfront\_oai\_canonical\_user\_id](#input\_cloudfront\_oai\_canonical\_user\_id) | CloudFront OAI canonical user id for bucket policies | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags for resources | `map(string)` | `{}` | no |
| <a name="input_dr_region"></a> [dr\_region](#input\_dr\_region) | DR AWS region | `string` | n/a | yes |
| <a name="input_enable_dr"></a> [enable\_dr](#input\_enable\_dr) | Enable DR resources | `bool` | n/a | yes |
| <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region) | Primary AWS region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_deployments_dr_arn"></a> [lambda\_deployments\_dr\_arn](#output\_lambda\_deployments\_dr\_arn) | ARN of the DR-region Lambda deployment bucket. Null when DR is disabled. |
| <a name="output_lambda_deployments_dr_id"></a> [lambda\_deployments\_dr\_id](#output\_lambda\_deployments\_dr\_id) | Name of the DR-region bucket holding Lambda deployment packages. Null when DR is disabled. |
| <a name="output_lambda_deployments_primary_arn"></a> [lambda\_deployments\_primary\_arn](#output\_lambda\_deployments\_primary\_arn) | ARN of the primary-region Lambda deployment bucket. |
| <a name="output_lambda_deployments_primary_id"></a> [lambda\_deployments\_primary\_id](#output\_lambda\_deployments\_primary\_id) | Name of the primary-region bucket holding Lambda deployment packages. |
| <a name="output_static_assets_arn"></a> [static\_assets\_arn](#output\_static\_assets\_arn) | ARN of the static assets bucket. |
| <a name="output_static_assets_dr_arn"></a> [static\_assets\_dr\_arn](#output\_static\_assets\_dr\_arn) | ARN of the DR-region static assets replica bucket. Null when DR is disabled. |
| <a name="output_static_assets_dr_id"></a> [static\_assets\_dr\_id](#output\_static\_assets\_dr\_id) | Name of the DR-region static assets replica bucket. Null when DR is disabled. |
| <a name="output_static_assets_dr_regional_domain_name"></a> [static\_assets\_dr\_regional\_domain\_name](#output\_static\_assets\_dr\_regional\_domain\_name) | Regional domain name of the DR static assets bucket, used as a CloudFront failover origin. |
| <a name="output_static_assets_id"></a> [static\_assets\_id](#output\_static\_assets\_id) | Name of the bucket serving static assets. |
| <a name="output_static_assets_regional_domain_name"></a> [static\_assets\_regional\_domain\_name](#output\_static\_assets\_regional\_domain\_name) | Regional domain name of the static assets bucket, used as a CloudFront origin. |
<!-- END_TF_DOCS -->

</details>

## Support and license

Part of the [pomo-studio](https://github.com/pomo-studio) Terraform components, run in production by [postmodern.](https://pomo.studio). Regenerate the reference with `terraform-docs` v0.20.0 (`terraform-docs .`); CI fails on drift.

See the [contribution guide](https://github.com/pomo-studio/.github/blob/main/CONTRIBUTING.md) and [security policy](https://github.com/pomo-studio/.github/blob/main/SECURITY.md).

MIT licensed. See [LICENSE](LICENSE).
