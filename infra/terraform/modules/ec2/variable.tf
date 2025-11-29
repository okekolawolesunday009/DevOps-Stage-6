variable "tags" {
  type = map(string)
  description = "A map of tags to assign to resources"
}

# variable "sg_id" {
#   type = string
# }

variable "pub_sg_id" {
    type = list(string) 
}

variable "epicbook_pubsub_id" {
    type = string  
}


variable "aws_region" {
}


variable "ami" {
    type = string  
}

variable "ec2_key" {
    type = string  
}

variable "ec2_key_content" {
  type        = string
  description = "Optional public key contents. If set, this string will be used as the public key for aws_key_pair. If empty, the file at var.ec2_key will be read."
  default     = ""
}

# variable "public_ip" {
#     type = string  
# }
variable "ssh_private_key_path" {
  default = "~/.ssh/id_rsa"
  type = string
}