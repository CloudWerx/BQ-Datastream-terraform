locals {
  aurora_host     = var.aurora_connection_info.host
  aurora_port     = var.aurora_connection_info.port
  aurora_username = var.aurora_connection_info.username
  aurora_password = var.aurora_connection_info.password
  aurora_database = var.aurora_connection_info.database
}

#AWS RDS Connection Profile
resource "google_datastream_connection_profile" "novi-connect-rds" {
  display_name = "aws-rds-to-bigquery"
  location = var.aws_region
  connection_profile_id = "novi-connect-rds"

  forward_ssh_connectivity {
    hostname = var.SSH_Hostname
    username = var.SSH_User
    port = var.SSH_Port
    private_key =  var.SSH_private_key
  }

  postgresql_profile {
    hostname = local.aurora_host
    port     = local.aurora_port
    database = local.aurora_database
    username = local.aurora_username
    password = local.aurora_password
  }
}

#BigQuery Connection Profile
resource "google_datastream_connection_profile" "bigquery-replica" {
  display_name = "bigquery-replica"
  location = var.gcp_region
  connection_profile_id = "bigquery-replica"

  bigquery_profile {}
}

# Create Datastream Stream
resource "google_datastream_stream" "aws_rds_to_bigquery" {
  display_name     = "aws-rds-to-bigquery"
  location = var.gcp_region
  stream_id = "aws-rds-to-bigquery"
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = google_datastream_connection_profile.novi-connect-rds.id
    postgresql_source_config {
      publication = "novipublication"
      replication_slot = "novirepliocationslot"
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bigquery-replica.id
    bigquery_destination_config {
    data_freshness = var.datafreshness
    }
  }


}