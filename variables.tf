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
  description = "Flag to enable CBR"
  nullable    = false
}
