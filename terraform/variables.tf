variable "region" {
  description = "AWS region used for this configuration"
}

variable "ami_owner" {
  description = "The optional AWS Account ID for private AMI collections"
}

variable "ami_name_regex" {
  description = "Regex string pattern to filter list of AMIs and return their ID"
}

variable "block_device_mappings" {}

variable "namespace" {}

variable "stage" {}

variable "name" {}

variable "small_instance_type" {}

variable "medium_instance_type" {}

variable "large_instance_type" {}

variable "health_check_type" {}

variable "min_size" {}

variable "max_size" {}

variable "wait_for_capacity_timeout" {}

variable "associate_public_ip_address" {}

variable "tags" {}

variable "autoscaling_policies_enabled" {}

variable "cpu_utilization_high_threshold_percent" {}

variable "cpu_utilization_low_threshold_percent" {}

variable "ssh_public_key_path" {}

variable "generate_ssh_key" {}

variable "private_key_extension" {}

variable "public_key_extension" {}

variable "ip_lookup_source" {}

variable "cloudgov_cidrs" {
  type = list
  default = []
}