########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# S2S Auth Module
########################################################################################################################

locals {
  # generate a service_map
  service_map = [{
    source_service_name         = "databases-for-postgresql"
    target_service_name         = "kms"
    roles                       = ["Reader"]
    description                 = "This is a test policy"
    source_resource_instance_id = null
    target_resource_instance_id = null
    source_resource_group_id    = module.resource_group.resource_group_id
    target_resource_group_id    = module.resource_group.resource_group_id
    }
  ]
  cbr_target_service_details = [{
    target_service_name = "kms"
    target_rg           = module.resource_group.resource_group_id
    enforcement_mode    = "report"
  }]
}

module "service_auth_cbr_rules" {
  source                     = "../.."
  service_map                = local.service_map
  cbr_target_service_details = local.cbr_target_service_details
  prefix                     = var.prefix
  zone_service_ref_list      = { "databases-for-postgresql" = {} }
}
