locals {
  serviceaccount_name = "default"
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "default" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_host
  kubernetes_ca_cert     = file(var.kubernetes_ca_cert)
  token_reviewer_jwt     = var.kubernetes_token_reviewer
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "demo" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "demo"
  bound_service_account_names      = [local.serviceaccount_name]
  bound_service_account_namespaces = [var.kubernetes_namespace]
  token_ttl                        = 3600
  audience                         = null
  alias_name_source                = "serviceaccount_name"
}

resource "vault_identity_entity" "demo_role" {
  name = "kubernetes_demo_role"
  metadata = {
    group = "kubernetes"
    role  = "demo"
  }
}

resource "vault_identity_entity_alias" "demo_role" {
  # https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#alias_name_source
  name           = "${var.kubernetes_namespace}/${local.serviceaccount_name}"
  mount_accessor = vault_auth_backend.kubernetes.accessor
  canonical_id   = vault_identity_entity.demo_role.id
}
