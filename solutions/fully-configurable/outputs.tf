##############################################################################
# Outputs
##############################################################################

output "service_auth_policies" {
  description = "Details of rules created"
  value       = module.service_auth_policy.auth_policies
}
