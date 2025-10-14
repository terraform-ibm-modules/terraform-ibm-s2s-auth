module "service_auth_cbr_rules" {
  source      = "../.."
  prefix      = var.prefix
  service_map = var.service_map
  enable_cbr  = false
}
