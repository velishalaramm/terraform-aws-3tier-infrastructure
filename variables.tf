variable "region" {
  description = "AWS region"  
  default = "us-east-1"
  type = string
}

variable "project_name" {
  default = "Yadagiri"
  description = "Project Name"
  type = string
}


variable "vpc_cidr" {
  default = "172.20.0.0/18"
  type = string
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

