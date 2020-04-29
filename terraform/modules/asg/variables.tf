variable "region" {
  description = "AWS region used for this configuration"
  default     = "us-east-1"
}

variable "namespace" {}

variable "stage" {}

variable "name" {}

variable "instance_type" {}

variable "user_data_base64" {}

variable "security_group_ids" {
    type = list
}

variable "subnet_ids" {
    type = list
}

variable "image_id" {}

variable "key_name" {}

variable "health_check_type" {}

variable "min_size" {}

variable "max_size" {}

variable "wait_for_capacity_timeout" {}

variable "associate_public_ip_address" {}

variable "tags" {
  default = {}
}

variable "autoscaling_policies_enabled" {}

variable "cpu_utilization_high_threshold_percent" {}

variable "cpu_utilization_low_threshold_percent" {}
