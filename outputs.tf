########################################################################################################################
# Outputs
########################################################################################################################

output "cbr_rules" {
  description = "CBR Rules created"
  value       = module.cbr_rules
}

output "auth_policies" {
  description = "Authorizations created"
  value       = ibm_iam_authorization_policy.auth_policies
}

##############################################################################
