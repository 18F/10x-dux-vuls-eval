output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_az1" {
  value = data.aws_subnet.az1.id
}

output "subnet_az2" {
  value = data.aws_subnet.az2.id
}

output "subnet_az3" {
  value = data.aws_subnet.az3.id
}

output "ami" {
  value = data.aws_ami.default.id
}

output "security_group_id" {
  value = aws_security_group.default.id
}

output "bastion_asg_id" {
  value = module.bastion_asg.autoscaling_group_id
}

output "bastion_asg_desired_capacity" {
  value = module.bastion_asg.autoscaling_group_desired_capacity
}

output "report_server_asg_id" {
  value = module.report_server_asg.autoscaling_group_id
}

output "report_server_asg_desired_capacity" {
  value = module.report_server_asg.autoscaling_group_desired_capacity
}

output "test_asg_id" {
  value = module.test_asg.autoscaling_group_id
}

output "test_asg_desired_capacity" {
  value = module.test_asg.autoscaling_group_desired_capacity
}

output "test_asg_instance_private_ips" {
    value = flatten(data.aws_instances.test.*.private_ips)
}

output "current_ingress_ip" {
  value = "${chomp(data.http.caller_identity_ip.body)}/32"
}