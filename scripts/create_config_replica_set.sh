# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

mongo --eval 'rs.initiate( { _id: "configReplSet", configsvr: true, members: [ { _id: 0, host: "${primary_config_server_ip}:27019" }, { _id: 1, host: "${secondary_config_server_ip}:27019" } ] } )' ${primary_config_server_ip}:27019

mongo --eval 'rs.status()' ${primary_config_server_ip}:27019
