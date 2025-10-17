## v1 to v2 Migration Notes

Significant changes were made to the input format for `service_map` between v1.x.x and v2.x.x, the array of objects is now a map of objects, which also changes how Terraform tracks the state of the policies internally (from integer index to string). Due to this change, Terraform will want to destroy the old policies and CBR rules and create them again using the new key values, which can cause a disruption.

If you wish to avoid any policy destruction during the upgrade you can use the `terraform state mv` command to move the state of the old names to the new names you supply in the map input, as well as add the new integer assigned to the CBR module. This should allow you to upgrade with zero changes.

For example, using the [Basic example](./examples/basic) as our solution, you would perform the following commands between v1 and v2 that will result in no changes made for the upgrade:
```
terraform state mv 'module.service_auth_cbr_rules.ibm_iam_authorization_policy.auth_policies[0]' 'module.service_auth_cbr_rules.ibm_iam_authorization_policy.auth_policies["test-1"]'

terraform state mv 'module.service_auth_cbr_rules.module.cbr_rules' 'module.service_auth_cbr_rules.module.cbr_rules[0]'
```
