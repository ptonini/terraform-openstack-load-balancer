variable "name" {}

variable "vip_subnet_id" {}

variable "public_network_name" {}

variable "listeners" {
  type = map(object({
    protocol      = optional(string, "TCP")
    protocol_port = number
  }))
  default = {}
}

variable "pools" {
  type = map(object({
    protocol  = optional(string, "TCP")
    lb_method = optional(string, "ROUND_ROBIN")
    listener  = string
    members   = optional(set(string), [])
    monitor = optional(object({
      type        = optional(string, "TCP")
      delay       = optional(number, 30)
      timeout     = optional(number, 5)
      max_retries = optional(number, 3)
    }), {})
  }))

}