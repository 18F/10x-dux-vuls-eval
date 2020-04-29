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

data "aws_instances" "bastion" {
  instance_state_names = ["running"]
  
  filter {
    name = "tag:Name"
    values = ["${var.namespace}-${var.stage}-${var.name}-bastion"]
  }

  depends_on = [module.bastion_asg]
}

data "aws_instances" "report_server" {
  instance_state_names = ["running"]
  
  filter {
    name = "tag:Name"
    values = ["${var.namespace}-${var.stage}-${var.name}-report-server"]
  }

  depends_on = [module.report_server_asg]
}

data "aws_instances" "test" {
  instance_state_names = ["running"]

  filter {
    name = "tag:Name"
    values = ["${var.namespace}-${var.stage}-${var.name}-test"]
  }

  depends_on = [module.test_asg]
}

data "http" "caller_identity_ip" {
  url = var.ip_lookup_source
}