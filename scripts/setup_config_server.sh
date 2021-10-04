# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

sudo tee /etc/mongod.conf > /dev/null << 'EOF'
# mongod.conf

systemLog:
  destination: file
  logAppend: true
  path: /u01/data/log/mongod.log

storage:
  dbPath: /u01/data/lib/mongo
  journal:
    enabled: true

processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod.pid
  timeZoneInfo: /usr/share/zoneinfo

net:
  port: 27019
  bindIp: ${config_server_ip}

replication:
  replSetName: configreplset

sharding:
  clusterRole: "configsvr"
EOF

sudo tee /usr/lib/systemd/system/mongod.service > /dev/null << 'EOF'
[Unit]
Description=MongoDB Database Server
Documentation=https://docs.mongodb.org/manual
After=network-online.target
Wants=network-online.target

[Service]
User=mongod
Group=mongod
Environment="OPTIONS=-f /etc/mongod.conf"
EnvironmentFile=-/etc/sysconfig/mongod
ExecStart=/usr/bin/mongod $OPTIONS
ExecStartPre=/usr/bin/mkdir -p /var/run/mongodb
ExecStartPre=/usr/bin/chown mongod:mongod /var/run/mongodb
ExecStartPre=/usr/bin/chmod 0755 /var/run/mongodb
PermissionsStartOnly=true
PIDFile=/var/run/mongodb/mongod.pid
Type=forking
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
# locked memory
LimitMEMLOCK=infinity
# total threads (user+kernel)
TasksMax=infinity
TasksAccounting=false
# Recommended limits for mongod as specified in
# https://docs.mongodb.com/manual/reference/ulimit/#recommended-ulimit-settings
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir -p /u01/data/log/
sudo mkdir -p /u01/data/lib/mongo

sudo chown -R mongod:mongod /u01/
sudo chmod -R 0755 /u01/

sudo chown -R mongod:mongod /etc/mongod.conf

sudo semanage fcontext -a -t mongod_log_t "/u01/data/.*"
sudo chcon -Rv -u system_u -t mongod_log_t "/u01/data"
sudo restorecon -R -v /u01/data/

sudo semanage fcontext -a -t mongod_var_lib_t "/u01/data/.*"
sudo chcon -Rv -u system_u -t mongod_var_lib_t "/u01/data"
sudo restorecon -R -v /u01/data/

sudo systemctl stop mongod
sudo systemctl start mongod
sudo systemctl status mongod
