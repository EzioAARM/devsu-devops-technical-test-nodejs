output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "public_subnet_arn" {
  value       = aws_subnet.public_subnet.arn
  description = "The ARN of the public subnet"
}

output "public_subnet_2_arn" {
  value       = aws_subnet.public_subnet_2.arn
  description = "The ARN of the second public subnet"
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "The ID of the public subnet"
}

output "public_subnet_2_id" {
  value       = aws_subnet.public_subnet_2.id
  description = "The ID of the second public subnet"
}

output "private_subnet_id" {
  value       = aws_subnet.private_subnet.id
  description = "The ID of the private subnet"
}

output "private_subnet_arn" {
  value       = aws_subnet.private_subnet.arn
  description = "The ARN of the private subnet"
}

output "build_subnet_id" {
  value       = aws_subnet.build_subnet.id
  description = "The ID of the build subnet"
}

output "build_subnet_arn" {
  value       = aws_subnet.build_subnet.arn
  description = "The ARN of the build subnet"
}

output "build_sg_id" {
  value       = aws_security_group.build_sg.id
  description = "The ID of the build security group"
}
