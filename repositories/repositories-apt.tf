# for debug
output "apt_repositories" {
  value = local.apt_repositories
}

##############################################
# Retrieve GPG secrets from Vault for APT repositories
##############################################

data "vault_kv_secret_v2" "apt_gpg_secrets" {
  for_each = {
    for repo in local.apt_repositories : repo.name => repo.project_id
  }

  mount = "cbi"
  name  = "${each.value}/gpg"
}

##############################################
# APT repositories
##############################################

resource "nexus_repository_apt_hosted" "apt_repositories" {
  for_each = {
    for repo in local.apt_repositories : repo.name => repo
  }

  name   = each.value.name
  online = each.value.online

  distribution = each.value.apt.distribution

  storage {
    blob_store_name                = each.value.storage.blob_store_name
    strict_content_type_validation = each.value.storage.strict_content_type_validation
    write_policy                   = each.value.storage.write_policy
  }

  cleanup {
    policy_names = each.value.cleanup.policy_names
  }

  signing {
    keypair = try(
      each.value.apt_signing.keypair,
      lookup(data.vault_kv_secret_v2.apt_gpg_secrets[each.key].data, "secret-subkeys.asc", null)
    )
    passphrase = try(
      each.value.apt_signing.passphrase,
      lookup(data.vault_kv_secret_v2.apt_gpg_secrets[each.key].data, "passphrase", null)
    )
  }

  component {
    proprietary_components = each.value.component.proprietary_components
  }

  depends_on = [data.vault_kv_secret_v2.apt_gpg_secrets]
}
