# Terraform template for VcenterCluster in Boise Lab
provider "vsphere" {
  user    = var.user
  password = var.password
  vsphere_server = var.vsphereip

  allow_unverified_ssl = true

}

data "vsphere_datacenter" "dc" {
      name = "Boise Colo"
}

data "vsphere_datastore" "datastore" {
      name          = "NFS4-Datastore"
        datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
      name        = "Terraform"
      datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
      name          = "x3550 Cluster"
        datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
      name          = "10 Gb"
        datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
      name             = "RHEL8.2"
      datacenter_id = data.vsphere_datacenter.dc.id
}


## Define the VM

resource "vsphere_virtual_machine" "VMclone" {
      name              = "RHEL8.2-test9"
      resource_pool_id  = data.vsphere_compute_cluster.cluster.resource_pool_id
      datastore_id      = data.vsphere_datastore.datastore.id

      num_cpus          = var.cpus
      memory            = var.memory
      guest_id          = data.vsphere_virtual_machine.template.guest_id
      scsi_type         = data.vsphere_virtual_machine.template.scsi_type
      firmware          = "efi"

      # Network info
      network_interface {
        network_id      = data.vsphere_network.network.id
        adapter_type    = data.vsphere_virtual_machine.template.network_interface_types[0]
                        }
      # Disk info
      disk {
        name              = "disk0.vmdk"
        size              = data.vsphere_virtual_machine.template.disks.0.size
        thin_provisioned  = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
           }

      # Template clone info
      clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
            linux_options {
                host_name = "tf-test9"
                domain    = "boise.local"
            }

        network_interface {
            ipv4_address = var.serverip
            ipv4_netmask = 23
            }
            ipv4_gateway = var.servergateway
        }

      }
}

