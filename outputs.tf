output "lambda_deployments_primary_id" {
  description = "Name of the primary-region bucket holding Lambda deployment packages."
  value       = aws_s3_bucket.lambda_deployments_primary.id
}

output "lambda_deployments_primary_arn" {
  description = "ARN of the primary-region Lambda deployment bucket."
  value       = aws_s3_bucket.lambda_deployments_primary.arn
}

output "lambda_deployments_dr_id" {
  description = "Name of the DR-region bucket holding Lambda deployment packages. Null when DR is disabled."
  value       = var.enable_dr ? aws_s3_bucket.lambda_deployments_dr[0].id : null
}

output "lambda_deployments_dr_arn" {
  description = "ARN of the DR-region Lambda deployment bucket. Null when DR is disabled."
  value       = var.enable_dr ? aws_s3_bucket.lambda_deployments_dr[0].arn : null
}

output "static_assets_id" {
  description = "Name of the bucket serving static assets."
  value       = aws_s3_bucket.static_assets.id
}

output "static_assets_arn" {
  description = "ARN of the static assets bucket."
  value       = aws_s3_bucket.static_assets.arn
}

output "static_assets_regional_domain_name" {
  description = "Regional domain name of the static assets bucket, used as a CloudFront origin."
  value       = aws_s3_bucket.static_assets.bucket_regional_domain_name
}

output "static_assets_dr_id" {
  description = "Name of the DR-region static assets replica bucket. Null when DR is disabled."
  value       = var.enable_dr ? aws_s3_bucket.static_assets_dr[0].id : null
}

output "static_assets_dr_arn" {
  description = "ARN of the DR-region static assets replica bucket. Null when DR is disabled."
  value       = var.enable_dr ? aws_s3_bucket.static_assets_dr[0].arn : null
}

output "static_assets_dr_regional_domain_name" {
  description = "Regional domain name of the DR static assets bucket, used as a CloudFront failover origin."
  value       = var.enable_dr ? aws_s3_bucket.static_assets_dr[0].bucket_regional_domain_name : null
}
