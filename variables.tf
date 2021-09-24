# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# variables.tf 
#
# Purpose: The following file declares all variables used in this backend repository

/********** Provider Variables NOT OVERLOADABLE **********/
variable "region" {
  description = "Target region where artifacts are going to be created"
}

variable "tenancy_ocid" {
  description = "OCID of tenancy"
}

variable "user_ocid" {
  description = "User OCID in tenancy. Currently hardcoded to user denny.alquinta@oracle.com"
}

variable "fingerprint" {
  description = "API Key Fingerprint for user_ocid derived from public API Key imported in OCI User config"
}

variable "private_key_path" {
  description = "Private Key Absolute path location where terraform is executed"
}

/********** Provider Variables NOT OVERLOADABLE **********/

/********** Brick Variables **********/

variable "base_compute_image_ocid" {

}

variable "config_server_name" {
  description = "The name given to the master instance"
}

variable "config_server_ad_list" {
  description = "The availability domain to provision the master instance in"
}

variable "config_server_fd_list" {
  description = "The fault domain to provision the master instance in"
}

variable "config_server_shape" {
  description = "The shape for the master instance to use"
}

variable "config_server_count" {

}

variable "config_server_is_flex_shape" {
  description = "Boolean to determine if the master instance is flex or not"
  default     = false
  type        = bool
}

variable "config_server_ocpus" {
  description = "The number of OCPUS for the master instance to use when flex shape is enabled"
  default     = ""
}

variable "config_server_memory_in_gb" {
  description = "The amount of memory in GB for the master instance to use when flex shape is enabled"
  default     = ""
}


variable "query_server_name" {
  description = "The name given to the standby2 instance"
}

variable "query_server_count" {
  description = "Number of MongoDB query servers to provision"
}


variable "query_server_ad_list" {
  description = "The availability domain to provision the hoststandby2 instance in"
}

variable "query_server_fd_list" {
  description = "The fault domain to provision the hoststandby2 instance in"
}

variable "query_server_shape" {
  description = "The shape for the hotstandby instances to use"
}

variable "query_server_is_flex_shape" {
  description = "Boolean to determine if the standy instances are flex or not"
  default     = false
  type        = bool
}

variable "query_server_ocpus" {
  description = "The number of OCPUS for the flex instances to use when flex shape is enabled"
  default     = ""
}

variable "query_server_memory_in_gb" {
  description = "The amount of memory in GB for the standby instances to use when flex shape is enabled"
  default     = ""
}

variable "shard_replica_set_name" {
  description = "The name given to the standby2 instance"
}

variable "shard_replica_set_count" {
  description = "Number of MongoDB query servers to provision"
}


variable "shard_replica_set_ad_list" {
  description = "The availability domain to provision the hoststandby2 instance in"
}

variable "shard_replica_set_fd_list" {
  description = "The fault domain to provision the hoststandby2 instance in"
}

variable "shard_replica_set_shape" {
  description = "The shape for the hotstandby instances to use"
}

variable "shard_replica_set_is_flex_shape" {
  description = "Boolean to determine if the standy instances are flex or not"
  default     = false
  type        = bool
}

variable "shard_replica_set_ocpus" {
  description = "The number of OCPUS for the flex instances to use when flex shape is enabled"
  default     = ""
}

variable "shard_replica_set_memory_in_gb" {
  description = "The amount of memory in GB for the standby instances to use when flex shape is enabled"
  default     = ""
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "mongodb_version" {
  description = "The version of PostgreSQL used in the setup"
}

variable "ssh_public_key" {
  description = "Defines SSH Public Key to be used in order to remotely connect to compute instances"
}

variable "ssh_private_key" {
  description = "Defines SSH Private Key to be used in order to remotely connect to compute instances"
}

variable "linux_compute_instance_compartment_name" {
  description = "Defines the compartment name where the infrastructure will be created"
}

variable "linux_compute_network_compartment_name" {
  description = "Defines the compartment where the Network is currently located"
}

variable "vcn_display_name" {
  description = "VCN Display name to execute lookup"
}

variable "private_network_subnet_name" {
  description = "Defines the subnet display name where this resource will be created at"
}

variable "compute_nsg_name" {
  description = "Name of the NSG associated to the compute"
  default     = ""
}

variable "config_disk_size_in_gb" {

}

variable "config_disk_vpus_per_gb" {

}

variable "query_disk_size_in_gb" {

}

variable "query_disk_vpus_per_gb" {

}

variable "database_size_in_gb" {
  description = "Disk Capacity for Database"
}

variable "database_vpus_per_gb" {
  description = "Disk VPUS for the Database"
}

variable "instance_backup_policy_level" {

}

variable "config_backup_policy_level" {

}

variable "query_backup_policy_level" {

}

variable "database_backup_policy_level" {
  description = "Backup policy level for Database ISCSI disks"
}

/********** Brick Variables **********/
