##############################################################################
# Service To Service Authorization Policies
##############################################################################

resource "ibm_iam_authorization_policy" "auth_policies" {
  for_each = var.service_map

  # Use individual arguments only when nested blocks are NOT provided
  source_service_name         = can(each.value.subject_attributes) && length(coalesce(each.value.subject_attributes, [])) > 0 ? null : each.value.source_service_name
  source_service_account      = can(each.value.subject_attributes) && length(coalesce(each.value.subject_attributes, [])) > 0 ? null : each.value.source_service_account_id
  source_resource_instance_id = can(each.value.subject_attributes) && length(coalesce(each.value.subject_attributes, [])) > 0 ? null : each.value.source_resource_instance_id
  source_resource_group_id    = can(each.value.subject_attributes) && length(coalesce(each.value.subject_attributes, [])) > 0 ? null : each.value.source_resource_group_id
  source_resource_type        = can(each.value.subject_attributes) && length(coalesce(each.value.subject_attributes, [])) > 0 ? null : each.value.source_resource_type

  target_service_name         = can(each.value.resource_attributes) && length(coalesce(each.value.resource_attributes, [])) > 0 ? null : each.value.target_service_name
  target_resource_instance_id = can(each.value.resource_attributes) && length(coalesce(each.value.resource_attributes, [])) > 0 ? null : each.value.target_resource_instance_id
  target_resource_group_id    = can(each.value.resource_attributes) && length(coalesce(each.value.resource_attributes, [])) > 0 ? null : each.value.target_resource_group_id
  target_resource_type        = can(each.value.resource_attributes) && length(coalesce(each.value.resource_attributes, [])) > 0 ? null : each.value.target_resource_type

  roles       = each.value.roles
  description = each.value.description

  # Dynamic subject_attributes block (only created when provided)
  dynamic "subject_attributes" {
    for_each = coalesce(each.value.subject_attributes, [])
    content {
      name     = subject_attributes.value.name
      value    = subject_attributes.value.value
      operator = try(subject_attributes.value.operator, "stringEquals")
    }
  }

  # Dynamic resource_attributes block (only created when provided)
  dynamic "resource_attributes" {
    for_each = coalesce(each.value.resource_attributes, [])
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
  version                = "1.36.2"
  target_service_details = var.cbr_target_service_details
  zone_vpc_crn_list      = var.zone_vpc_crn_list
  zone_service_ref_list  = var.zone_service_ref_list
  prefix                 = var.prefix
}
