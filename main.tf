##############################################################################
# Service To Service Authorization Policies
##############################################################################

locals {
  service_map_by_key = {
    for idx, svc in var.service_map :
    "${svc.source_service_name}-${svc.target_service_name}-${idx}" => svc
  }
}

resource "ibm_iam_authorization_policy" "auth_policies" {
  for_each                    = local.service_map_by_key
  source_service_name         = each.value.source_service_name
  target_service_name         = each.value.target_service_name
  roles                       = each.value.roles
  description                 = each.value.description
  source_service_account      = each.value.source_service_account_id
  source_resource_instance_id = each.value.source_resource_instance_id
  target_resource_instance_id = each.value.target_resource_instance_id
  source_resource_group_id    = each.value.source_resource_group_id
  target_resource_group_id    = each.value.target_resource_group_id
}

module "cbr_rules" {
  count                  = var.enable_cbr == false ? 0 : 1
  source                 = "terraform-ibm-modules/cbr/ibm//modules/cbr-service-profile"
  version                = "1.33.2"
  target_service_details = var.cbr_target_service_details
  zone_vpc_crn_list      = var.zone_vpc_crn_list
  zone_service_ref_list  = var.zone_service_ref_list
  prefix                 = var.prefix
}
