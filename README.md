### For Google Cloud Platform Credentials:
Go to the Google Cloud Console: Navigate to the Google Cloud Console.

Select Your Project: Make sure you are on the project for which you need the credentials.

Navigate to IAM & Admin: Go to the "IAM & Admin" section and then click on "Service accounts."

Create a Service Account: Click on the "Create Service Account" button and follow the on-screen instructions. Assign the necessary roles for Datastream and BigQuery (for example, Datastream Admin, BigQuery Admin).

Generate JSON Key: Once the service account is created, click on it, then go to the "Keys" tab and generate a new JSON key. Download this JSON file.

Use in Terraform: Place this downloaded JSON file somewhere secure, and refer to its path in the Terraform variable gcp_credentials_file.


### For AWS Aurora Credentials:
Go to the AWS Management Console: Navigate to the AWS Management Console.

Navigate to IAM: Go to the "Services" menu and find "IAM" (Identity and Access Management).

Create User: Create a new IAM User with programmatic access and assign necessary permissions to access the Aurora PostgreSQL database.

Get Credentials: After creating the user, you will get an Access Key ID and Secret Access Key. You can use these to set the AWS provider in Terraform or set them as environment variables.

### how to access aws credentials in terraform via google cloud secrets manager

Step 1: Install and Initialize Google Cloud SDK
If you haven't already, install the Google Cloud SDK.

Initialize the SDK:

bash
Copy code
gcloud init
Step 2: Create Secrets
Create the AWS secrets using Google Cloud SDK commands. Replace your-gcp-project with your GCP project ID, and your-access-key-id and your-secret-access-key with your actual AWS credentials.

bash
Copy code
gcloud secrets create aws-access-key-id \
  --data-file=<(echo -n "your-access-key-id") \
  --project=your-gcp-project

gcloud secrets create aws-secret-access-key \
  --data-file=<(echo -n "your-secret-access-key") \
  --project=your-gcp-project
Step 3: Grant Access to the Secrets
You'll need to grant permissions to the service account used by Terraform to access these secrets. Replace your-service-account with the actual service account email.

bash
Copy code
gcloud secrets add-iam-policy-binding aws-access-key-id \
  --member="serviceAccount:your-service-account" \
  --role="roles/secretmanager.secretAccessor" \
  --project=your-gcp-project

gcloud secrets add-iam-policy-binding aws-secret-access-key \
  --member="serviceAccount:your-service-account" \
  --role="roles/secretmanager.secretAccessor" \
  --project=your-gcp-project
Step 4: Access Secrets in Terraform
In your Terraform script, you can now access these secrets. You'll need the Google provider to interact with Secret Manager.

Firstly, add a Google provider to your provider.tf file if it's not already there:

hcl
Copy code
provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.gcp_project
  region      = var.gcp_region
}
Then, in your main.tf or another appropriate Terraform file, add the following resources to fetch the secrets:

hcl
Copy code
data "google_secret_manager_secret_version" "aws_access_key_id" {
  project = var.gcp_project
  secret  = "aws-access-key-id"
  version = "latest"
}

data "google_secret_manager_secret_version" "aws_secret_access_key" {
  project = var.gcp_project
  secret  = "aws-secret-access-key"
  version = "latest"
}

provider "aws" {
  region      = var.aws_region
  access_key  = data.google_secret_manager_secret_version.aws_access_key_id.secret_data
  secret_key  = data.google_secret_manager_secret_version.aws_secret_access_key.secret_data
}
