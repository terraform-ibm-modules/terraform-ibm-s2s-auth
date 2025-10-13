module "service_auth_cbr_rules" {
  source                     = "../.."
  prefix                     = var.prefix
  service_map                = var.service_map
  cbr_target_service_details = var.cbr_target_service_details
  zone_vpc_crn_list          = var.zone_vpc_crn_list
  zone_service_ref_list      = var.zone_service_ref_list
  enable_cbr                 = var.enable_cbr
}
