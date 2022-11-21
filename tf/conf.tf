provider "google" {
  project = "acidlabs-369203"
}
terraform {
  backend "gcs" {
    bucket = "acidlabs-state"
    prefix = "terraform/state"
  }
}
