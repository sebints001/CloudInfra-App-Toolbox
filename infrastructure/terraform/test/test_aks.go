package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestAKSDeployment(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../environments/dev",
    }

    defer terraform.Destroy(t, terraformOptions)

    terraform.InitAndApply(t, terraformOptions)

    clusterName := terraform.Output(t, terraformOptions, "aks_cluster_name")
    assert.NotEmpty(t, clusterName, "AKS Cluster Name should not be empty")
}
