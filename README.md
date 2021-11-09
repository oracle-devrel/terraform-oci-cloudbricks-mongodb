# OCI Cloud Bricks: MongoDB

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_terraform-oci-cloudbricks-mongodb)](https://sonarcloud.io/dashboard?id=oracle-devrel_terraform-oci-cloudbricks-mongodb)

## Introduction
The following brick contains the logic to provision a MonoDB database cluster in a highly available architecture. This includes 3-7 Config Servers, 3-7 Shards and any number of query servers.

This brick is only supported on Oracle Linux for the time being.

## Reference Architecture
The following is the reference architecture associated to this brick

![Reference Architecture](./images/Bricks_Architectures-mongodb.jpg)

### Prerequisites
- Pre-baked Artifact and Network Compartments
- Pre-baked VCN

# Sample tfvar file

If using Fixes Shapes.

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

config_server_name    = "MY_CONFIG_SERVER_NAME"
config_server_shape   = "VM.Standard2.1"
config_server_count   = 3
config_server_ad_list = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
config_server_fd_list = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]

query_server_name    = "MY_QUERY_SERVER"
query_server_shape   = "VM.Standard2.1"
query_server_count   = 2
query_server_ad_list = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
query_server_fd_list = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]

shard_replica_set_name    = "MY_SHARD_SERVER_NAME"
shard_replica_set_shape   = "VM.Standard2.1"
shard_replica_set_count   = 3
shard_replica_set_ad_list = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
shard_replica_set_fd_list = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]

instance_backup_policy_level = "bronze"

config_disk_size_in_gb     = "50"
config_disk_vpus_per_gb    = "10"
config_backup_policy_level = "bronze"

query_disk_size_in_gb     = "50"
query_disk_vpus_per_gb    = "10"
query_backup_policy_level = "bronze"

database_size_in_gb          = "50"
database_vpus_per_gb         = "10"
database_backup_policy_level = "bronze"

mongodb_version = "5.0"
######################################## ARTIFACT SPECIFIC VARIABLES ######################################
```

If using Flex Shapes.

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

config_server_name          = "MY_CONFIG_SERVER_NAME"
config_server_shape         = "VM.Standard.E4.Flex"
config_server_count         = 3
config_server_ad_list       = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
config_server_fd_list       = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]
config_server_is_flex_shape = true
config_server_ocpus         = 1
config_server_memory_in_gb  = 16

query_server_name          = "MY_QUERY_SERVER"
query_server_shape         = "VM.Standard.E4.Flex"
query_server_count         = 2
query_server_ad_list       = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
query_server_fd_list       = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]
query_server_is_flex_shape = true
query_server_ocpus         = 1
query_server_memory_in_gb  = 16

shard_replica_set_name          = "MY_SHARD_SERVER_NAME"
shard_replica_set_shape         = "VM.Standard.E4.Flex"
shard_replica_set_count         = 3
shard_replica_set_ad_list       = ["aBCD:RE-REGION-1-AD-1", "aBCD:RE-REGION-1-AD-2","aBCD:RE-REGION-1-AD-3" ]
shard_replica_set_fd_list       = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]
shard_replica_set_is_flex_shape = true
shard_replica_set_ocpus         = 1
shard_replica_set_memory_in_gb  = 16

instance_backup_policy_level = "bronze"

config_disk_size_in_gb     = "50"
config_disk_vpus_per_gb    = "10"
config_backup_policy_level = "bronze"

query_disk_size_in_gb     = "50"
query_disk_vpus_per_gb    = "10"
query_backup_policy_level = "bronze"

database_size_in_gb          = "50"
database_vpus_per_gb         = "10"
database_backup_policy_level = "bronze"

mongodb_version = "5.0" 
######################################## ARTIFACT SPECIFIC VARIABLES ######################################
```

