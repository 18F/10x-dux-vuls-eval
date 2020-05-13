variable "namespace" {}

variable "stage" {}

variable "name" {}

variable "path" {
  description = "Path for the instance profie in IAM configuration, defaults to '/'"
  type        = string
  default     = "/"
}

variable "assume_role_policy" {
  description = "The assume role policy permitting EC2 instances to utilize the defined policy"
  type        = string
  default     = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                "Service": "ec2.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}

variable "policy" {
  description = "The EC2 instance profile policy itself"
  type       = string
  default    = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:DescribeInstances"
                ],
                "Resource": "*"
            }
        ]
    }
    EOF
}