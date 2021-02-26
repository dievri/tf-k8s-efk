variable "aws_region" {
  default = "eu-north-1"
}

variable "elasticsearch_domain" {
  default = "k8s"
}

variable "access_key" {
  description = "AWS root user access_key"
  sensitive = true
  default = ""
}

variable "secret_key" {
  description = "AWS root user secret key"
  sensitive = true
  default = ""
}

variable "cluster_name" {
  default = "tf-k8s-efk"
}

variable "elasticsearch_username" {
  description = "AWS Elasticsearch domain master username"
  sensitive = true
  default = "testuser"
}

variable "elasticsearch_password" {
  description = "AWS Elasticsearch domain master password"
  sensitive = true
  default = "TestValue1$"
}