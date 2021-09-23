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
  port: 27017
  bindIp: ${shard_ip}

replication:
  replSetName: shardreplset
sharding:
  clusterRole: shardsvr
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
