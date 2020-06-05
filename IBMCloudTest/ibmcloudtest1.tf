
######################################
#       Housekeeping                 #
######################################
# Variables
variable "ibmcloud_api_key" {}
variable "region" {}
variable "image" {}
variable "profile" {}
variable "sshkey" {}

# Provider information
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  generation = 1
  region = var.region
}

######################################
#       SSH Keys                     #
######################################
# SSH Key for access (Refers to test1.priv)
resource "ibm_is_ssh_key" "tf-testkey" {
  name = "test-key"
  public_key = var.sshkey
}


######################################
#         VPC Section                #
######################################
# VPC section
resource "ibm_is_vpc" "tf-test1-vpc" {
  name = "test1-vpc"
}

# Security group to allow ssh and icmp
resource "ibm_is_security_group" "tf-test1-secgrp" {
  name = "tftest-secgrp-ssh-icmp"
  vpc = ibm_is_vpc.tf-test1-vpc.id
}


# ICMP rule that attaches to tf-test1-secgrp
resource "ibm_is_security_group_rule" "test1-secgrp-icmp" {
  group = ibm_is_security_group.tf-test1-secgrp.id
  direction = "inbound"
  remote = "0.0.0.0/0"
    icmp {
      type = 8
    }
}

# SSH rule that attches to tf-test1-secgrp
resource "ibm_is_security_group_rule" "test1-secgrp-ssh" {
  group = ibm_is_security_group.tf-test1-secgrp.id
  direction = "inbound"
  remote = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Main subnet 10.240.30.0/24
resource "ibm_is_subnet" "tf-test1-subnet" {
  name    = "test1-subnet"
  vpc     = ibm_is_vpc.tf-test1-vpc.id 
  zone    = "us-south-1"
  ipv4_cidr_block = "10.240.30.0/24"
}


#######################################
#       Instance Section              #
#######################################

## Begin instance configuration
resource "ibm_is_instance" "tf-test1-instance" {
  name    = "test1-instance"
  image   = "cfdaf1a0-5350-4350-fcbc-97173b510843"
  profile = "cc1-2x4"
 
 # primary network interface..attach the floating ip to this interface
  primary_network_interface {
      name = "ethPrimary0"
      subnet = ibm_is_subnet.tf-test1-subnet.id
      security_groups = [ibm_is_security_group.tf-test1-secgrp.id]
    }

  vpc = ibm_is_vpc.tf-test1-vpc.id 
  zone = "us-south-1"
  keys = [ibm_is_ssh_key.tf-testkey.id]

  timeouts {
    create = "90m"
    delete = "30m"
  }

}

# Floating IP.  Connect to main instance interface
resource "ibm_is_floating_ip" "test1-floatingip" {
  name = "test1fip1"
  target = ibm_is_instance.tf-test1-instance.primary_network_interface.0.id
}
