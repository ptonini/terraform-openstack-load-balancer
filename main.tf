resource "openstack_lb_loadbalancer_v2" "this" {
  name          = var.name
  vip_subnet_id = var.vip_subnet_id
}

resource "openstack_networking_floatingip_v2" "this" {
  pool = var.public_network_name
}

resource "openstack_networking_floatingip_associate_v2" "this" {
  floating_ip = openstack_networking_floatingip_v2.this.address
  port_id     = openstack_lb_loadbalancer_v2.this.vip_port_id
}

resource "openstack_lb_listener_v2" "this" {
  for_each        = var.listeners
  name            = each.key
  protocol        = each.value.protocol
  protocol_port   = each.value.protocol_port
  loadbalancer_id = openstack_lb_loadbalancer_v2.this.id
}

resource "openstack_lb_pool_v2" "this" {
  for_each    = var.pools
  name        = each.key
  protocol    = each.value.protocol
  lb_method   = each.value.lb_method
  listener_id = openstack_lb_listener_v2.this[each.value.listener].id
}

resource "openstack_lb_monitor_v2" "ebt_lb0001_monitor_1" {
  for_each    = var.pools
  pool_id     = openstack_lb_pool_v2.this[each.key].id
  name        = each.key
  type        = each.value.monitor.type
  delay       = each.value.monitor.delay
  timeout     = each.value.monitor.timeout
  max_retries = each.value.monitor.max_retries
}

resource "openstack_lb_member_v2" "this" {
  for_each = { for m in flatten([
    for k, v in var.pools : [
      for a in v.members : {
        name     = "${k}-${a}"
        pool     = k
        listener = v.listener
        address  = a
      }
    ]
  ]) : m.name => m }
  name          = each.key
  pool_id       = openstack_lb_pool_v2.this[each.value.pool].id
  protocol_port = openstack_lb_listener_v2.this[each.value.listener].protocol_port
  address       = each.value.address
}

