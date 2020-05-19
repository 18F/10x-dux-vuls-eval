region                                 = "us-east-1"
ami_owner                              = "amazon"
ami_name_regex                         = "amzn2-ami-hvm-2.0.*"
block_device_mappings = [
  {
    "device_name" : "/dev/xvda",
    "no_device" : null,
    "virtual_name" : null,
    "ebs" : {
      "delete_on_termination" : null,
      "encrypted" : false,
      "iops" : null,
      "kms_key_id" : null,
      "snapshot_id" : null,
      "volume_size" : 64,
      "volume_type" : "gp2"
    }
  }
]
namespace                              = "10x-dux"
stage                                  = "dev"
name                                   = "vuls"
small_instance_type                    = "t2.micro"
medium_instance_type                   = "t2.medium"
large_instance_type                    = "m5ad.large"
health_check_type                      = "EC2"
min_size                               = 1
max_size                               = 1
wait_for_capacity_timeout              = "5m"
associate_public_ip_address            = true
tags                                   = {}
autoscaling_policies_enabled           = "true"
cpu_utilization_high_threshold_percent = "70"
cpu_utilization_low_threshold_percent  = "20"
ssh_public_key_path                    = "../../secrets"
generate_ssh_key                       = true
private_key_extension                  = ".pem"
public_key_extension                   = ".pub"
ip_lookup_source                       = "http://ipv4.icanhazip.com"