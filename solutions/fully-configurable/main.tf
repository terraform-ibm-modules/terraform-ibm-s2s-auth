module "service_auth_policy" {
  source      = "../.."
  prefix      = var.prefix
  service_map = var.service_map
  enable_cbr  = false
}
