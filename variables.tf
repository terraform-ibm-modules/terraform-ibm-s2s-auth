########################################################################################################################
# Input Variables
########################################################################################################################

variable "prefix" {
  type        = string
  description = "Prefix for new CBR zones and rules."
  default     = null
}

variable "service_map" {
  description = "Map of unique service pairs and their authorization config."
  type = map(object({
    # Legacy individual arguments (backward compatible)
    source_service_name = optional(string, null)
    target_service_name = optional(string, null)
    roles               = list(string)
    description         = optional(string, null)

    source_service_account_id = optional(string, null)

    source_resource_instance_id = optional(string, null)
    target_resource_instance_id = optional(string, null)

    source_resource_group_id = optional(string, null)
    target_resource_group_id = optional(string, null)

    source_resource_type = optional(string, null)
    target_resource_type = optional(string, null)

    # New dynamic attributes approach
    subject_attributes = optional(list(object({
      name     = string
      value    = string
      operator = optional(string, "stringEquals")
    })), null)

    resource_attributes = optional(list(object({
      name     = string
      value    = string
      operator = optional(string, "stringEquals")
    })), null)
  }))
  default = {}

  # Validation: Ensure either legacy OR new approach is used for source/subject
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      (svc.subject_attributes == null) ||
      (svc.source_service_name == null &&
        svc.source_service_account_id == null &&
        svc.source_resource_instance_id == null &&
        svc.source_resource_group_id == null &&
      svc.source_resource_type == null)
    ])
    error_message = "Cannot use both subject_attributes and individual source_* arguments. Choose one approach."
  }

  # Validation: Ensure either legacy OR new approach is used for target/resource
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      (svc.resource_attributes == null) ||
      (svc.target_service_name == null &&
        svc.target_resource_instance_id == null &&
        svc.target_resource_group_id == null &&
      svc.target_resource_type == null)
    ])
    error_message = "Cannot use both resource_attributes and individual target_* arguments. Choose one approach."
  }

  # Validation: At least one source identifier must be provided
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      (svc.subject_attributes != null ? length(svc.subject_attributes) > 0 : false) ||
      (svc.source_service_name != null ||
        svc.source_resource_group_id != null ||
      svc.source_service_account_id != null)
    ])
    error_message = "At least one source identifier must be provided: either subject_attributes or one of source_service_name, source_resource_group_id, source_service_account_id."
  }

  # Validation: At least one target identifier must be provided
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      (svc.resource_attributes != null ? length(svc.resource_attributes) > 0 : false) ||
      (svc.target_service_name != null ||
      svc.target_resource_type != null)
    ])
    error_message = "At least one target identifier must be provided: either resource_attributes or target_service_name/target_resource_type."
  }

  # Legacy validation: source_resource_instance_id and source_resource_group_id are mutually exclusive
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      svc.subject_attributes != null ? true :
      (svc.source_resource_instance_id == null || svc.source_resource_group_id == null)
    ])
    error_message = "source_resource_instance_id and source_resource_group_id are mutually exclusive, please only provide one of the values"
  }

  # Legacy validation: target_resource_instance_id and target_resource_group_id are mutually exclusive
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      svc.resource_attributes != null ? true :
      (svc.target_resource_instance_id == null || svc.target_resource_group_id == null)
    ])
    error_message = "target_resource_instance_id and target_resource_group_id are mutually exclusive, please only provide one of the values"
  }

  # Legacy validation: target_resource_instance_id format
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      svc.target_resource_instance_id != null ? can(regex("^[a-zA-Z0-9-]*$", svc.target_resource_instance_id)) : true
    ])
    error_message = "target_resource_instance_id must be the GUID of the instance and match the following pattern: \"^[a-zA-Z0-9-]*$\""
  }

  # Legacy validation: source_resource_instance_id format
  validation {
    condition = alltrue([
      for svc in values(var.service_map) :
      svc.source_resource_instance_id != null ? can(regex("^[a-zA-Z0-9-]*$", svc.source_resource_instance_id)) : true
    ])
    error_message = "source_resource_instance_id must be the GUID of the instance and match the following pattern: \"^[a-zA-Z0-9-]*$\""
  }
}


variable "cbr_target_service_details" {
  type = list(object({
    target_service_name = string
    target_rg           = optional(string)
    enforcement_mode    = string
    tags                = optional(list(string))
  }))
  description = "Details of the target service for which the rule has to be created."
  default     = []
}

variable "zone_service_ref_list" {
  type = map(object({
    service_ref_location = optional(list(string), [])
  }))
  default     = {}
  description = "Service reference for the zone creation."
}

variable "zone_vpc_crn_list" {
  type        = list(string)
  default     = []
  description = "CRN of the VPC for the zones."
}

variable "enable_cbr" {
  type        = bool
  default     = true
  description = "Set to true to enable creation of Context Based restrictions (CBR) for services defined in var.cbr_target_service_details. When true, var.zone_vpc_crn_list and var.zone_service_ref_list must be provided to create and attach the required CBR zones. When false, no CBR zones or rules are created."
  nullable    = false
}
