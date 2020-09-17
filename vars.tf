variable "access_key" {}
variable "secret_key" {}

variable "region" {
  description = "VPC region"
  default     = "us-east-1"
}

variable "az1" {
  description = "Avaialbility Zone1"
  default     = "us-east-1a"
}

variable "az2" {
  description = "Avaialbility Zone2"
  default     = "us-east-1b"
}
variable "vpc_cidr" {
  description = "CIDR of the VPC"
  default     = "172.0.0.0/16"
}
