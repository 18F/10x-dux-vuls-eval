provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

provider "http" {
  version = "~> 1.2"
}
