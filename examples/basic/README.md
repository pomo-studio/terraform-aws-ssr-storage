# Basic Storage Example

Shows the module creating S3 buckets for Lambda deployments and static assets with a single region.

## What it creates

- One versioned `aws_s3_bucket` for Lambda deployment packages in the primary region.
- One versioned `aws_s3_bucket` for static assets, with a public access block and a bucket policy for CloudFront OAI reads.
- One `aws_iam_role` and `aws_iam_policy` for S3 replication, attached together. The replication configuration is skipped because `enable_dr = false`.

## Before you start

- AWS provider, region `us-east-1`, plus a DR provider alias for `us-west-2`.
- The example sets mock credentials and skip flags. It is meant for `init` and `plan` offline.
- Replace the mock credentials with real ones before `apply`. The CloudFront OAI canonical user ID is a placeholder.

## Run it

```bash
terraform init
terraform plan
terraform apply
```

## Clean up

```bash
terraform destroy
```
