data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "az1" {
  vpc_id               = data.aws_vpc.default.id
  availability_zone_id = "use1-az1"
}

data "aws_subnet" "az2" {
  vpc_id               = data.aws_vpc.default.id
  availability_zone_id = "use1-az2"
}

data "aws_subnet" "az3" {
  vpc_id               = data.aws_vpc.default.id
  availability_zone_id = "use1-az3"
}

data "aws_ami" "default" {
  owners      = [var.ami_owner == null ? data.aws_caller_identity.current.account_id : var.ami_owner]
  name_regex  = var.ami_name_regex
  most_recent = true
}

data "http" "caller_identity_ip" {
  url = var.ip_lookup_source
}