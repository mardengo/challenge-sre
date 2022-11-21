# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

resource "google_cloud_run_service" "run_service" {
  name = "acidlabs-api"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/acidlabs-369203/acidlabs-api:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.run_service.location
  project     = google_cloud_run_service.run_service.project
  service     = google_cloud_run_service.run_service.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
