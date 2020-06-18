# Variables
variable "ibmcloud_api_key" {
    description = "The IBM Cloud API Key to use."
}
variable "region" {
    description = "IBM Cloud region being used"
    default = "us-south"
}
variable "image" {
    description = "Image used (VPC)"
}
variable "profile" {
    description = "VSI Profile to use (VPC)"
}
variable "sshkey" {
    description = "SSH Key to use"
}
variable "ibmpowerservice" {
    description = "Power instance service id"
}
variable "aix72img" {
    description = "IBM 7.2 image"
}
variable "ibmcloudinstanceid" {
    description = "IBM Cloud Instance ID"
}

variable "networks" {
    description = "Power instance network to use"
    default = ["powertest-net1"]
  
}


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

resource "ibm_pi_key" "powertest-key" {
  pi_cloud_instance_id = var.ibmcloudinstanceid
  pi_key_name = "powertest-key"
  pi_ssh_key = var.sshkey
}

##################################################
# /$$$$$$$                                            
#| $$__  $$                                           
#| $$  \ $$ /$$$$$$  /$$  /$$  /$$  /$$$$$$   /$$$$$$ 
#| $$$$$$$//$$__  $$| $$ | $$ | $$ /$$__  $$ /$$__  $$
#| $$____/| $$  \ $$| $$ | $$ | $$| $$$$$$$$| $$  \__/
#| $$     | $$  | $$| $$ | $$ | $$| $$_____/| $$      
#| $$     |  $$$$$$/|  $$$$$/$$$$/|  $$$$$$$| $$      
#|__/      \______/  \_____/\___/  \_______/|__/      
#                                                 
##################################################

# First create our service
### This is created manually for the sandbox ###

######################################
#       Instances                    #
######################################
# Instance details 

resource "ibm_pi_instance" "powertest-instance" {
  pi_cloud_instance_id = var.ibmcloudinstanceid
  pi_image_id = var.aix72img
  pi_instance_name = "powertest-vm1"
  pi_key_pair_name = ibm_pi_key.powertest-key.id
  pi_memory = "2"
  pi_network_ids = [ibm_pi_network.powertest-net.id]
  pi_processors = ".25"
  pi_proc_type = "shared"
  pi_sys_type = "e880"
  pi_volume_ids = [ibm_pi_volume.powertest-vol.id]

}

resource "ibm_pi_network" "powertest-net" {
  pi_cloud_instance_id = var.ibmcloudinstanceid
  pi_network_name = "powertest-net1"
  pi_network_type = "vlan"
  pi_dns = ["127.0.0.1"]
  pi_cidr = "10.240.20.0/24"
}

resource "ibm_pi_volume" "powertest-vol" {
    pi_cloud_instance_id = var.ibmcloudinstanceid
    pi_volume_name = "powertest-vol1"
    pi_volume_shareable = false
    pi_volume_size = 15
    pi_volume_type = "tier3"
}