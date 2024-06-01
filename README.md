<!-- Update the title -->
# Terraform IBM Service-to-service authorization module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://github.ibm.com/GoldenEye/documentation/blob/master/status.md
  2. Update the "latest release" badge to point to the correct module's repo. Replace "module-template" in two places.
-->
[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-s2s-auth?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-s2s-auth/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

This module generates authorization policies and context-based restriction (CBR) rules to enable access and restrictions between a source service and a target service.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-s2s-auth](#terraform-ibm-s2s-auth)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Complete example](./examples/complete)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-s2s-auth

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
module "service_auth_cbr_rules" {
  source                = "terraform-ibm-modules/s2s-auth/ibm"
  version               = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  service_map           = [
    {
        "description"= "This is a test auth policy",
        "enforcement_mode"= "report",
        "roles"= [
            "Reader"
        ],
        "source_resource_instance_id"= "<source_resource_instance_guid>",
        "source_service_name"= "cloud-object-storage",
        "target_resource_instance_id"= "<target_resource_instance_guid>",
        "target_service_name"= "kms"
    },
    {
        "description"= "This is a test auth policy",
        "enforcement_mode"= "report",
        "roles"= [
            "Reader"
        ],
        "source_rg"= "<source_rg>",
        "source_service_name"= "containers-kubernetes",
        "target_rg"= "<target_rg>",
        "target_service_name"= "kms"
    }
  ]
}
```

### Required IAM access policies

You need the following permissions to run this module.

* You must have access to the target service to create an authorization between services. You can grant only the level of access that you have as a user of the target service. For example, if you have viewer access on the target service, you can assign only the viewer role for the authorization.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rules"></a> [cbr\_rules](#module\_cbr\_rules) | terraform-ibm-modules/cbr/ibm//modules/cbr-service-profile | 1.22.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.auth_policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_target_service_details"></a> [cbr\_target\_service\_details](#input\_cbr\_target\_service\_details) | Details of the target service for which the rule has to be created. | <pre>list(object({<br>    target_service_name = string<br>    target_rg           = optional(string)<br>    enforcement_mode    = string<br>    tags                = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for new CBR zones and rules. | `string` | `null` | no |
| <a name="input_service_map"></a> [service\_map](#input\_service\_map) | Map of source service and the corresponding target service details. | <pre>list(object({<br>    source_service_name         = string<br>    target_service_name         = string<br>    roles                       = list(string)<br>    description                 = optional(string, null)<br>    source_resource_instance_id = optional(string, null)<br>    target_resource_instance_id = optional(string, null)<br>    source_resource_group_id    = optional(string, null)<br>    target_resource_group_id    = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_zone_service_ref_list"></a> [zone\_service\_ref\_list](#input\_zone\_service\_ref\_list) | Service reference for the zone creation. | `list(string)` | `[]` | no |
| <a name="input_zone_vpc_crn_list"></a> [zone\_vpc\_crn\_list](#input\_zone\_vpc\_crn\_list) | CRN of the VPC for the zones. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_policies"></a> [auth\_policies](#output\_auth\_policies) | Authorizations created |
| <a name="output_cbr_rules"></a> [cbr\_rules](#output\_cbr\_rules) | CBR Rules created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
