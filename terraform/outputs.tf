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

output "target_asg_id" {
  value = module.target_asg.autoscaling_group_id
}

output "target_asg_desired_capacity" {
  value = module.target_asg.autoscaling_group_desired_capacity
}

output "current_ingress_ip" {
  value = "${chomp(data.http.caller_identity_ip.body)}/32"
}
