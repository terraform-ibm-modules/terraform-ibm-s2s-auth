variable "ibmcloud_api_key" {
  type        = string
  description = "An IBM Cloud API key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The region to provision all resources created by this example."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "The prefix for the resources created by this example."
  default     = "complete-s2s"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision the resources in. If not set, a resource group is created with the prefix variable."
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to add to new resources"
  default     = []
}

variable "enforcement_mode" {
  type        = string
  description = "The CBR rule enforcement mode."
  default     = "report"
}
