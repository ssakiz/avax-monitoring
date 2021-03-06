# How to Monitor Your AVAX Node
avax-monitoring


## Preparing the environment

### Install Docker (if not already installed)
```bash
# Install Docker on ubuntu
sudo apt-get install wget curl apt-transport-https ca-certificates software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y 
sudo systemctl enable docker
sudo systemctl status docker
# exit and login again
sudo usermod -aG docker $(whoami)
```

### Start Avax Node (if not already started)
```bash

# Install Avax Node on ubuntu ( ATTENTION : install ava if not already installed !!! )
cd ~
wget https://github.com/ava-labs/gecko/releases/download/v0.5.7/gecko-linux-0.5.7.tar.gz
tar xvfz gecko-linux-0.5.7.tar.gz
cd gecko-0.5.7

# Start Avax Node on ubuntu
./ava --http-host=0.0.0.0

```

####
  317  docker run --restart=always --rm -d --name=prometheus -p 9090:9090 -v prometheus-storage:/prometheus-data  -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --config.file=/etc/prometheus/prometheus.yml
  318  docker run --restart=always -d --name=prometheus -p 9090:9090 -v prometheus-storage:/prometheus-data  -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --config.file=/etc/prometheus/prometheus.yml
  319  docker volume create grafana-storage
  320  docker run --restart=always -d -p 80:3000 --name=grafana -v grafana-storage:/var/lib/grafana grafana/grafana
  329  docker run --restart=always -d -p 9100:9100 --net="host" prom/node-exporter
  336  docker ps
  337  docker stop 5796f3654250
  338  docker rm 5796f3654250
  339  docker run --restart=always -d --name node-exporter -p 9100:9100 --net="host" prom/node-exporter
  340  docker ps
  341  docker stop b9711bd6c29f
  342  docker stop 205fc3a616a9
  343  docker rm 205fc3a616a9
  344  docker rm b9711bd6c29f
  348  docker ps
  350  docker run --add-host="localhost:172.17.37.64" --restart=always -d --name prometheus -p 9090:9090 -v prometheus-storage:/prometheus-data  -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --config.file=/etc/prometheus/prometheus.yml
  
  
  
  
  351  docker run --restart=always -d --name grafana -p 80:3000 -v grafana-storage:/var/lib/grafana grafana/grafana
  352  docker ps
  353  docker exec -it 6b7931276c25 bash
  354  docker network create myNetwork
  355  docker network connect myNetwork grafana
  356  docker network connect myNetwork prometheus
  357  docker network connect myNetwork node-exporter
  358  docker network inspect myNetwork
  359  docker network ls
  360  docker ps
  361  docker rm f041d40626da
  362  docker stop f041d40626da
  363  docker rm f041d40626da
  364  docker run --restart=always -d --name node-exporter -p 9100:9100  prom/node-exporter
  365  docker ps
  366  docker network connect myNetwork node-exporter
  367  docker network inspect myNetwork
  369  docker ps
  373  docker pull prom/pushgateway
  374  docker run -d  --restart=always -d --name pushgateway -p 9091:9091 prom/pushgateway
  377  docker ps
  378  docker network connect myNetwork pushgateway


####


## Step 1 - Start node-exporter

# docker run --restart=always -d --name node-exporter -p 9100:9100 --net="host" prom/node-exporter
docker run --restart=always -d --name node-exporter -p 9100:9100  prom/node-exporter


## Step 1 - Create prometheus config file 
```bash

# get SERVER IP
SERVER_IP=$(/sbin/ifconfig eth0 | grep 'inet' | cut -d: -f2 | awk '{ print $2}')

# prometheus yml create
cat << 'EOF' > /tmp/prometheus.yml
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
    - targets: ['prometheus:9090']
  - job_name: 'avax-node'
    metrics_path: '/ext/metrics'
    scrape_interval: 5s
    static_configs:
    - targets: ['localhost:9650']
      labels:
        group: 'ava'
  # Scrape the Node Exporter every 5 seconds.
  - job_name: 'node'
    scrape_interval: 5s
    static_configs:
    - targets: ['node-exporter:9100']
  - job_name: 'pushgateway'
    honor_labels: true
    static_configs:
    - targets: ['pushgateway:9091']
EOF

# sed -i "s/localhost/${SERVER_IP}/g"  /tmp/prometheus.yml
```


