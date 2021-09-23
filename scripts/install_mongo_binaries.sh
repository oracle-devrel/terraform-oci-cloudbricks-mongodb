# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

sudo tee /etc/yum.repos.d/mongodb-org.repo > /dev/null << 'EOF'
[mongodb-org]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/${mongodb_version}/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-${mongodb_version}.asc
EOF

sudo yum -y install mongodb-org

# Should be moved elsewhere once ports are understood 
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# sudo -u root bash -c "firewall-cmd --permanent --zone=trusted --add-source=/32"
# sudo -u root bash -c "firewall-cmd --permanent --zone=trusted --add-port=27017/tcp"
# sudo -u root bash -c "firewall-cmd --permanent --zone=trusted --add-port=27019/tcp"
# sudo -u root bash -c "firewall-cmd --reload"

