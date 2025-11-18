##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

##############################################################################
# S2S Authorisation Variables
##############################################################################

variable "service_map" {
  description = "Map of unique service pairs and their authorization config. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-s2s-auth/tree/main/solutions/fully-configurable/DA-complex-input-variables.md#service-map)"
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
