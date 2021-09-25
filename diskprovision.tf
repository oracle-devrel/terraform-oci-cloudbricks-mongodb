# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# diskprovision.tf
#
# Purpose: The following script defines the logic to format and present a disk to a machine idempotently 


resource "null_resource" "provisioning_disk_config_server" {
  count      = var.config_server_count
  depends_on = [oci_core_volume_attachment.ISCSIDiskAttachment_config_server]

  connection {
    type        = "ssh"
    host        = oci_core_instance.config_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # register and connect the iSCSI block volume

  provisioner "remote-exec" {

    inline = [
      "set +x",
      "${local.iscsiadm} -m node -o new -T ${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].port}",
      "${local.iscsiadm} -m node -o update -T ${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn} -n node.startup -v automatic",
      "${local.iscsiadm} -m node -T ${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].port} -l",
    ]
  }
}


resource "null_resource" "partition_disk_config_server" {
  count      = var.config_server_count
  depends_on = [null_resource.provisioning_disk_config_server]

  connection {
    type        = "ssh"
    host        = oci_core_instance.config_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn}-lun-1",
      "${local.fdisk} $${DEVICE_ID}",
    ]
  }
}


resource "null_resource" "pvcreate_exec_config_server" {
  count      = var.config_server_count
  depends_on = [null_resource.partition_disk_config_server]
  connection {
    type        = "ssh"
    host        = oci_core_instance.config_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn}-lun-1",
      "${local.pvcreate} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "vgcreate_exec_config_server" {
  count      = var.config_server_count
  depends_on = [null_resource.pvcreate_exec_config_server]
  connection {
    type        = "ssh"
    host        = oci_core_instance.config_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn}-lun-1",
      "${local.vgcreate} ${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].display_name} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "format_disk_exec_config_server" {
  count = var.config_server_count
  depends_on = [
    null_resource.vgcreate_exec_config_server,
    oci_core_volume_attachment.ISCSIDiskAttachment_config_server
  ]
  connection {
    type        = "ssh"
    host        = oci_core_instance.config_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s $${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -ne 0 ] ; then",
      "while [[ ! -e $${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "${local.mkfs_xfs} $${DEVICE_ID}-part1 -f",
      "fi",
    ]
  }
}


resource "null_resource" "mount_disk_exec_config_server" {
  count = var.config_server_count
  depends_on = [null_resource.format_disk_exec_config_server,
    oci_core_volume_attachment.ISCSIDiskAttachment_config_server
  ]
  connection {
    type        = "ssh"
    host        = oci_core_instance.config_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export MOUNTED_DISKS=$(cat /etc/fstab |grep u01 |wc -l)",
      "if [ $MOUNTED_DISKS -eq 0 ] ; then",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_config_server[count.index].iqn}-lun-1",
      "sudo mkdir -p /u01/",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value $${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /u01/ xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "sudo chown -R opc:opc /u01/",
      "cd /",
      "fi",
    ]
  }
}


#Create Disk Attachment
resource "null_resource" "provisioning_disk_query_server" {
  count      = var.query_server_count
  depends_on = [oci_core_volume_attachment.ISCSIDiskAttachment_query_server]

  connection {
    type        = "ssh"
    host        = oci_core_instance.query_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # register and connect the iSCSI block volume

  provisioner "remote-exec" {

    inline = [
      "set +x",
      "${local.iscsiadm} -m node -o new -T ${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].port}",
      "${local.iscsiadm} -m node -o update -T ${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn} -n node.startup -v automatic",
      "${local.iscsiadm} -m node -T ${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].port} -l",
    ]
  }
}


resource "null_resource" "partition_disk_query_server" {
  count      = var.query_server_count
  depends_on = [null_resource.provisioning_disk_query_server]

  connection {
    type        = "ssh"
    host        = oci_core_instance.query_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn}-lun-1",
      "${local.fdisk} $${DEVICE_ID}",
    ]
  }
}


