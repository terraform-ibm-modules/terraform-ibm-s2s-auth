// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleDir = "examples/complete"
const fullyConfigurableDADir = "solutions/fully-configurable"

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	// Allow tests to create their own resource group
	// This is to avoid conflicts on CBR rules when running in parallel
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
	})
	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "s2s", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "s2s-upg", completeExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestFullyConfigurableDAInSchematics(t *testing.T) {
	t.Parallel()

	// Sample data for s2s authorisation service map
	serviceMap := map[string]interface{}{
		"test-policy-1": map[string]interface{}{
			"source_service_name":      "databases-for-postgresql",
			"target_service_name":      "kms",
			"roles":                    []string{"Reader"},
			"description":              "This is a test policy",
			"source_resource_group_id": "be19bxxxxxxxxxxx83ea90c7d",
			"target_resource_group_id": "be19bxxxxxxxxxxx83ea90c7d",
		},
	}

	serviceMapJSON, err := json.Marshal(serviceMap)
	if err != nil {
		t.Fatalf("Failed to marshal cbr_rules: %v", err)
	}

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "s2s-auth-da",
		TarIncludePatterns: []string{
			"*.tf",
			fullyConfigurableDADir + "/*.tf",
		},
		TemplateFolder:         fullyConfigurableDADir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "service_map", Value: string(serviceMapJSON), DataType: "map(object{})"},
	}

	err = options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
