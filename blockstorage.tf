# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# blockstorage.tf
#
# Purpose: The following script defines the declaration for block volumes using ISCSI Disks
# Registry: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment

# Create Disk
resource "oci_core_volume" "ISCSIDisk_config_server" {
  count               = var.config_server_count
  availability_domain = var.config_server_ad_list[count.index % length(var.config_server_ad_list)]
  compartment_id      = local.compartment_id
  display_name        = "${oci_core_instance.config_server[count.index].display_name}_disk"
  size_in_gbs         = var.config_disk_size_in_gb
  vpus_per_gb         = var.config_disk_vpus_per_gb
}

# Create Disk Attachment
resource "oci_core_volume_attachment" "ISCSIDiskAttachment_config_server" {
  count           = var.config_server_count
  depends_on      = [oci_core_volume.ISCSIDisk_config_server]
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.config_server[count.index].id
  volume_id       = oci_core_volume.ISCSIDisk_config_server[count.index].id
}

# Assignment of backup policy for ProdDisk
resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_ISCSI_Disk_config_server" {
  count     = var.config_server_count
  asset_id  = oci_core_volume.ISCSIDisk_config_server[count.index].id
  policy_id = local.config_backup_policy_id
}


# Create Disk
resource "oci_core_volume" "ISCSIDisk_query_server" {
  count               = var.query_server_count
  availability_domain = var.query_server_ad_list[count.index % length(var.query_server_ad_list)]
  compartment_id      = local.compartment_id
  display_name        = "${oci_core_instance.query_server[count.index].display_name}_disk"
  size_in_gbs         = var.query_disk_size_in_gb
  vpus_per_gb         = var.query_disk_vpus_per_gb
}

# Create Disk Attachment
resource "oci_core_volume_attachment" "ISCSIDiskAttachment_query_server" {
  count           = var.query_server_count
  depends_on      = [oci_core_volume.ISCSIDisk_query_server]
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.query_server[count.index].id
  volume_id       = oci_core_volume.ISCSIDisk_query_server[count.index].id
}

# Assignment of backup policy for ProdDisk
resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_ISCSI_Disk_query_server" {
  count     = var.query_server_count
  asset_id  = oci_core_volume.ISCSIDisk_query_server[count.index].id
  policy_id = local.query_backup_policy_id
}


# Create Disk
resource "oci_core_volume" "ISCSIDisk_shard_replica_set" {
  count               = var.shard_replica_set_count
  availability_domain = var.shard_replica_set_ad_list[count.index % length(var.shard_replica_set_ad_list)]
  compartment_id      = local.compartment_id
  display_name        = "${oci_core_instance.shard_replica_set[count.index].display_name}_disk"
  size_in_gbs         = var.database_size_in_gb
  vpus_per_gb         = var.database_vpus_per_gb
}

# Create Disk Attachment
resource "oci_core_volume_attachment" "ISCSIDiskAttachment_shard_replica_set" {
  count           = var.shard_replica_set_count
  depends_on      = [oci_core_volume.ISCSIDisk_shard_replica_set]
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.shard_replica_set[count.index].id
  volume_id       = oci_core_volume.ISCSIDisk_shard_replica_set[count.index].id
}

# Assignment of backup policy for ProdDisk
resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_ISCSI_Disk_shard_replica_set" {
  count     = var.shard_replica_set_count
  asset_id  = oci_core_volume.ISCSIDisk_shard_replica_set[count.index].id
  policy_id = local.database_backup_policy_id
}
