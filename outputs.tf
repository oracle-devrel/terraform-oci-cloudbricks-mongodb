# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# output.tf 
#
# Purpose: The following file passes all outputs of the brick

output "mongodb_config_servers" {
  description = "MongoDB Config Server Instances"
  sensitive   = true
  value = oci_core_instance.config_server[*]
}

output "mongodb_query_servers" {
  description = "MongoDB Query Server Instances"
  sensitive   = true
  value = oci_core_instance.query_server[*]
}

output "mongodb_shard_servers" {
  description = "MongoDB Shard Server Instances"
  sensitive   = true
  value = oci_core_instance.shard_replica_set[*]
}