### Variable Specific Conisderions
- Compute ssh keys to later log into instances. Paths to the keys should be provided in variables `ssh_public_key` and `ssh_private_key`.
- Variable `compute_nsg_name` is an optional network security group that can be attached.
- Variable `mongodb_version` may be set to any of the supported version of MongoDB at the time of creating this brick `(4.0, 4.2, 4.4 or 5.0)`.
- Variables `config_server_count` and `shard_replica_set_count` are used to choose how many config and shard servers are provisioned respectively. These can be anywhere between `1-7`, though it is recommended to use at least `3` each for high availability setups to function correctly.
- Variable `query_server_count` is used to choose how many query servers are provisioned. `2` is a reasonable amount to provision.
- Variable `instance_backup_policy_level` specifies the name of the backup policy used on the instance boot volumes.
- Variables `config_backup_policy_level` and `query_backup_policy_level` specificy the name of the backup policy used on the ISCSI disks storing log files on the config and query servers respectively.
- Variable `database_backup_policy_level` specifices the name of the backup policy used on the ISCSI disks storing database data on the shard servers.
- Variables `config_disk_size_in_gb` and `query_disk_size_in_gb` specify the size of the ISCSI disks in GB used to store log files on the config and query servers respectively. This can be between `50` and `32768`.
- Variable `config_disk_vpus_per_gb` and `query_disk_vpus_per_gb` specify the VPUs per GB of the ISCSI disks used to store log files on the config and query servers respectively. The value must be between `0` and `120` and be multiple of 10.
- Variable `database_size_in_gb` specifices the size of the ISCSI disks in GB used to store database data on the shard servers. This can be between `50` and `32768`.
- Variable `database_vpus_per_gb` specifices the VPUs per GB of the ISCSI disks used to store database data on the shard servers. The value must be between `0` and `120` and be multiple of 10.
- Flex Shapes:
  - Variable `config_server_is_flex_shape` should be defined as true when the config server instances are a flex shape. The variables `config_server_ocpus` and `config_server_memory_in_gb` should then also be defined. Do not use any of these variables at all when using a standard shape as they are not needed and assume sensible defaults.
  - Variable `query_server_is_flex_shape` should be defined as true when the query server instances are a flex shape. The variables `query_server_ocpus` and `query_server_memory_in_gb` should then also be defined. Do not use any of these variables at all when using a standard shape as they are not needed and assume sensible defaults.
  - Variable `shard_replica_set_is_flex_shape` should be defined as true when the shard server instances are a flex shape. The variables `shard_replica_set_ocpus` and `shard_replica_set_memory_in_gb` should then also be defined. Do not use any of these variables at all when using a standard shape as they are not needed and assume sensible defaults.


### Sample provider
The following is the base provider definition to be used with this module

```shell
terraform {
  required_version = ">= 0.13.5"
}
provider "oci" {
  region       = var.region
  tenancy_ocid = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  disable_auto_retries = "true"
}

provider "oci" {
  alias        = "home"
  region       = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
  tenancy_ocid = var.tenancy_ocid  
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  disable_auto_retries = "true"
}
```

