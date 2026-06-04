########################################################################################################################
# Outputs
########################################################################################################################

output "cbr_rules" {
  description = "CBR Rules created"
  value       = module.cbr_rules
}

output "auth_policies" {
  description = "Authorizations created"
  value = merge(
    ibm_iam_authorization_policy.auth_policies_static_attrs,
    ibm_iam_authorization_policy.auth_policies_dynamic_subject_attrs,
    ibm_iam_authorization_policy.auth_policies_dynamic_resource_attrs,
    ibm_iam_authorization_policy.auth_policies_dynamic_attrs
  )
}

##############################################################################
