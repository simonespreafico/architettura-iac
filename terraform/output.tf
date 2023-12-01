#region dove risorse vengono create
output "region" {
  description = "AWS region"
  value       = var.region
}

#vpc
output "main_vpc_id" {
  description = "Id sspreafico-main-vpc"
  value = module.vpc.vpc_id
}

#DevOps ec2
output "instance_id" {
  description = "Id EC2 istance"
  value = aws_instance.devsecops-istance.id
}

output "instance_public_ip" {
  description = "Public IP istance EC2"
  value = aws_instance.devsecops-istance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS istance EC2"
  value = aws_instance.devsecops-istance.public_dns
}

#cluster EKS
output "cluster_endpoint" {
  description = "Endpoint EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids cluster EKS"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Nome Kubernetes Cluster"
  value       = module.eks.cluster_name
}

#Registry ECR

#Microservizio Gateway
output "repository_ecr_gateway_name" {
  description = "Nome repository ecr per microservizio gateway"
  value       = aws_ecr_repository.gateway.name
}

output "repository_ecr_gateway_id" {
  description = "Id repository ecr per microservizio gateway"
  value       = aws_ecr_repository.gateway.registry_id
}

output "repository_ecr_gateway_url" {
  description = "Url repository ecr per microservizio gateway"
  value       = aws_ecr_repository.gateway.repository_url
}

#Microservizio User
output "repository_ecr_user_name" {
  description = "Nome repository ecr per microservizio user"
  value       = aws_ecr_repository.user.name
}

output "repository_ecr_user_id" {
  description = "Id repository ecr per microservizio user"
  value       = aws_ecr_repository.user.registry_id
}

output "repository_ecr_user_url" {
  description = "Url repository ecr per microservizio user"
  value       = aws_ecr_repository.user.repository_url
}

#Microservizio certificate
output "repository_ecr_certificate_name" {
  description = "Nome repository ecr per microservizio certificate"
  value       = aws_ecr_repository.certificate.name
}

output "repository_ecr_certificate_id" {
  description = "Id repository ecr per microservizio certificate"
  value       = aws_ecr_repository.certificate.registry_id
}

output "repository_ecr_certificate_url" {
  description = "Url repository ecr per microservizio certificate"
  value       = aws_ecr_repository.certificate.repository_url
}

#Microservizio Frontend
output "repository_ecr_frontend_name" {
  description = "Nome repository ecr per microservizio frontend"
  value       = aws_ecr_repository.frontend.name
}

output "repository_ecr_frontend_id" {
  description = "Id repository ecr per microservizio frontend"
  value       = aws_ecr_repository.frontend.registry_id
}

output "repository_ecr_frontend_url" {
  description = "Url repository ecr per microservizio frontend"
  value       = aws_ecr_repository.frontend.repository_url
}