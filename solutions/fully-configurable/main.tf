locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

module "service_auth_policy" {
  source      = "../.."
  prefix      = local.prefix
  service_map = var.service_map
  enable_cbr  = false
}
