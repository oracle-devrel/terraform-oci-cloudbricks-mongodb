# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

shard_ips=$1
shard_count=$2

shard_count=$((shard_count-1))

IFS="," read -a shard_ips_arr <<< "$(echo "$shard_ips" | tr -d '[]')"

primary_shard_ip=${shard_ips_arr[0]}

members=()

count=0
while [ $count -le ${shard_count} ]
do
  members+="{ _id: $count, host: \"${shard_ips_arr[count]}:27017\" },"
  count=$(($count + 1))
done

members=$(echo ${members} | sed 's/.$//g')

mongo --eval 'rs.initiate( { _id: "shardreplset", members: [ '"${members}"' ] } )' "${primary_shard_ip}":27017
