package test

import (
	"crypto/tls"
	"testing"
	"time"
	"net/http"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// An example of how to test the Terraform module in examples/terraform-http-example using Terratest.
func TestTerraformHttpExample(t *testing.T) {
	t.Parallel()

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../Deployment",
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	url := "https://argocd.whats-the-weather.com"

	// Send HTTPS GET request
    maxRetries := 3

    // Define the interval between retries
    retryInterval := 5 * time.Second

    // Loop for retries
    for attempt := 1; attempt <= maxRetries; attempt++ {
        // Send HTTPS GET request
        resp, err := http.Get(url)
        if err == nil && resp.StatusCode == http.StatusOK {
            // If the response is successful, break out of the loop
            resp.Body.Close()
            return
        }

        // If there's an error or the status code is not 200, log and retry after interval
        t.Logf("Attempt %d: Failed to send GET request or status code not 200: %v", attempt, err)
        if err != nil {
            t.Logf("Error: %v", err)
        } else {
            t.Logf("Status code: %d", resp.StatusCode)
        }
        
        // Close the response body if it's not nil
        if resp != nil {
            resp.Body.Close()
        }

        // If it's not the last attempt, wait for the retry interval
        if attempt < maxRetries {
            time.Sleep(retryInterval)
        }
    }

    // If all retries fail, fail the test
    t.Errorf("All attempts failed to get status code 200")
}