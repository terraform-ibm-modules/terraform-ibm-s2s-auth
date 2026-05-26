##############################################################################
# Service To Service Authorization Policies
##############################################################################

resource "ibm_iam_authorization_policy" "auth_policies" {
  for_each = var.service_map

  # Use individual arguments only when nested blocks are NOT provided
  source_service_name         = try(each.value.subject_attributes, null) == null ? each.value.source_service_name : null
  source_service_account      = try(each.value.subject_attributes, null) == null ? each.value.source_service_account_id : null
  source_resource_instance_id = try(each.value.subject_attributes, null) == null ? each.value.source_resource_instance_id : null
  source_resource_group_id    = try(each.value.subject_attributes, null) == null ? each.value.source_resource_group_id : null
  source_resource_type        = try(each.value.subject_attributes, null) == null ? each.value.source_resource_type : null

  target_service_name         = try(each.value.resource_attributes, null) == null ? each.value.target_service_name : null
  target_resource_instance_id = try(each.value.resource_attributes, null) == null ? each.value.target_resource_instance_id : null
  target_resource_group_id    = try(each.value.resource_attributes, null) == null ? each.value.target_resource_group_id : null
  target_resource_type        = try(each.value.resource_attributes, null) == null ? each.value.target_resource_type : null

  roles       = each.value.roles
  description = each.value.description

  # Dynamic subject_attributes block (only created when provided)
  dynamic "subject_attributes" {
    for_each = try(each.value.subject_attributes, [])
    content {
      name     = subject_attributes.value.name
      value    = subject_attributes.value.value
      operator = try(subject_attributes.value.operator, "stringEquals")
    }
  }

  # Dynamic resource_attributes block (only created when provided)
  dynamic "resource_attributes" {
    for_each = try(each.value.resource_attributes, [])
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
