# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

shard_ips_with_ports=$(echo ${shard_ips} | sed 's/,/:27017,/g' | sed 's/]/:27017/g' | sed 's/^.//')

mongo --eval 'sh.addShard("shardreplset/'$shard_ips_with_ports'")' ${query_server_ip}:27017
