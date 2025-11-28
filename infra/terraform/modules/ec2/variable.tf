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

# variable "public_ip" {
#     type = string  
# }
variable "ssh_private_key_path" {
  default = "~/.ssh/id_ed25519"
  type = string
}