resource "null_resource" "pvcreate_exec_query_server" {
  count      = var.query_server_count
  depends_on = [null_resource.partition_disk_query_server]
  connection {
    type        = "ssh"
    host        = oci_core_instance.query_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn}-lun-1",
      "${local.pvcreate} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "vgcreate_exec_query_server" {
  count      = var.query_server_count
  depends_on = [null_resource.pvcreate_exec_query_server]
  connection {
    type        = "ssh"
    host        = oci_core_instance.query_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn}-lun-1",
      "${local.vgcreate} ${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].display_name} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "format_disk_exec_query_server" {
  count = var.query_server_count
  depends_on = [
    null_resource.vgcreate_exec_query_server,
    oci_core_volume_attachment.ISCSIDiskAttachment_query_server
  ]
  connection {
    type        = "ssh"
    host        = oci_core_instance.query_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s $${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -ne 0 ] ; then",
      "while [[ ! -e $${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "${local.mkfs_xfs} $${DEVICE_ID}-part1 -f",
      "fi",
    ]
  }
}

resource "null_resource" "mount_disk_exec_query_server" {
  count = var.query_server_count
  depends_on = [null_resource.format_disk_exec_query_server,
    oci_core_volume_attachment.ISCSIDiskAttachment_query_server
  ]
  connection {
    type        = "ssh"
    host        = oci_core_instance.query_server[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export MOUNTED_DISKS=$(cat /etc/fstab |grep u01 |wc -l)",
      "if [ $MOUNTED_DISKS -eq 0 ] ; then",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_query_server[count.index].iqn}-lun-1",
      "sudo mkdir -p /u01/",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value $${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /u01/ xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "sudo chown -R opc:opc /u01/",
      "cd /",
      "fi",
    ]
  }
}



resource "null_resource" "provisioning_disk_shard_replica_set" {
  count      = var.shard_replica_set_count
  depends_on = [oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set]

  connection {
    type        = "ssh"
    host        = oci_core_instance.shard_replica_set[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # register and connect the iSCSI block volume

  provisioner "remote-exec" {

    inline = [
      "set +x",
      "${local.iscsiadm} -m node -o new -T ${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].port}",
      "${local.iscsiadm} -m node -o update -T ${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn} -n node.startup -v automatic",
      "${local.iscsiadm} -m node -T ${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].port} -l",
    ]
  }
}


resource "null_resource" "partition_disk_shard_replica_set" {
  count      = var.shard_replica_set_count
  depends_on = [null_resource.provisioning_disk_shard_replica_set]

  connection {
    type        = "ssh"
    host        = oci_core_instance.shard_replica_set[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn}-lun-1",
      "${local.fdisk} $${DEVICE_ID}",
    ]
  }
}


resource "null_resource" "pvcreate_exec_shard_replica_set" {
  count      = var.shard_replica_set_count
  depends_on = [null_resource.partition_disk_shard_replica_set]
  connection {
    type        = "ssh"
    host        = oci_core_instance.shard_replica_set[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn}-lun-1",
      "${local.pvcreate} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "vgcreate_exec_shard_replica_set" {
  count      = var.shard_replica_set_count
  depends_on = [null_resource.pvcreate_exec_shard_replica_set]
  connection {
    type        = "ssh"
    host        = oci_core_instance.shard_replica_set[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn}-lun-1",
      "${local.vgcreate} ${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].display_name} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "format_disk_exec_shard_replica_set" {
  count = var.shard_replica_set_count
  depends_on = [
    null_resource.vgcreate_exec_shard_replica_set,
    oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set
  ]
  connection {
    type        = "ssh"
    host        = oci_core_instance.shard_replica_set[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s $${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -ne 0 ] ; then",
      "while [[ ! -e $${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "${local.mkfs_xfs} $${DEVICE_ID}-part1 -f",
      "fi",
    ]
  }
}

resource "null_resource" "mount_disk_exec_shard_replica_set" {
  count = var.shard_replica_set_count
  depends_on = [null_resource.format_disk_exec_shard_replica_set,
    oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set
  ]
  connection {
    type        = "ssh"
    host        = oci_core_instance.shard_replica_set[count.index].private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export MOUNTED_DISKS=$(cat /etc/fstab |grep u01 |wc -l)",
      "if [ $MOUNTED_DISKS -eq 0 ] ; then",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment_shard_replica_set[count.index].iqn}-lun-1",
      "sudo mkdir -p /u01/",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value $${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /u01/ xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "sudo chown -R opc:opc /u01/",
      "cd /",
      "fi",
    ]
  }
}
