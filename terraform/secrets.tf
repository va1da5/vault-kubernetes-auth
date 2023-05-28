resource "vault_generic_secret" "demo" {
  path = "secret/kubernetes/demo/credentials"

  data_json = <<EOT
{
  "user":   "🤖",
  "password": "🙈"
}
EOT
}

resource "vault_generic_secret" "user" {
  path = "secret/user/credentials"

  data_json = <<EOT
{
  "user":   "🤓",
  "password": "⛔️"
}
EOT
}
