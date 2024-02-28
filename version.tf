terraform {
  required_version = ">= 1.3.0, <1.7.0"
  # Each required provider's version should be a flexible range to future proof the module's usage with upcoming minor and patch versions.
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # Use "greater than or equal to" range in modules
      version = ">= 1.56.1"
    }
  }
}
