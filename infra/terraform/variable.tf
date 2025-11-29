variable "aws_region" {
  type = string
}


variable "ec2_key" {
  type = string
}


variable "projectname" {
  type = string
}

variable "ami" {
    type = string
}

variable "ssh_private_key" {
  description = "private key for ansible connection"
  type = string
}

variable "domain" {
  type = string
  description = "domain for ansible host"
}