resource "kubernetes_config_map" "apache-log-parser" {
  metadata {
    name = "apache-log-parser"
  }
  data = {
    "fluentd.conf" = <<CONFIG
# Ignore fluentd own events
<match fluent.*>
  @type null
</match>
<match fluentd.*>
  @type null
</match>
# HTTP input for the liveness and readiness probes
<source>
  @type http
  port 9880
</source>
# Throw the healthcheck to the standard output instead of forwarding it
<match fluentd.healthcheck>
  @type null
</match>
# Get the logs from the containers running in the cluster
# This block parses logs using an expression valid for the Apache log format
# Update this depending on your application log format
<source>
  @type tail
  path /var/log/containers/*httpd*.log
  pos_file /opt/bitnami/fluentd/logs/buffers/fluentd-docker.pos
  tag www.log
  read_from_head true
  format json
</source>
<filter www.log>
  @type parser
  <parse>
      @type apache2
      keep_time_key true
  </parse>
  replace_invalid_sequence true
  key_name log
  reserve_data true
</filter>
# Forward all logs to the aggregators
<match **>
  @type forward
  <server>
    host fluentd-0.fluentd-headless.default.svc.cluster.local
    port 24224
  </server>
  <buffer>
    @type file
    path /opt/bitnami/fluentd/logs/buffers/logs.buffer
    flush_thread_count 2
    flush_interval 5s
  </buffer>
</match>
    CONFIG
  }
}

resource "kubernetes_config_map" "elasticsearch-output" {
  metadata {
    name = "elasticsearch-output"
  }
  data = {
    "fluentd.conf" = <<CONFIG
# Ignore fluentd own events
<match fluent.*>
  @type null
</match>
<match fluentd.**>
  @type null
</match>
# TCP input to receive logs from the forwarders
<source>
  @type forward
  bind 0.0.0.0
  port 24224
</source>
# HTTP input for the liveness and readiness probes
<source>
  @type http
  bind 0.0.0.0
  port 9880
</source>
<match fluentd.healthcheck>
  @type null
</match>
<match **>
  @type elasticsearch
  include_tag_key true
  host "#{ENV['ELASTICSEARCH_HOST']}"
  port "#{ENV['ELASTICSEARCH_PORT']}"
  scheme https
  user ${var.elasticsearch_username}
  password ${var.elasticsearch_password}
  index_name "httpd-logs"
  <buffer>
    @type file
    path /opt/bitnami/fluentd/logs/buffers/logs.buffer
    flush_thread_count 2
    flush_interval 5s
  </buffer>
</match>
  CONFIG
  }
}

resource "helm_release" "fluentd" {
  depends_on = [
    kubernetes_config_map.apache-log-parser,
    kubernetes_config_map.elasticsearch-output,
    aws_elasticsearch_domain.domain
  ]
  name       = "fluentd"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "fluentd"
  #values = [ "${file("values.yml")}" ]
  values = [<<VALUES
aggregator:
  configMap: elasticsearch-output
  extraEnv:
    - name: ELASTICSEARCH_HOST
      value: "${aws_elasticsearch_domain.domain.endpoint}"
    - name: ELASTICSEARCH_PORT
      value: "443"
forwarder:
  configMap: apache-log-parser
  extraEnv:
    - name: FLUENTD_DAEMON_USER
      value: root
    - name: FLUENTD_DAEMON_GROUP
      value: root
  VALUES
  ]
}