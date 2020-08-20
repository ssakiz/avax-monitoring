
# STEP -1 : YML CREATE

# prometheus yml create
cat << EOF > /tmp/prometheus.yml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
    - targets: ['192.168.100.100:9090']

  - job_name: 'avax-node'
    metrics_path: '/ext/metrics'
    scrape_interval: 5s
    static_configs:
    - targets: ['192.168.100.100:9650']
      labels:
        group: 'ava'

  # Scrape the Node Exporter every 5 seconds.
  - job_name: 'node'
    scrape_interval: 5s
    static_configs:
    - targets: ['192.168.100.100:9100']
EOF


# STEP - 2: PROMETHEUS DOCKER RUN

# docker volume create prometheus-storage
docker run -d --name=prometheus -p 9090:9090 -v prometheus-storage:/prometheus-data  -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --config.file=/etc/prometheus/prometheus.yml

