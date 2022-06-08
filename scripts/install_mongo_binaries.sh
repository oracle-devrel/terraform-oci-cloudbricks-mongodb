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

sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld
