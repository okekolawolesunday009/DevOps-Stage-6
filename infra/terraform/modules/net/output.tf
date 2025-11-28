# output "priv_sg_id" {
#   value = aws_security_group.private_sg.id
# }

output "pub_sg_id" {
  value = aws_security_group.public_sg.id
}


# output "db_subnet_ids" {
#   description = "List of subnet IDs for RDS"
#   value       = [aws_subnet.mysql_privsub1.id, aws_subnet.mysql_privsub2.id]
# }

output "epicbook_pubsub_id" {
  description = "Public subnet ID for EC2"
  value       = aws_subnet.epicbook_pubsub.id
}

# output "priv_subnet_id" {
#   value = aws_subnet.mysql_privsub1.id 
# }
