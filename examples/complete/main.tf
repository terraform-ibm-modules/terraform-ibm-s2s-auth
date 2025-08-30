##############################################################################
# Complete example
##############################################################################

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.3.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

# Create COS instance
module "cos_instance" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "10.2.8"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  retention_enabled      = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-cos-bucket"
}

# Create Key Protect instance
module "key_protect_instance" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "2.10.10"
  key_protect_name  = "${var.prefix}-key-protect"
  resource_group_id = module.resource_group.resource_group_id
  plan              = "tiered-pricing"
  region            = var.region
  tags              = var.resource_tags
}

resource "ibm_is_vpc" "vpc_instance" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

# generate a service_map
locals {
  service_map = [
    {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "This is a test policy locked to 2 instance IDs"
      source_resource_instance_id = module.cos_instance.cos_instance_guid
      target_resource_instance_id = module.key_protect_instance.key_protect_guid
      source_resource_group_id    = null
      target_resource_group_id    = null
    },
    {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "This is a test policy locked to target instance ID"
      source_resource_instance_id = null
      target_resource_instance_id = module.key_protect_instance.key_protect_guid
      source_resource_group_id    = module.resource_group.resource_group_id
      target_resource_group_id    = null
    },
    {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "This is a test policy locked to source instance ID"
      source_resource_instance_id = module.cos_instance.cos_instance_guid
      target_resource_instance_id = null
      source_resource_group_id    = null
      target_resource_group_id    = module.resource_group.resource_group_id
    }
  ]
  cbr_target_service_details = [
    {
      target_service_name = "kms"
      target_rg           = module.resource_group.resource_group_id
      enforcement_mode    = var.enforcement_mode
    }
  ]
}

module "service_auth_cbr_rules" {
  source                     = "../.."
  service_map                = local.service_map
  cbr_target_service_details = local.cbr_target_service_details
  prefix                     = var.prefix
  zone_vpc_crn_list          = [ibm_is_vpc.vpc_instance.crn]
  zone_service_ref_list      = { "cloud-object-storage" = {} }
}
