data "aws_caller_identity" "current" {}
resource "aws_elasticsearch_domain" "domain" {
  domain_name           = var.elasticsearch_domain
  elasticsearch_version = "7.9"

  cluster_config {
    instance_type  = "r5.large.elasticsearch"
    instance_count = 1
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  tags = {
    Domain = "TestDomain"
  }
  encrypt_at_rest {
    enabled = true
  }
  node_to_node_encryption {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.elasticsearch_username
      master_user_password = var.elasticsearch_password
    }
  }
  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
             "Principal": {
        "AWS": "*"
      },
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.elasticsearch_domain}/*"
        }
    ]
}
CONFIG
}