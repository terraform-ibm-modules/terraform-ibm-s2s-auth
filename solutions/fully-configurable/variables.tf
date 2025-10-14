##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The region to provision all resources created by this example."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-cbr. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

##############################################################################
# S2S Authorisation Variables
##############################################################################

variable "service_map" {
  description = "Map of unique service pairs and their authorization config."
  type = map(object({
    source_service_name         = string
    target_service_name         = string
    roles                       = list(string)
    description                 = optional(string, null)
    source_service_account_id   = optional(string, null)
    source_resource_instance_id = optional(string, null)
    target_resource_instance_id = optional(string, null)
    source_resource_group_id    = optional(string, null)
    target_resource_group_id    = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      ((svc.source_resource_instance_id != null && svc.source_resource_group_id == null) ||
      (svc.source_resource_instance_id == null && svc.source_resource_group_id != null))
    ])
    error_message = "source_resource_instance_id and source_resource_group_id are mutually exclusive, please only provide one of the values"
  }

  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      ((svc.target_resource_instance_id != null && svc.target_resource_group_id == null) ||
      (svc.target_resource_instance_id == null && svc.target_resource_group_id != null))
    ])
    error_message = "target_resource_instance_id and target_resource_group_id are mutually exclusive, please only provide one of the values"
  }

  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      svc.target_resource_instance_id != null ? can(regex("^[a-zA-Z0-9-]*$", svc.target_resource_instance_id)) : true
    ])
    error_message = "target_resource_instance_id must be the GUID of the instance and match the following pattern: \"^[a-zA-Z0-9-]*$\""
  }

  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      svc.source_resource_instance_id != null ? can(regex("^[a-zA-Z0-9-]*$", svc.source_resource_instance_id)) : true
    ])
    error_message = "source_resource_instance_id must be the GUID of the instance and match the following pattern: \"^[a-zA-Z0-9-]*$\""
  }
}
