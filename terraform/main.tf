locals {
  bucket                 = "${var.namespace}-${var.stage}-${var.name}-results"
  vuls_release           = "0.9.6"
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
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    sudo curl -L  -o /usr/local/bin/docker-compose \
    https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)
    sudo chmod +x /usr/local/bin/docker-compose
    gpasswd -a ec2-user docker
    pushd /home/ec2-user/
    git clone https://github.com/flexion/10x-dux-vuls-eval.git
    chown -R ec2-user:ec2-user 10x-dux-vuls-eval
    pushd 10x-dux-vuls-eval/docker/
    pushd vuls/
    for db in cve go-exploitdb gost oval;
    do aws s3 cp s3://10x-dux-dev-vuls-results/$db.sqlite3 .;
    done;
    popd
    aws s3 cp s3://10x-dux-dev-vuls-results/config.toml .
    docker-compose up -d
    popd
    popd
  USERDATA
  test_userdata          = <<-USERDATA
    ${local.base_userdata}
    su - ec2-user <<"__EOF__"
    aws s3 cp s3://10x-dux-dev-vuls-results/config.toml .
    git clone https://github.com/flexion/10x-dux-app
    chown -R ec2-user:ec2-user 10x-dux-app
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
                  "s3:ListBucket"
              ],
              "Resource": "arn:aws:s3:::${local.bucket}"
          },
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

  block_device_mappings = []
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

  block_device_mappings = []
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

  block_device_mappings = var.block_device_mappings
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

  ingress {
    description = "internal-go-cve-dictionary"
    from_port   = 1323
    to_port     = 1323
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "internal-goval-dictionary"
    from_port   = 1324
    to_port     = 1324
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "internal-gost"
    from_port   = 1325
    to_port     = 1325
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "internal-go-exploitdb"
    from_port   = 1326
    to_port     = 1326
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "internal-vuls"
    from_port   = 5515
    to_port     = 5515
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "external-vuls"
    from_port   = 5515
    to_port     = 5515
    protocol    = "tcp"
    cidr_blocks = concat(
      ["${chomp(data.http.caller_identity_ip.body)}/32"],
      var.cloudgov_cidrs
      )
  }

  ingress {
    description = "external-vulsrepo"
    from_port   = 5111
    to_port     = 5111
    protocol    = "tcp"
    cidr_blocks = concat(
      ["${chomp(data.http.caller_identity_ip.body)}/32"],
      var.cloudgov_cidrs
      )
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
