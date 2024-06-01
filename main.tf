##############################################################################
# Service To Service Authorization Policies
##############################################################################

resource "ibm_iam_authorization_policy" "auth_policies" {
  count                       = length(var.service_map)
  source_service_name         = var.service_map[count.index].source_service_name
  target_service_name         = var.service_map[count.index].target_service_name
  roles                       = var.service_map[count.index].roles
  description                 = var.service_map[count.index].description
  source_resource_instance_id = var.service_map[count.index].source_resource_instance_id
  target_resource_instance_id = var.service_map[count.index].target_resource_instance_id
  source_resource_group_id    = var.service_map[count.index].source_resource_group_id
  target_resource_group_id    = var.service_map[count.index].target_resource_group_id
}

module "cbr_rules" {
  source                 = "terraform-ibm-modules/cbr/ibm//modules/cbr-service-profile"
  version                = "1.22.1"
  target_service_details = var.cbr_target_service_details
  zone_vpc_crn_list      = var.zone_vpc_crn_list
  zone_service_ref_list  = var.zone_service_ref_list
  prefix                 = var.prefix
}
