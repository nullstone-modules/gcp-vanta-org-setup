data "google_organization" "this" {
  domain = var.org_domain
}

locals {
  org_id = data.google_organization.this.org_id
}
