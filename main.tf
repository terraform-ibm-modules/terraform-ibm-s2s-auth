##############################################################################
# Service To Service Authorization Policies
##############################################################################

resource "ibm_iam_authorization_policy" "auth_policies" {
  for_each = var.service_map

  source_service_name = each.value.source_service_name
  target_service_name = each.value.target_service_name

  roles       = each.value.roles
  description = each.value.description

  source_service_account = each.value.source_service_account_id

  source_resource_instance_id = each.value.source_resource_instance_id
  target_resource_instance_id = each.value.target_resource_instance_id

  source_resource_group_id = each.value.source_resource_group_id
  target_resource_group_id = each.value.target_resource_group_id

  source_resource_type = each.value.source_resource_type
  target_resource_type = each.value.target_resource_type

  dynamic "subject_attributes" {
    for_each = length(each.value.subject_attributes) > 0 ? { for idx, subject in each.value.subject_attributes : idx => subject } : {}
    content {
      name     = subject_attributes.value.name
      value    = subject_attributes.value.value
      operator = try(subject_attributes.value.operator, "stringEquals")
    }
  }

  dynamic "resource_attributes" {
    for_each = length(each.value.resource_attributes) > 0 ? { for idx, subject in each.value.resource_attributes : idx => subject } : {}
    content {
      name     = resource_attributes.value.name
      value    = resource_attributes.value.value
      operator = try(resource_attributes.value.operator, "stringEquals")
    }
  }
}

module "cbr_rules" {
  count                  = var.enable_cbr == false ? 0 : 1
  source                 = "terraform-ibm-modules/cbr/ibm//modules/cbr-service-profile"
  version                = "1.36.7"
  target_service_details = var.cbr_target_service_details
  zone_vpc_crn_list      = var.zone_vpc_crn_list
  zone_service_ref_list  = var.zone_service_ref_list
  prefix                 = var.prefix
}
