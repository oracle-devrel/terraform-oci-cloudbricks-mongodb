# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

config_ips=$1
query_server_ip=$2

config_ips_with_ports=$(echo "${config_ips}" | sed 's/,/:27019,/g' | sed 's/]/:27019/g' | sed 's/^.//')


sudo tee /etc/mongos.conf > /dev/null << EOF
# mongos.conf

systemLog:
  destination: file
  logAppend: true
  path: /u01/data/log/mongod.log

net:
  port: 27017
  bindIp: ${query_server_ip}

sharding:
  configDB: configreplset/${config_ips_with_ports}
EOF


sudo tee /lib/systemd/system/mongos.service > /dev/null << EOF
[Unit]
Description=Mongo Cluster Router
After=network.target

[Service]
User=mongod
Group=mongod
ExecStart=/usr/bin/mongos --config /etc/mongos.conf
# file size
LimitFSIZE=infinity
# cpu time
LimitCPU=infinity
# virtual memory size
LimitAS=infinity
# open files
LimitNOFILE=64000
# processes/threads
LimitNPROC=64000
# total threads (user+kernel)
TasksMax=infinity
TasksAccounting=false
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir -p /u01/data/log/mongod.diagnostic.data
sudo chown -R mongod:mongod /u01/
sudo chmod -R 0755 /u01/

sudo chown -R mongod:mongod /etc/mongos.conf

sudo semanage fcontext -a -t mongod_log_t "/u01/data/.*"
sudo chcon -Rv -u system_u -t mongod_log_t "/u01/data"
sudo restorecon -R -v /u01/data/

sudo systemctl stop mongod

sudo systemctl enable mongos.service
sudo systemctl start mongos
sudo systemctl status mongos
