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

# generate a service_map
locals {
  # Legacy policies (no dynamic attributes)
  legacy_policies = {
    "test-policy-1" = {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "Legacy: COS instance to KMS instance"
      source_resource_instance_id = module.cos_instance.cos_instance_guid
      target_resource_instance_id = module.key_protect_instance.key_protect_guid
    }
    "test-policy-2" = {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "Legacy: COS resource group to KMS instance"
      source_resource_group_id    = module.resource_group.resource_group_id
      target_resource_instance_id = module.key_protect_instance.key_protect_guid
    }
    "test-policy-3" = {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "kms"
      roles                       = ["Reader"]
      description                 = "Legacy: COS instance to KMS resource group"
      source_resource_instance_id = module.cos_instance.cos_instance_guid
      target_resource_group_id    = module.resource_group.resource_group_id
    }
  }

  # Policies with BOTH subject_attributes AND resource_attributes
  both_attrs_policies = {
    "test-policy-4" = {
      roles       = ["Reader"]
      description = "Dynamic: COS account to KMS keys in account"

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
  }

  # Policies with subject_attributes and legacy target fields
  subject_attrs_policies = {
    "test-policy-5" = {
      roles       = ["Reader"]
      description = "Dynamic: COS in resource group to specific KMS instance"

      subject_attributes = [
        {
          name  = "serviceName"
          value = "cloud-object-storage"
        },
        {
          name  = "accountId"
          value = data.ibm_iam_account_settings.iam_account_settings.account_id
        },
        {
          name  = "resourceGroupId"
          value = module.resource_group.resource_group_id
        }
      ]

      target_service_name         = "kms"
      target_resource_instance_id = module.key_protect_instance.key_protect_guid
    }
  }

  # Policies with resource_attributes and legacy source fields
  resource_attrs_policies = {
    "test-policy-6" = {
      roles       = ["Reader"]
      description = "Dynamic: Specific COS instance to KMS in resource group"

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
        },
        {
          name  = "resourceGroupId"
          value = module.resource_group.resource_group_id
        }
      ]
    }
  }

  # Merge all policies for the module
  service_map = merge(
    local.legacy_policies,
    local.both_attrs_policies,
    local.subject_attrs_policies,
    local.resource_attrs_policies
  )

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
