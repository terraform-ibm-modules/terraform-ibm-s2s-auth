##############################################################################
# Service To Service Authorization Policies
##############################################################################

# Policies using ONLY legacy approach (no dynamic blocks at all)
resource "ibm_iam_authorization_policy" "auth_policies_legacy" {
  for_each = {
    for k, v in var.service_map : k => v
    if(
      (!contains(keys(v), "subject_attributes") || v.subject_attributes == null) &&
      (!contains(keys(v), "resource_attributes") || v.resource_attributes == null)
    )
  }

  source_service_name         = try(each.value.source_service_name, null)
  source_service_account      = try(each.value.source_service_account_id, null)
  source_resource_instance_id = try(each.value.source_resource_instance_id, null)
  source_resource_group_id    = try(each.value.source_resource_group_id, null)
  source_resource_type        = try(each.value.source_resource_type, null)

  target_service_name         = try(each.value.target_service_name, null)
  target_resource_instance_id = try(each.value.target_resource_instance_id, null)
  target_resource_group_id    = try(each.value.target_resource_group_id, null)
  target_resource_type        = try(each.value.target_resource_type, null)

  roles       = each.value.roles
  description = try(each.value.description, null)

  lifecycle {
    create_before_destroy = true
  }
}

# Policies using subject_attributes (with legacy target fields)
resource "ibm_iam_authorization_policy" "auth_policies_subject_attrs" {
  for_each = {
    for k, v in var.service_map : k => v
    if(
      contains(keys(v), "subject_attributes") && v.subject_attributes != null &&
      (!contains(keys(v), "resource_attributes") || v.resource_attributes == null)
    )
  }

  target_service_name         = try(each.value.target_service_name, null)
  target_resource_instance_id = try(each.value.target_resource_instance_id, null)
  target_resource_group_id    = try(each.value.target_resource_group_id, null)
  target_resource_type        = try(each.value.target_resource_type, null)

  roles       = each.value.roles
  description = try(each.value.description, null)

  dynamic "subject_attributes" {
    for_each = coalesce(each.value.subject_attributes, [])
    content {
      name     = subject_attributes.value.name
      value    = subject_attributes.value.value
      operator = try(subject_attributes.value.operator, "stringEquals")
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Policies using resource_attributes (with legacy source fields)
resource "ibm_iam_authorization_policy" "auth_policies_resource_attrs" {
  for_each = {
    for k, v in var.service_map : k => v
    if(
      (!contains(keys(v), "subject_attributes") || v.subject_attributes == null) &&
      contains(keys(v), "resource_attributes") && v.resource_attributes != null
    )
  }

  source_service_name         = try(each.value.source_service_name, null)
  source_service_account      = try(each.value.source_service_account_id, null)
  source_resource_instance_id = try(each.value.source_resource_instance_id, null)
  source_resource_group_id    = try(each.value.source_resource_group_id, null)
  source_resource_type        = try(each.value.source_resource_type, null)

  roles       = each.value.roles
  description = try(each.value.description, null)

  dynamic "resource_attributes" {
    for_each = coalesce(each.value.resource_attributes, [])
    content {
      name     = resource_attributes.value.name
      value    = resource_attributes.value.value
      operator = try(resource_attributes.value.operator, "stringEquals")
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Policies using BOTH subject_attributes AND resource_attributes
resource "ibm_iam_authorization_policy" "auth_policies_both_attrs" {
  for_each = {
    for k, v in var.service_map : k => v
    if(
      contains(keys(v), "subject_attributes") && v.subject_attributes != null &&
      contains(keys(v), "resource_attributes") && v.resource_attributes != null
    )
  }

  roles       = each.value.roles
  description = try(each.value.description, null)

  dynamic "subject_attributes" {
    for_each = coalesce(each.value.subject_attributes, [])
    content {
      name     = subject_attributes.value.name
      value    = subject_attributes.value.value
      operator = try(subject_attributes.value.operator, "stringEquals")
    }
  }

  dynamic "resource_attributes" {
    for_each = coalesce(each.value.resource_attributes, [])
    content {
      name     = resource_attributes.value.name
      value    = resource_attributes.value.value
      operator = try(resource_attributes.value.operator, "stringEquals")
    }
  }

  lifecycle {
    create_before_destroy = true
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
