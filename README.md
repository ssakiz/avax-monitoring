# How to Monitor Your AVAX Node
avax-monitoring



## Preparing the environment

### Install Docker (if not already installed)
```bash
# Install Docker on ubuntu

```

### Start Avax Node (if not already started)
```bash
# Start Avax Node on ubuntu
./ava

```



# Step 1 - Create prometheus config file 
```bash
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
```


# Step 2 - Start Prometheus Docker Container
```bash
# create persistent volume
docker volume create prometheus-storage

# start prometheus 
docker run -d --name=prometheus -p 9090:9090 -v prometheus-storage:/prometheus-data  -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --config.file=/etc/prometheus/prometheus.yml

```


# Step 3 - Start Grafana Docker Container
```bash
# create persistent volume
docker volume create grafana-storage

# start grafana
docker run -d -p 3000:3000 --name=grafana -v grafana-storage:/var/lib/grafana grafana/grafana
```


# Step 4 - Import Grafana Dashboard

<img src="https://github.com/ssakiz/avax-monitoring/grafana-import-dashboard-1.jpg"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />