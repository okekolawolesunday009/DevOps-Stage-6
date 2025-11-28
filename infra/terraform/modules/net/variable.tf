variable "tags" {
  type = map(string)
  description = "A map of tags to assign to resources"
}

variable "projectname" {
  type = string  
}

variable "aws_region" {
  type = string  
}