output "public_ip" {
  value = module.ec2.public_ip
}

# output "instance_id" {
#   description = "EC2 instance id"
#   value       = module.ec2.instance_id
# }