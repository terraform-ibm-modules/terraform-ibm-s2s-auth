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
  description = "Map of source service and the corresponding target service details."
  type = list(object({
    source_service_name         = string
    target_service_name         = string
    roles                       = list(string)
    description                 = optional(string, null)
    source_resource_instance_id = optional(string, null)
    target_resource_instance_id = optional(string, null)
    source_resource_group_id    = optional(string, null)
    target_resource_group_id    = optional(string, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for service in var.service_map :
      contains(["iam-groups", "iam-access-management", "iam-identity",
        "user-management", "cloud-object-storage", "codeengine",
        "container-registry", "databases-for-cassandra",
        "databases-for-enterprisedb", "databases-for-elasticsearch",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql", "databases-for-redis",
        "directlink", "dns-svcs", "messagehub", "kms", "containers-kubernetes",
        "messages-for-rabbitmq", "secrets-manager", "transit", "is",
        "schematics", "apprapp", "event-notifications", "compliance", "kms", "atracker", "sql-query", "hs-crypto", "server-protect"],
      service.source_service_name) &&
      contains(["iam-groups", "iam-access-management", "iam-identity",
        "user-management", "cloud-object-storage", "codeengine",
        "container-registry", "databases-for-cassandra",
        "databases-for-enterprisedb", "databases-for-elasticsearch",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql", "databases-for-redis",
        "directlink", "dns-svcs", "messagehub", "kms", "containers-kubernetes",
        "messages-for-rabbitmq", "secrets-manager", "transit", "is",
        "schematics", "apprapp", "event-notifications", "compliance",
        "kms", "internet-svcs", "atracker", "sql-query", "hs-crypto", "server-protect"],
      service.target_service_name)
    ])
    error_message = "Provide a valid service for authorization policy creation."
  }

  validation {
    condition = alltrue([
      for service in var.service_map :
      ((service.source_resource_instance_id != null && service.source_resource_group_id == null) ||
      (service.source_resource_instance_id == null && service.source_resource_group_id != null))
    ])
    error_message = "source_resource_instance_id and source_resource_group_id are mutually exclusive, please only provide one of the values"
  }

  validation {
    condition = alltrue([
      for service in var.service_map :
      ((service.target_resource_instance_id != null && service.target_resource_group_id == null) ||
      (service.target_resource_instance_id == null && service.target_resource_group_id != null))
    ])
    error_message = "target_resource_instance_id and target_resource_group_id are mutually exlusive, please only provide one of the values"
  }

  validation {
    condition = alltrue([
      for service in var.service_map :
      service.target_resource_instance_id != null ? can(regex("^[a-zA-Z0-9-]*$", service.target_resource_instance_id)) : true
    ])
    error_message = "target_resource_instance_id must be the GUID of the instance and match the following pattern: \"^[a-zA-Z0-9-]*$\""
  }

  validation {
    condition = alltrue([
      for service in var.service_map :
      service.source_resource_instance_id != null ? can(regex("^[a-zA-Z0-9-]*$", service.source_resource_instance_id)) : true
    ])
    error_message = "source_resource_instance_id must be the GUID of the instance and match the following pattern: \"^[a-zA-Z0-9-]*$\""
  }
}

##############################################################################
# CBR Variables
##############################################################################

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
