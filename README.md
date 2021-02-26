# Kubernetes cluster on AWS with EFK stack

This terraform script deploys managed kubernetes cluster with Apache HTTP server in AWS and AWS Elasticsearch service domain. Logs from Apache HTTP server collected and sent to AWS Elasticsearch with fluentd. 

AWS root user access and secret keys should be provided as "access_key" and "secret_key" variables. Optionally, change AWS Elasticsearch service master username and password.
 
In outputs links provided to apache HTTP server and AWS Elasticsearch Kibana interface