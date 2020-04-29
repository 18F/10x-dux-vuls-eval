variable "region" {
  description = "AWS region used for this configuration"
  default     = "us-east-1"
}

variable "ami_owner" {
  description = "The optional AWS Account ID for private AMI collections"
  default     = "amazon"
}

variable "ami_name_regex" {
  description = "Regex string pattern to filter list of AMIs and return their ID"
  default     = "amzn2-ami-hvm-2.0.*"
}

variable "namespace" {
  default = "10x-dux"
}

variable "stage" {
  default = "dev"
}

variable "name" {
  default = "vuls"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "health_check_type" {
  default = "EC2"
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "wait_for_capacity_timeout" {
  default = "5m"
}

variable "associate_public_ip_address" {
  default = true
}

variable "tags" {
  default = {}
}

variable "autoscaling_policies_enabled" {
  default = "true"
}

variable "cpu_utilization_high_threshold_percent" {
  default = "70"
}

variable "cpu_utilization_low_threshold_percent" {
  default = "20"
}

variable "ssh_public_key_path" {
  default = "../../secrets"
}

variable "generate_ssh_key" {
  default = true
}

variable "private_key_extension" {
  default = ".pem"
}

variable "public_key_extension" {
  default = ".pub"
}

variable "ip_lookup_source" {
  default = "http://ipv4.icanhazip.com"
}