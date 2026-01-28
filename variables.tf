variable "org_domain" {
  type        = string
  description = "Domain of the GCP organization"
}

variable "project_name" {
  type        = string
  default     = "vanta-scanner"
  description = "Name of the GCP project that will host the vanta scanner"
}

variable "project_id" {
  type        = string
  default     = ""
  description = "ID of the GCP project that will host the vanta scanner"
}

variable "project_billing_account" {
  type        = string
  description = "Billing account to be associated with the GCP project that will host the vanta scanner"
}

variable "linked_project_ids" {
  type        = list(string)
  description = "List of project IDs to be linked to the GCP project that will host the vanta scanner"
  default     = []
}
