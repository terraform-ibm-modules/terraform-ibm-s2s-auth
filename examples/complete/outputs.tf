##############################################################################
# Outputs
##############################################################################

output "cos_instance" {
  description = "COS instance"
  value       = module.resource_group.resource_group_id
}

output "key_protect_instance_guid" {
  description = "Key protect instance"
  value       = module.key_protect_instance.key_protect_guid
}

output "service_auth_cbr_rules" {
  description = "Details of rules created"
  value       = module.service_auth_cbr_rules
}
