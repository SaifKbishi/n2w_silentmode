output "aws_instance_public_dns" {
  value       = "https://${aws_instance.n2w_v441.public_dns}"
  description = "Public DNS for n2w instnace"
}