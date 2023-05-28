data "vault_policy_document" "kv_secret_rw" {
  rule {
    path         = "secret/data/{{identity.entity.metadata.group}}/{{identity.entity.metadata.role}}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "provide access to a specific role based on metadata"
  }

  rule {
    path         = "secret/data/{{identity.entity.metadata.group}}/+"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "provide access to a group based on metadata"
  }
}

resource "vault_policy" "kv_secret_rw" {
  name   = "kv_secret_rw"
  policy = data.vault_policy_document.kv_secret_rw.hcl
}

resource "vault_identity_group" "kv_secret_rw" {
  name                       = "kv_secret_rw"
  type                       = "internal"
  external_member_entity_ids = true

  member_entity_ids = []

  policies = [
    vault_policy.kv_secret_rw.name
  ]
}

resource "vault_identity_group_member_entity_ids" "members" {

  exclusive         = true
  member_entity_ids = [vault_identity_entity.demo_role.id]
  group_id          = vault_identity_group.kv_secret_rw.id
}
