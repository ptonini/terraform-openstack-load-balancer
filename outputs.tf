output "this" {
  value = openstack_lb_loadbalancer_v2.this
}

output "address" {
  value = openstack_networking_floatingip_v2.this.address
}