## Variable documentation

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.5 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 4.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 4.45.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.format_disk_exec_config_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.format_disk_exec_query_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.format_disk_exec_shard_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_config_create_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_config_server_install_binaries](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_config_server_setup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_query_server_install_binaries](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_query_setup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_shard_replica_set_attach_shards](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_shard_replica_set_create_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_shard_replica_set_install_binaries](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mongodb_shard_replica_set_setup_shards](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mount_disk_exec_config_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mount_disk_exec_query_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.mount_disk_exec_shard_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.partition_disk_config_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.partition_disk_query_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.partition_disk_shard_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.provisioning_disk_config_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.provisioning_disk_query_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.provisioning_disk_shard_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.pvcreate_exec_config_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.pvcreate_exec_query_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.pvcreate_exec_shard_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vgcreate_exec_config_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vgcreate_exec_query_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vgcreate_exec_shard_replica_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [oci_core_instance.config_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_instance.query_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_instance.shard_replica_set](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_volume.ISCSIDisk_config_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume.ISCSIDisk_query_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume.ISCSIDisk_shard_replica_set](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.ISCSIDiskAttachment_config_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_attachment.ISCSIDiskAttachment_query_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy_assignment.backup_policy_assignment_ISCSI_Disk_config_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_volume_backup_policy_assignment.backup_policy_assignment_ISCSI_Disk_query_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_volume_backup_policy_assignment.backup_policy_assignment_ISCSI_Disk_shard_replica_set](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_volume_backup_policy_assignment.backup_policy_assignment_config_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_volume_backup_policy_assignment.backup_policy_assignment_query_server](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_volume_backup_policy_assignment.backup_policy_assignment_shard_replica_set](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_images.ORACLELINUX](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_images) | data source |
| [oci_core_network_security_groups.NSG](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_network_security_groups) | data source |
| [oci_core_subnets.PRIVATESUBNET](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_subnets) | data source |
| [oci_core_vcns.VCN](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_vcns) | data source |
| [oci_core_volume_backup_policies.CONFIGBACKUPPOLICY](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_volume_backup_policies) | data source |
| [oci_core_volume_backup_policies.DATABASEBACKUPPOLICY](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_volume_backup_policies) | data source |
| [oci_core_volume_backup_policies.INSTANCEBACKUPPOLICY](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_volume_backup_policies) | data source |
| [oci_core_volume_backup_policies.QUERYBACKUPPOLICY](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_volume_backup_policies) | data source |
| [oci_identity_compartments.COMPARTMENTS](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartments) | data source |
| [oci_identity_compartments.NWCOMPARTMENTS](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartments) | data source |
| [template_file.attach_shards_replica_set_sh](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.install_mongo_binaries_sh](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.setup_config_server_sh](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.setup_shard_replica_set_sh](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_nsg_name"></a> [compute\_nsg\_name](#input\_compute\_nsg\_name) | Name of the NSG associated to the computes | `string` | `""` | no |
| <a name="input_config_backup_policy_level"></a> [config\_backup\_policy\_level](#input\_config\_backup\_policy\_level) | The backup policy of config server ISCSI disks | `any` | n/a | yes |
| <a name="input_config_disk_size_in_gb"></a> [config\_disk\_size\_in\_gb](#input\_config\_disk\_size\_in\_gb) | The size of the attached disk to the config server instances, stores logging data | `any` | n/a | yes |
| <a name="input_config_disk_vpus_per_gb"></a> [config\_disk\_vpus\_per\_gb](#input\_config\_disk\_vpus\_per\_gb) | The VPUS of the attached disk to the config server instances | `any` | n/a | yes |
| <a name="input_config_server_ad_list"></a> [config\_server\_ad\_list](#input\_config\_server\_ad\_list) | The availability domains to provision the config server instances in | `any` | n/a | yes |
| <a name="input_config_server_count"></a> [config\_server\_count](#input\_config\_server\_count) | The number of config server instances to provision | `any` | n/a | yes |
| <a name="input_config_server_fd_list"></a> [config\_server\_fd\_list](#input\_config\_server\_fd\_list) | The fault domains to provision the config server instances in | `any` | n/a | yes |
| <a name="input_config_server_is_flex_shape"></a> [config\_server\_is\_flex\_shape](#input\_config\_server\_is\_flex\_shape) | Boolean to determine if the config server instances are flex or not | `bool` | `false` | no |
| <a name="input_config_server_memory_in_gb"></a> [config\_server\_memory\_in\_gb](#input\_config\_server\_memory\_in\_gb) | The amount of memory in GB for the config server instances to use when flex shape is enabled | `string` | `""` | no |
| <a name="input_config_server_name"></a> [config\_server\_name](#input\_config\_server\_name) | The name given to the config server instances | `any` | n/a | yes |
| <a name="input_config_server_ocpus"></a> [config\_server\_ocpus](#input\_config\_server\_ocpus) | The number of OCPUS for the config server instances to use when flex shape is enabled | `string` | `""` | no |
| <a name="input_config_server_shape"></a> [config\_server\_shape](#input\_config\_server\_shape) | The shape for the config server instances to use | `any` | n/a | yes |
| <a name="input_database_backup_policy_level"></a> [database\_backup\_policy\_level](#input\_database\_backup\_policy\_level) | Backup policy level for Database ISCSI disks | `any` | n/a | yes |
| <a name="input_database_size_in_gb"></a> [database\_size\_in\_gb](#input\_database\_size\_in\_gb) | The size of the attached disk to the shard server instances, stores database data | `any` | n/a | yes |
| <a name="input_database_vpus_per_gb"></a> [database\_vpus\_per\_gb](#input\_database\_vpus\_per\_gb) | The VPUS of the attached disk to the shard server instances | `any` | n/a | yes |
| <a name="input_fingerprint"></a> [fingerprint](#input\_fingerprint) | API Key Fingerprint for user\_ocid derived from public API Key imported in OCI User config | `any` | n/a | yes |
| <a name="input_instance_backup_policy_level"></a> [instance\_backup\_policy\_level](#input\_instance\_backup\_policy\_level) | The backup policy of all instances boot volumes | `any` | n/a | yes |
| <a name="input_linux_compute_instance_compartment_name"></a> [linux\_compute\_instance\_compartment\_name](#input\_linux\_compute\_instance\_compartment\_name) | Defines the compartment name where the infrastructure will be created | `any` | n/a | yes |
| <a name="input_linux_compute_network_compartment_name"></a> [linux\_compute\_network\_compartment\_name](#input\_linux\_compute\_network\_compartment\_name) | Defines the compartment where the Network is currently located | `any` | n/a | yes |
| <a name="input_mongodb_version"></a> [mongodb\_version](#input\_mongodb\_version) | The version of MongoDB used in the setup | `any` | n/a | yes |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Private Key Absolute path location where terraform is executed | `any` | n/a | yes |
| <a name="input_private_network_subnet_name"></a> [private\_network\_subnet\_name](#input\_private\_network\_subnet\_name) | Defines the subnet display name where this resource will be created at | `any` | n/a | yes |
| <a name="input_query_backup_policy_level"></a> [query\_backup\_policy\_level](#input\_query\_backup\_policy\_level) | The backup policy of query server ISCSI disks | `any` | n/a | yes |
| <a name="input_query_disk_size_in_gb"></a> [query\_disk\_size\_in\_gb](#input\_query\_disk\_size\_in\_gb) | The size of the attached disk to the query server instances, stores logging data | `any` | n/a | yes |
| <a name="input_query_disk_vpus_per_gb"></a> [query\_disk\_vpus\_per\_gb](#input\_query\_disk\_vpus\_per\_gb) | The VPUS of the attached disk to the query server instances | `any` | n/a | yes |
| <a name="input_query_server_ad_list"></a> [query\_server\_ad\_list](#input\_query\_server\_ad\_list) | The availability domains to provision the query server instances in | `any` | n/a | yes |
| <a name="input_query_server_count"></a> [query\_server\_count](#input\_query\_server\_count) | The number of query server instances to provision | `any` | n/a | yes |
| <a name="input_query_server_fd_list"></a> [query\_server\_fd\_list](#input\_query\_server\_fd\_list) | The fault domains to provision the query server instances in | `any` | n/a | yes |
| <a name="input_query_server_is_flex_shape"></a> [query\_server\_is\_flex\_shape](#input\_query\_server\_is\_flex\_shape) | Boolean to determine if the query server instances are flex or not | `bool` | `false` | no |
| <a name="input_query_server_memory_in_gb"></a> [query\_server\_memory\_in\_gb](#input\_query\_server\_memory\_in\_gb) | The amount of memory in GB for the query server instances to use when flex shape is enabled | `string` | `""` | no |
| <a name="input_query_server_name"></a> [query\_server\_name](#input\_query\_server\_name) | The name given to the query server instances instance | `any` | n/a | yes |
| <a name="input_query_server_ocpus"></a> [query\_server\_ocpus](#input\_query\_server\_ocpus) | The number of OCPUS for the query server instances to use when flex shape is enabled | `string` | `""` | no |
| <a name="input_query_server_shape"></a> [query\_server\_shape](#input\_query\_server\_shape) | The shape for the query server instances to use | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Target region where artifacts are going to be created | `any` | n/a | yes |
| <a name="input_shard_replica_set_ad_list"></a> [shard\_replica\_set\_ad\_list](#input\_shard\_replica\_set\_ad\_list) | The availability domains to provision the shard server instances in | `any` | n/a | yes |
| <a name="input_shard_replica_set_count"></a> [shard\_replica\_set\_count](#input\_shard\_replica\_set\_count) | The number of shard server instances to provision | `any` | n/a | yes |
| <a name="input_shard_replica_set_fd_list"></a> [shard\_replica\_set\_fd\_list](#input\_shard\_replica\_set\_fd\_list) | The fault domains to provision the shard server instances in | `any` | n/a | yes |
| <a name="input_shard_replica_set_is_flex_shape"></a> [shard\_replica\_set\_is\_flex\_shape](#input\_shard\_replica\_set\_is\_flex\_shape) | Boolean to determine if the shard server instances are flex or not | `bool` | `false` | no |
| <a name="input_shard_replica_set_memory_in_gb"></a> [shard\_replica\_set\_memory\_in\_gb](#input\_shard\_replica\_set\_memory\_in\_gb) | The amount of memory in GB for the shard server instances to use when flex shape is enabled | `string` | `""` | no |
| <a name="input_shard_replica_set_name"></a> [shard\_replica\_set\_name](#input\_shard\_replica\_set\_name) | The name given to the shard server instances | `any` | n/a | yes |
| <a name="input_shard_replica_set_ocpus"></a> [shard\_replica\_set\_ocpus](#input\_shard\_replica\_set\_ocpus) | The number of OCPUS for the shard server instances to use when flex shape is enabled | `string` | `""` | no |
| <a name="input_shard_replica_set_shape"></a> [shard\_replica\_set\_shape](#input\_shard\_replica\_set\_shape) | The shape for the shard server instances to use | `any` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Defines SSH Private Key to be used in order to remotely connect to compute instances | `any` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Defines SSH Public Key to be used in order to remotely connect to compute instances | `any` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | OCID of tenancy | `any` | n/a | yes |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | User OCID in tenancy. Currently hardcoded to user denny.alquinta@oracle.com | `any` | n/a | yes |
| <a name="input_vcn_display_name"></a> [vcn\_display\_name](#input\_vcn\_display\_name) | VCN Display name to execute lookup | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mongodb_config_servers"></a> [mongodb\_config\_servers](#output\_mongodb\_config\_servers) | MongoDB Config Server Instances |
| <a name="output_mongodb_query_servers"></a> [mongodb\_query\_servers](#output\_mongodb\_query\_servers) | MongoDB Query Server Instances |
| <a name="output_mongodb_shard_servers"></a> [mongodb\_shard\_servers](#output\_mongodb\_shard\_servers) | MongoDB Shard Server Instances |

## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open source community.

## License
Copyright (c) 2021 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.
