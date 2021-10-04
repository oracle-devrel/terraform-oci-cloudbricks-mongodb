# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# compute.tf
#
# Purpose: The following script defines the declaration of computes needed for the MongoDB deployment
# Registry: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment


resource "oci_core_instance" "config_server" {
  count               = var.config_server_count
  availability_domain = var.config_server_ad_list[count.index % length(var.config_server_ad_list)]
  compartment_id      = local.compartment_id
  display_name        = "${var.config_server_name}${count.index + 1}"
  shape               = var.config_server_shape

  dynamic "shape_config" {
    for_each = var.config_server_is_flex_shape ? [1] : []
    content {
      ocpus         = var.config_server_ocpus
      memory_in_gbs = var.config_server_memory_in_gb
    }
  }

  fault_domain = var.config_server_fd_list[floor(count.index / length(var.config_server_fd_list))]

  create_vnic_details {
    subnet_id        = local.private_subnet_ocid
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "${var.config_server_name}${count.index + 1}"
    nsg_ids          = local.nsg_id == "" ? [] : [local.nsg_id]
  }

  source_details {
    source_type = "image"
    source_id   = local.base_compute_image_ocid
  }

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = "opc"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}


resource "oci_core_instance" "query_server" {
  count               = var.query_server_count
  availability_domain = var.query_server_ad_list[count.index % length(var.query_server_ad_list)]
  compartment_id      = local.compartment_id
  display_name        = "${var.query_server_name}${count.index + 1}"
  shape               = var.query_server_shape

  dynamic "shape_config" {
    for_each = var.query_server_is_flex_shape ? [1] : []
    content {
      ocpus         = var.query_server_ocpus
      memory_in_gbs = var.query_server_memory_in_gb
    }
  }

  fault_domain = var.query_server_fd_list[floor(count.index / length(var.query_server_fd_list))]

  create_vnic_details {
    subnet_id        = local.private_subnet_ocid
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "${var.query_server_name}${count.index + 1}"
    nsg_ids          = local.nsg_id == "" ? [] : [local.nsg_id]
  }

  source_details {
    source_type = "image"
    source_id   = local.base_compute_image_ocid
  }

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = "opc"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}


resource "oci_core_instance" "shard_replica_set" {
  count               = var.shard_replica_set_count
  availability_domain = var.shard_replica_set_ad_list[count.index % length(var.shard_replica_set_ad_list)]
  compartment_id      = local.compartment_id
  display_name        = "${var.shard_replica_set_name}${count.index + 1}"
  shape               = var.shard_replica_set_shape

  dynamic "shape_config" {
    for_each = var.shard_replica_set_is_flex_shape ? [1] : []
    content {
      ocpus         = var.shard_replica_set_ocpus
      memory_in_gbs = var.shard_replica_set_memory_in_gb
    }
  }

  fault_domain = var.query_server_fd_list[floor(count.index / length(var.query_server_fd_list))]

  create_vnic_details {
    subnet_id        = local.private_subnet_ocid
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "${var.shard_replica_set_name}${count.index + 1}"
    nsg_ids          = local.nsg_id == "" ? [] : [local.nsg_id]
  }

  source_details {
    source_type = "image"
    source_id   = local.base_compute_image_ocid
  }

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = "opc"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}


resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_config_server" {
  count      = var.config_server_count
  depends_on = [oci_core_instance.config_server]
  asset_id   = oci_core_instance.config_server[count.index].boot_volume_id
  policy_id  = local.instance_backup_policy_id
}


resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_query_server" {
  count      = var.query_server_count
  depends_on = [oci_core_instance.query_server]
  asset_id   = oci_core_instance.query_server[count.index].boot_volume_id
  policy_id  = local.instance_backup_policy_id
}


resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_shard_replica_set" {
  count      = var.shard_replica_set_count
  depends_on = [oci_core_instance.shard_replica_set]
  asset_id   = oci_core_instance.shard_replica_set[count.index].boot_volume_id
  policy_id  = local.instance_backup_policy_id
}
