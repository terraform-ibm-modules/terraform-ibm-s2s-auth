########################################################################################################################
# Input Variables
########################################################################################################################

variable "prefix" {
  type        = string
  description = "Prefix to append when creating CBR zones and CBR rules"
  default     = null
}

variable "service_map" {
  description = "Map of source service and the corresponding target service details"
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
    error_message = "Provide a valid service for auth policy creation"
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
}

variable "cbr_target_service_details" {
  type = list(object({
    target_service_name = string
    target_rg           = optional(string)
    enforcement_mode    = string
    tags                = optional(list(string))
  }))
  description = "Details of the target service for which the rule has to be created"
  default     = []
}

variable "zone_service_ref_list" {
  type        = list(string)
  default     = []
  description = "Service reference for the zone creation"
}

variable "zone_vpc_crn_list" {
  type        = list(string)
  default     = []
  description = "VPC CRN for the zones"
}
