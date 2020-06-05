output "internal_ip_address"{
    value = ibm_is_instance.tf-test1-instance.primary_network_interface[0].primary_ipv4_address
}

output "external_floating_ip" {
    value = ibm_is_floating_ip.test1-floatingip.address
}