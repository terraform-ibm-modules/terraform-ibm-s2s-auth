module "service_auth_policy" {
  source      = "../.."
  prefix      = null
  service_map = var.service_map
  enable_cbr  = false
}
