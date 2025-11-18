# Configuring complex inputs for Service to Service Authoirsation in IBM Cloud projects

The `service_map` input variable use complex object type. You need to specify this input variable when you configure deployable architecture.

* [Service Map](#service-map) (`service_map`)

## Service Map <a name="service-map"></a>

The `service_map` input variable allows you to define service to service authorisation policy between services in same or different account.

- Variable name: `service_map`
- Type: A map of objects, where the key is a unique attribute to describe the authorisation policy
- Default value: An empty map (`{}`)

### Options for service_map
- `source_service_name` (required): The name of the service requesting the access (or needing the access)

- `target_service_name` (required): The name of the service that the source service wants to access or communicate with.

- `roles` (required): A list of roles or permissions granted from the source service to the target service. These roles define the scope and level of access allowed.

- `description` (optional): A description providing additional context or the purpose of the authorization policy

- `source_service_account_id` (optional): The cloud account ID where the source service resides. This is important when the source and target services belong to different accounts.

- `source_resource_instance_id` (optional): The unique identifier(GUID) for a specific resource instance of the source service. This is mutually exclusive with `source_resource_group_id` and identifies the granular resource for access control.

- `target_resource_instance_id` (optional): The unique identifier(GUID) for the target service. This gives fine-grained control over the target resource. It is mutually exclusive with `target_resource_group_id`.

- `source_resource_group_id` (optional): The resource group ID containing the source service instances. This is an alternative to `source_resource_instance_id` to specify a group-level scope. Cannot be used at the same time as `source_resource_instance_id`.

- `target_resource_group_id` (optional): The resource group ID for the target service. Allows specifying a group-level target rather than an individual resource instance. Mutually exclusive with `target_resource_instance_id`.

### Points to note

- You must provide either `source_resource_instance_id` or `source_resource_group_id` but not both.
- Similarly, only one of `target_resource_instance_id` or `target_resource_group_id` should be provided to avoid conflicts in target scope definition.

### Example Service Map Configuration

#### Cross Account s2s Authorisation Policy

```hcl
service_map = {
  "cross-account-policy" = {
    source_service_name         = "toolchain"
    target_service_name         = "secrets-manager"
    roles                       = ["Viewer"]
    description                 = "Toolchain in account A can view to secrets manager in account B."
    source_service_account_id   = "acct-id-123456"
    source_resource_instance_id = "be19xxxxxxxx3ea90c7d"
    target_resource_instance_id = "abcd12xxxxxxxxe21fgh"
    source_resource_group_id    = null
    target_resource_group_id    = null
  }
}
```

#### Single Resource Instance to whole Resource Group

Authorize one resource instance to access all resources of service "secrets-manager" within a target resource group

```hcl
service_map = {
  "instance-to-group-policy" = {
    source_service_name         = "toolchain"
    target_service_name         = "secrets-manager"
    roles                       = ["Viewer"]
    description                 = "Toolchain instance needs read access to all storage resources in dev group."
    source_resource_instance_id = "be19xxxxxxxx3ea90c7d"
    target_resource_instance_id = null
    source_resource_group_id    = null
    target_resource_group_id    = "example-resource-group"
  }
}
```

For more information, refer to the [IBM Cloud Service to Service Authorisation documentation](https://cloud.ibm.com/docs/account?topic=account-serviceauth&interface=ui) and the [IBM Cloud Terraform Provider documentation for Authorisation Policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy).
