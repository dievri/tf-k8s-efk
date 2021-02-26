output "apache_address" {
  description = "Apache service address"
  value       = "http://${kubernetes_service.apache.status.0.load_balancer.0.ingress.0.hostname}"
}

output "kibana_address" {
  description = "Public Kibana dashboard for AWS Elasticsearch Service"
  value       = "https://${aws_elasticsearch_domain.domain.kibana_endpoint}"
}
