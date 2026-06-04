##############################################################################
# Complete example
##############################################################################

# Get current account ID
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

# Create COS instance
module "cos_instance" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "10.16.0"
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  resource_group_id      = module.resource_group.resource_group_id
  bucket_name            = "${var.prefix}-cos-bucket"
}

# Create Key Protect instance
module "key_protect_instance" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "2.11.2"
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

# Generate a service_map with original 3 test policies + additional scenario tests
# All policies are unique to avoid conflicts
locals {
  service_map = {
    # Original test policies from main branch (backward compatibility)
    "test-policy-1" = {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "This is a test policy locked to 2 instance IDs"
      source_resource_instance_id = module.cos_instance.cos_instance_guid
      target_resource_instance_id = module.key_protect_instance.key_protect_guid
      source_resource_group_id    = null
      target_resource_group_id    = null
    }
    "test-policy-2" = {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "This is a test policy locked to target instance ID"
      source_resource_instance_id = null
      target_resource_instance_id = module.key_protect_instance.key_protect_guid
      source_resource_group_id    = module.resource_group.resource_group_id
      target_resource_group_id    = null
    }
    "test-policy-3" = {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "This is a test policy locked to source instance ID"
      source_resource_instance_id = module.cos_instance.cos_instance_guid
      target_resource_instance_id = null
      source_resource_group_id    = null
      target_resource_group_id    = module.resource_group.resource_group_id
    }

    # Additional scenario tests for dynamic attributes functionality
    # Scenario 1: Both subject_attributes AND resource_attributes
    "scenario-both-attrs" = {
      roles       = ["Reader"]
      description = "Scenario: Both dynamic attributes - COS account to KMS keys"

      subject_attributes = [
        {
          name  = "serviceName"
          value = "cloud-object-storage"
        },
        {
          name  = "accountId"
          value = data.ibm_iam_account_settings.iam_account_settings.account_id
        }
      ]

      resource_attributes = [
        {
          name  = "serviceName"
          value = "kms"
        },
        {
          name  = "accountId"
          value = data.ibm_iam_account_settings.iam_account_settings.account_id
        },
        {
          name     = "resourceType"
          value    = "key"
          operator = "stringEquals"
        }
      ]
    }

    # Scenario 2: subject_attributes with static target
    "scenario-subject-attrs" = {
      roles       = ["Reader"]
      description = "Scenario: Dynamic subject with static target - COS account to KMS RG"

      subject_attributes = [
        {
          name  = "serviceName"
          value = "cloud-object-storage"
        },
        {
          name  = "accountId"
          value = data.ibm_iam_account_settings.iam_account_settings.account_id
        }
      ]

      target_service_name      = "kms"
      target_resource_group_id = module.resource_group.resource_group_id
    }

    # Scenario 3: resource_attributes with static source
    "scenario-resource-attrs" = {
      roles       = ["Reader"]
      description = "Scenario: Static source with dynamic resource - COS instance to KMS account"

      source_service_name         = "cloud-object-storage"
      source_resource_instance_id = module.cos_instance.cos_instance_guid

      resource_attributes = [
        {
          name  = "serviceName"
          value = "kms"
        },
        {
          name  = "accountId"
          value = data.ibm_iam_account_settings.iam_account_settings.account_id
        }
      ]
    }
  }

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
  enable_cbr                 = true
  cbr_target_service_details = local.cbr_target_service_details
  prefix                     = var.prefix
  zone_vpc_crn_list          = [ibm_is_vpc.vpc_instance.crn]
  zone_service_ref_list      = { "cloud-object-storage" = {} }
}
