output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.prefix
}

output "githubactions_creds_id" {
  value = aws_iam_access_key.githubactions.id
}

output "githubactions_creds_secret" {
  value = aws_iam_access_key.githubactions.secret
  sensitive = true
}


output "app_access_creds_id" {
  value = aws_iam_access_key.app_access.id
}

output "app_access_creds_secret" {
  value = aws_iam_access_key.app_access.secret
  sensitive = true
}
