locals {
  bucket                 = "${var.namespace}-${var.stage}-${var.name}-results"
  base_userdata          = <<-USERDATA
    #!/bin/bash
    cat <<"__EOF__" > /home/ec2-user/.ssh/config
    Host *
      StrictHostKeyChecking no
    __EOF__
    chmod 600 /home/ec2-user/.ssh/config
    chown ec2-user:ec2-user /home/ec2-user/.ssh/config
    yum install -y git tmux vim
    yum update -y
  USERDATA
  bastion_userdata       = local.base_userdata
  report_server_userdata = <<-USERDATA
    ${local.base_userdata}
    yum install -y git docker
    systemctl start docker
    systemctl enable docker
    gpasswd -a ec2-user docker
    git clone https://github.com/vulsio/vulsctl
    pushd vulsctl
    bash -x ./update-all.sh
    popd
  USERDATA
  test_userdata          = <<-USERDATA
    ${local.base_userdata}
    yum install -y git golang
    su - ec2-user <<"__EOF__"
    export GOPATH=$HOME
    echo "GOPATH is $GOPATH ..."
    rm -rf $GOPATH/{bin,pkg,src}
    mkdir -p $GOPATH/src/github.com/future-architect
    pushd $GOPATH/src/github.com/future-architect
    git clone https://github.com/future-architect/vuls.git
    pushd vuls
    make install
    popd
    popd
    __EOF__
  USERDATA
}

module "iam_instance_profile" {
  source = "./modules/iam/instance"

  namespace = var.namespace
  stage     = var.stage
  name      = var.name
  policy    = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "s3:ListBucket",
              ],
              "Resource": "arn:aws:s3:::${local.bucket}"
          }
          {
              "Effect": "Allow",
              "Action": [
                  "s3:ListObjects",
                  "s3:GetObject",
                  "s3:PutObject"
              ],
              "Resource": "arn:aws:s3:::${local.bucket}/*"
          }
      ]
  }
  EOF
}

module "bastion_asg" {
  source = "./modules/asg"

  namespace = var.namespace
  stage     = var.stage
  name      = "${var.name}-bastion"

  image_id           = data.aws_ami.default.id
  instance_type      = var.small_instance_type
  key_name           = module.ssh_key_pair.key_name
  security_group_ids = [aws_security_group.default.id]
  subnet_ids = [
    data.aws_subnet.az1.id,
    data.aws_subnet.az2.id,
    data.aws_subnet.az3.id
  ]
  iam_instance_profile_name              = module.iam_instance_profile.name
  health_check_type                      = var.health_check_type
  min_size                               = var.min_size
  max_size                               = var.max_size
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  associate_public_ip_address            = var.associate_public_ip_address
  user_data_base64                       = "${base64encode(local.bastion_userdata)}"
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
  tags                                   = var.tags
}

module "test_asg" {
  source = "./modules/asg"

  namespace = var.namespace
  stage     = var.stage
  name      = "${var.name}-test"

  image_id           = data.aws_ami.default.id
  instance_type      = var.medium_instance_type
  key_name           = module.ssh_key_pair.key_name
  security_group_ids = [aws_security_group.default.id]
  subnet_ids = [
    data.aws_subnet.az1.id,
    data.aws_subnet.az2.id,
    data.aws_subnet.az3.id
  ]
  iam_instance_profile_name              = module.iam_instance_profile.name
  health_check_type                      = var.health_check_type
  min_size                               = var.min_size
  max_size                               = var.max_size
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  associate_public_ip_address            = var.associate_public_ip_address
  user_data_base64                       = "${base64encode(local.test_userdata)}"
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
  tags                                   = var.tags
}

module "report_server_asg" {
  source = "./modules/asg"

  namespace = var.namespace
  stage     = var.stage
  name      = "${var.name}-report-server"

  image_id           = data.aws_ami.default.id
  instance_type      = var.large_instance_type
  key_name           = module.ssh_key_pair.key_name
  security_group_ids = [aws_security_group.default.id]
  subnet_ids = [
    data.aws_subnet.az1.id,
    data.aws_subnet.az2.id,
    data.aws_subnet.az3.id
  ]
  iam_instance_profile_name              = module.iam_instance_profile.name
  health_check_type                      = var.health_check_type
  min_size                               = var.min_size
  max_size                               = var.max_size
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  associate_public_ip_address            = var.associate_public_ip_address
  user_data_base64                       = "${base64encode(local.report_server_userdata)}"
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
  tags                                   = var.tags
}

module "ssh_key_pair" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=tags/0.9.0"
  namespace             = var.namespace
  stage                 = var.stage
  name                  = var.name
  ssh_public_key_path   = var.ssh_public_key_path
  generate_ssh_key      = var.generate_ssh_key
  private_key_extension = var.private_key_extension
  public_key_extension  = var.public_key_extension
}

resource "aws_security_group" "default" {
  name        = "${var.namespace}-${var.stage}-${var.name}"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "ingress-ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["${chomp(data.http.caller_identity_ip.body)}/32"]
  }

  egress {
    description = "egress-all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    map(
      "Namespace", "${var.namespace}",
      "Stage", "${var.stage}",
    )
  )
}
