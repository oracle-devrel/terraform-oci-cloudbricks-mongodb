# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# mongoconfig.tf
#
# Purpose: The following script remotely executes all the setup scripts on the MongoDB compute instances


data "template_file" "install_mongo_binaries_sh" {
  template = file("${path.module}/scripts/install_mongo_binaries.sh")

  vars = {
    mongodb_version = var.mongodb_version
  }
}

data "template_file" "setup_config_server_sh" {
  count      = var.config_server_count
  depends_on = [oci_core_instance.config_server]
  template   = file("${path.module}/scripts/setup_config_server.sh")
  vars = {
    config_server_ip = oci_core_instance.config_server[count.index].private_ip
  }
}

data "template_file" "setup_shard_replica_set_sh" {
  count      = var.shard_replica_set_count
  depends_on = [oci_core_instance.shard_replica_set]
  template   = file("${path.module}/scripts/setup_shard.sh")

  vars = {
    shard_ip = oci_core_instance.shard_replica_set[count.index].private_ip
  }
}

data "template_file" "attach_shards_replica_set_sh" {
  count      = var.query_server_count
  depends_on = [oci_core_instance.shard_replica_set]
  template   = file("${path.module}/scripts/attach_shards.sh")

  vars = {
    shard_ips       = jsonencode(oci_core_instance.shard_replica_set.*.private_ip)
    query_server_ip = oci_core_instance.query_server[count.index].private_ip
  }
}


resource "null_resource" "mongodb_config_server_install_binaries" {
  count = var.config_server_count
  depends_on = [oci_core_instance.config_server,
    null_resource.provisioning_disk_config_server,
    null_resource.partition_disk_config_server,
    null_resource.pvcreate_exec_config_server,
    null_resource.vgcreate_exec_config_server,
    null_resource.format_disk_exec_config_server,
    null_resource.mount_disk_exec_config_server
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/install_mongo_binaries.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    content     = data.template_file.install_mongo_binaries_sh.rendered
    destination = "/tmp/install_mongo_binaries.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/install_mongo_binaries.sh",
      "sudo /tmp/install_mongo_binaries.sh"
    ]
  }
}


resource "null_resource" "mongodb_config_server_setup" {
  count      = var.config_server_count
  depends_on = [null_resource.mongodb_config_server_install_binaries]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/setup_config_server.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    content     = data.template_file.setup_config_server_sh[count.index].rendered
    destination = "/tmp/setup_config_server.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/setup_config_server.sh",
      "sudo /tmp/setup_config_server.sh"
    ]
  }
}


resource "null_resource" "mongodb_config_create_replica_set" {
  depends_on = [
    null_resource.mongodb_config_server_setup,
    # null_resource.mongodb_config_seconday_setup
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[0].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/create_config_replica_set.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[0].private_ip
      private_key = file(var.ssh_private_key)
    }

    source      = "${path.module}/scripts/create_config_replica_set.sh"
    destination = "/tmp/create_config_replica_set.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.config_server[0].private_ip
      private_key = file(var.ssh_private_key)

    }

    inline = [
      "chmod +x /tmp/create_config_replica_set.sh",
      "sudo /tmp/create_config_replica_set.sh ${jsonencode(oci_core_instance.config_server.*.private_ip)} ${var.config_server_count}"
    ]
  }
}




resource "null_resource" "mongodb_query_server_install_binaries" {
  count = var.query_server_count
  depends_on = [oci_core_instance.query_server,
    null_resource.provisioning_disk_query_server,
    null_resource.partition_disk_query_server,
    null_resource.pvcreate_exec_query_server,
    null_resource.vgcreate_exec_query_server,
    null_resource.format_disk_exec_query_server,
    null_resource.mount_disk_exec_query_server
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/install_mongo_binaries.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    content     = data.template_file.install_mongo_binaries_sh.rendered
    destination = "/tmp/install_mongo_binaries.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/install_mongo_binaries.sh",
      "sudo /tmp/install_mongo_binaries.sh"
    ]
  }
}


resource "null_resource" "mongodb_query_setup" {
  count = var.query_server_count
  depends_on = [
    null_resource.mongodb_query_server_install_binaries,
    null_resource.mongodb_config_create_replica_set
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/setup_query_server.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    source      = "${path.module}/scripts/setup_query_server.sh"
    destination = "/tmp/setup_query_server.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/setup_query_server.sh",
      "sudo /tmp/setup_query_server.sh ${jsonencode(oci_core_instance.config_server.*.private_ip)} ${oci_core_instance.query_server[count.index].private_ip}"
    ]
  }
}




resource "null_resource" "mongodb_shard_replica_set_install_binaries" {
  count = var.shard_replica_set_count
  depends_on = [oci_core_instance.shard_replica_set,
    null_resource.provisioning_disk_shard_replica_set,
    null_resource.partition_disk_shard_replica_set,
    null_resource.pvcreate_exec_shard_replica_set,
    null_resource.vgcreate_exec_shard_replica_set,
    null_resource.format_disk_exec_shard_replica_set,
    null_resource.mount_disk_exec_shard_replica_set
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/install_mongo_binaries.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    content     = data.template_file.install_mongo_binaries_sh.rendered
    destination = "/tmp/install_mongo_binaries.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/install_mongo_binaries.sh",
      "sudo /tmp/install_mongo_binaries.sh"
    ]
  }
}


resource "null_resource" "mongodb_shard_replica_set_setup_shards" {
  count = var.shard_replica_set_count
  depends_on = [
    null_resource.mongodb_shard_replica_set_install_binaries,
    null_resource.mongodb_query_setup
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/setup_shard.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    content     = data.template_file.setup_shard_replica_set_sh[count.index].rendered
    destination = "/tmp/setup_shard.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/setup_shard.sh",
      "sudo /tmp/setup_shard.sh"
    ]
  }
}


resource "null_resource" "mongodb_shard_replica_set_create_replica_set" {
  depends_on = [
    null_resource.mongodb_shard_replica_set_setup_shards
  ]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[0].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/create_shard_replica_set.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[0].private_ip
      private_key = file(var.ssh_private_key)
    }

    source      = "${path.module}/scripts/create_shard_replica_set.sh"
    destination = "/tmp/create_shard_replica_set.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.shard_replica_set[0].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/create_shard_replica_set.sh",
      "sudo /tmp/create_shard_replica_set.sh ${jsonencode(oci_core_instance.shard_replica_set.*.private_ip)} ${var.shard_replica_set_count}"
    ]
  }
}


resource "null_resource" "mongodb_shard_replica_set_attach_shards" {
  count = var.query_server_count
  depends_on = [
    null_resource.mongodb_shard_replica_set_create_replica_set
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo rm -rf /tmp/attach_shards.sh"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    content     = data.template_file.attach_shards_replica_set_sh[count.index].rendered
    destination = "/tmp/attach_shards.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.query_server[count.index].private_ip
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "chmod +x /tmp/attach_shards.sh",
      "sudo /tmp/attach_shards.sh"
    ]
  }
}