## Step 2 - Start Prometheus Docker Container
```bash
# create persistent volume
docker volume create prometheus-storage

# start prometheus 
docker run --restart=always -d --name prometheus -p 9090:9090 -v prometheus-storage:/prometheus-data  -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --config.file=/etc/prometheus/prometheus.yml

```


## Step 3 - Start Grafana Docker Container
```bash
# create persistent volume
docker volume create grafana-storage

# start grafana
docker run --restart=always -d --name grafana -p 80:3000 -v grafana-storage:/var/lib/grafana grafana/grafana
```


## Step 4 - Import Grafana Dashboard


### Login Grafana with default user/passwd and change it ( admin / admin )

NOT: If you are using firewall, you should permit port 80 access from outside.

http://PUBLIC-NODE-IP:80

### Create Data Source 



Configuration -> Data Sources --> Add datasource --> Select Prometheus ->

Name --> DS_PROMETHEUS

URL --> http://SERVER_IP:9090

Access --> Server

![alt text](https://github.com/ssakiz/avax-monitoring/raw/master/grafana-datasource.jpg)

![alt text](https://github.com/ssakiz/avax-monitoring/raw/master/grafana-datasource2.jpg)



### Import the following grafana dashboard JSON 

Dashboards --> Manage --> Import -> Upload JSON file -> File Name  --> 

```bash
https://raw.githubusercontent.com/ssakiz/avax-monitoring/master/grafana-dashboard/ava-node-dashboard-1597935940166.json
```

## Step 5 - Happy monitoring

![alt text](https://github.com/ssakiz/avax-monitoring/raw/master/grafana-import-dashboard.jpg)




## Step 6 - Create alert for Telegram

##### - Go to Grafana > Alerting > Notification channels > New channel.
##### -  Type: Telegram. It will ask you for a Bot API Token and a Chat ID.
##### -  Open a chat with BotFather on Telegram.
##### -  Type /newbot
##### -  Type your bots name. F.e: Grafana Bot
##### -  Type your bots username. F.e: a_new_grafana_bot
##### -  You have your Bot API Token. Paste it on Grafana.
##### -  Telegram -> new message -> search -> Type your bots name -> select your bots name -> Start ( Chat started )
##### -  Open this URL address, substituing YOUR_API_TOKEN_KEY with yours: https://api.telegram.org/botYOUR_API_TOKEN_KEY/getUpdates
The response may look like this: {"ok":true,"result":[{"update_id":BLA_BLA_BLA", chat":{"id":[CHAT_ID],"title". 
##### -  Copy that CHAT_ID, even with the minus sign.
##### -  Paste it on Grafana.
##### -  Test it click on "Send Test". 
You can test it using Telegram API too, just substitute parameters with your API Token and Chat ID: https://api.telegram.org/botYOUR_API_TOKEN/sendMessage?chat_id=YOUR_CHAT_ID&text=a_message


![alt text](https://github.com/ssakiz/avax-monitoring/raw/master/grafana-alert-channel.jpg)

![alt text](https://github.com/ssakiz/avax-monitoring/raw/master/grafana-alert-channel2.jpg)


## Step 7 - Test alert for Telegram

##### -  Shutdown the ava node and see the coming alert message from telegram 
![alt text](https://github.com/ssakiz/avax-monitoring/raw/master/grafana_telegram_messages_not_ok.jpg)


##### -  Start the ava node and see the coming OK alert message from telegram

![alt text](https://github.com/ssakiz/avax-monitoring/raw/master/grafana_telegram_messages_ok.jpg)
