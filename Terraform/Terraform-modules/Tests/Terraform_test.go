package test

import (
	"testing"
	"time"
	"net/http"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
	"os/exec"
)

// An example of how to test the Terraform module in examples/terraform-http-example using Terratest.
func TestTerraformHttpExample(t *testing.T) {
	t.Parallel()
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../Deployment",
	})

	// defer terraform.Destroy(t, terraformOptions)

	// cluster_name := os.Getenv("CLUSTER_NAME")
	// account_ID := os.Getenv("ACCOUNT_ID")
	// Path_To_Root := os.Getenv("ROOT_PATH")

	// runScript := func() {
	// 	// Run your script using the os/exec package
	// 	cmd := exec.Command("../../../ArgoCD/ArgoCD-destroy.sh",
	// 		"-c", cluster_name,
	// 		"-a", account_ID,
	// 		"-p", Path_To_Root,
	// 	)
		
	// 	cmd.Stdout = os.Stdout
	// 	cmd.Stderr = os.Stderr
		
	// 	// Run the script and check for errors
	// 	err := cmd.Run()
	// 	if err != nil {
	// 		t.Errorf("Error running script: %v", err)
	// 	}
		
	// 	// Wait for the script to finish executing
	// 	cmd.Wait()
	// }

	// defer runScript()
	
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	url := "https://argocd.whats-the-weather.com"

	// Send HTTPS GET request
    maxRetries := 10

    // Define the interval between retries
    retryInterval := 10 * time.Second

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