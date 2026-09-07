# terraform-aws-ssr-storage

The S3 buckets a serverless SSR stack needs: static assets readable by CloudFront, and
Lambda deployment packages, optionally replicated to a second region.

Composed by [`serverless-ssr`](https://registry.terraform.io/modules/pomo-studio/serverless-ssr/aws).

## What it creates

| Bucket | Purpose |
|---|---|
| Static assets | Built front-end assets, read by CloudFront through an origin access identity |
| Static assets (DR) | Replica in the DR region, serving as a CloudFront failover origin |
| Lambda deployments | Deployment packages for the primary region |
| Lambda deployments (DR) | Deployment packages for the DR region |

All buckets block public access. Versioning is enabled, and cross-region replication is
configured on the static assets bucket when DR is enabled.

## Design decisions

**Public access is blocked on every bucket.** CloudFront reads the static assets through
an origin access identity, so nothing needs to be world-readable. The bucket policy grants
exactly that identity and nothing else.

**Replication needs versioning, so versioning is always on.** That also means objects are
retained after deletion — worth knowing when estimating storage cost for a bucket that
receives a full asset set on every deploy.

## Usage

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

Both providers must be passed even when `enable_dr = false` — provider aliases are
resolved at plan time regardless. Point them at the same region if you do not want a
second one.

## Notes

- Bucket names are deterministic, with no random suffix, which matters if you scope IAM
  policies to them:

  | Bucket | Name |
  |---|---|
  | Static assets | `<app_name>-static-<account_id>` |
  | Static assets (DR) | `<app_name>-static-<account_id>-dr` |
  | Lambda deployments | `<app_name>-lambda-deployments-<account_id>-<region>` |

  Note the static assets buckets do not carry a region, so `app_name` must be unique per
  account.
- Deleting the module leaves versioned objects behind. Empty the buckets first, including
  old versions, or the destroy fails.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |
| <a name="provider_aws.dr"></a> [aws.dr](#provider\_aws.dr) | 6.63.0 |

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
