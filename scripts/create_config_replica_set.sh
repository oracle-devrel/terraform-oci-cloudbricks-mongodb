# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

config_ips=$1
config_count=$2

config_count=$((config_count-1))

IFS="," read -a config_ips_arr <<< "$(echo "$config_ips" | tr -d '[]')"

primary_config_ip=${config_ips_arr[0]}

members=()

count=0
while [ $count -le ${config_count} ]
do
  members+="{ _id: $count, host: \"${config_ips_arr[count]}:27019\" },"
  count=$(($count + 1))
done

members=$(echo ${members} | sed 's/.$//g')

mongo --eval 'rs.initiate( { _id: "configreplset", configsvr: true, members: [ '"${members}"' ] } )' "${primary_config_ip}":27019
