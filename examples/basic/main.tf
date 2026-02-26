provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

provider "aws" {
  alias                       = "dr"
  region                      = "us-west-2"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

module "storage" {
  source = "../.."

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  app_name                         = "example-app"
  account_id                       = "123456789012"
  primary_region                   = "us-east-1"
  dr_region                        = "us-west-2"
  enable_dr                        = false
  cloudfront_oai_canonical_user_id = "examplecanonicaluserid"
}
