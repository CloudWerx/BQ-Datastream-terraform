locals {
  aurora_host     = var.aurora_connection_info.host
  aurora_port     = var.aurora_connection_info.port
  aurora_username = var.aurora_connection_info.username
  aurora_password = var.aurora_connection_info.password
  aurora_database = var.aurora_connection_info.database
}

resource "google_datastream_connection_profile" "aws_aurora_profile" {
  name     = "aws-aurora-profile"
  project  = var.gcp_project
  location = var.gcp_region

  postgres_connection_profile {
    hostname = local.aurora_host
    port     = local.aurora_port
    database = local.aurora_database
    username = local.aurora_username
    password = local.aurora_password

    ssl_config {
      enabled = false
    }
  }
}

# Create BigQuery Dataset
resource "google_bigquery_dataset" "datastream_dataset" {
  dataset_id = "datastream_dataset"
  location   = "US"
}

# Create Datastream Stream
resource "google_datastream_stream" "aurora_to_bigquery_stream" {
  name     = "aurora-to-bigquery-stream"
  project  = var.gcp_project
  location = var.gcp_region

  source_config {
    source_connection_profile = google_datastream_connection_profile.aws_aurora_profile.self_link
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.gcp_bigquery_profile.self_link
  }
}

# Create BigQuery Connection Profile
resource "google_datastream_connection_profile" "gcp_bigquery_profile" {
  name     = "gcp-bigquery-profile"
  project  = var.gcp_project
  location = var.gcp_region

  bigquery_connection_profile {
    dataset = google_bigquery_dataset.datastream_dataset.dataset_id
  }
}


