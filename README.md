# OCI Cloud Bricks: MongoDB

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_terraform-oci-cloudbricks-mongodb)](https://sonarcloud.io/dashboard?id=oracle-devrel_terraform-oci-cloudbricks-mongodb)

*TODO: ADD ANOTHER CONFIG SERVER/MAKE DYNAMIC*

## Introduction
The following brick contains the logic to provision a MonoDB database cluster in a highly available architecture.
*Note: ADD DETAILS*

## Reference Architecture
The following is the reference architecture associated to this brick
*Note: ADD DETAILS*

### Prerequisites
- Pre-baked Artifact and Network Compartments
- Pre-baked VCN

# Sample tfvar file
```shell
######################################## COMMON VARIABLES ######################################
region           = "re-region-1"
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaabcedfghijklmonoprstuvwxyz"
user_ocid        = "ocid1.user.oc1..aaaaaaaabcedfghijklmonoprstuvwxyz"
fingerprint      = "fo:oo:ba:ar:ba:ar"
private_key_path = "/absolute/path/to/api/key/your_api_key.pem"
######################################## COMMON VARIABLES ######################################
######################################## ARTIFACT SPECIFIC VARIABLES ######################################
ssh_public_key                          = "/absolute/path/to/api/key/your_ssh_public_key.pub"
ssh_private_key                         = "/absolute/path/to/api/key/your_ssh_private_key"
compute_nsg_name                        = "MY_NSG"
linux_compute_instance_compartment_name = "MY_ARTIFACT_COMPARTMENT"
linux_compute_network_compartment_name  = "MY_NETWORK_COMPARTMENT"
private_network_subnet_name             = "MY_PRIVATE_SUBNET"
vcn_display_name                        = "MY_VCN"

base_compute_image_ocid = "ocid1.image.oc1.uk-london-1.aaaaaaaabcedfghijklmonoprstuvwxyz" #Use OPC image

config_primary_name = "MY_CONFIG_PRIMARY_NAME"
config_primary_ad   = "aBCD:RE-REGION-1-AD-1"
config_primary_fd   = "FAULT-DOMAIN-1"
config_primary_shape = "VM.Standard2.1"

config_secondary_name = "MY_CONFIG_SECONDARY_NAME"
config_secondary_ad   = "aBCD:RE-REGION-1-AD-2"
config_secondary_fd   = "FAULT-DOMAIN-1"
config_secondary_shape = "VM.Standard2.1"

query_server_name = "MY_QUERY_SERVER"
query_server_shape = "VM.Standard2.1"
query_server_count = 2
query_server_ad_list = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
query_server_fd_list = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]

shard_replica_set_name = "MY_SHARD_NAME"
shard_replica_set_shape = "VM.Standard2.1"
shard_replica_set_count = 3 # MUST BE BETWEEN 3 AND 7
shard_replica_set_ad_list = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
shard_replica_set_fd_list = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]

instance_backup_policy_level = "bronze"

config_disk_size_in_gb       = "50"
config_disk_vpus_per_gb      = "10"
config_backup_policy_level   = "bronze"

query_disk_size_in_gb        = "50"
query_disk_vpus_per_gb       = "10"
query_backup_policy_level    = "bronze"

database_size_in_gb          = "50"
database_vpus_per_gb         = "10"
database_backup_policy_level = "bronze"

mongodb_version              = "5.0" #TESTED WITH ALL SUPPORTED VERSIONS AT THE TIME (4.0, 4.2, 4.4, 5.0)
######################################## ARTIFACT SPECIFIC VARIABLES ######################################
```

*Note: CHANGE variables.tf DESCRIPTIONS*


## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open source community.

## License
Copyright (c) 2021 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.
