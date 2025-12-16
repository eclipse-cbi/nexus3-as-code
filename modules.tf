module "types" {
  source   = "./types"
  projects = var.projects
  defaults = var.defaults
}

module "blobstores" {
  source   = "./blobstores"
  projects = var.projects
}

module "repositories" {
  source             = "./repositories"
  defaults           = var.defaults
  projects           = var.projects
  project_blobstores = module.blobstores.project_blobstores
  depends_on         = [module.blobstores]
}

module "proxies" {
  source             = "./proxies"
  defaults           = var.defaults
  projects           = var.projects
  project_blobstores = module.blobstores.project_blobstores
  depends_on         = [module.blobstores]
}

module "repositories-group" {
  source             = "./repositories-group"
  defaults           = var.defaults
  projects           = var.projects
  project_blobstores = module.blobstores.project_blobstores
  depends_on         = [module.repositories, module.proxies, module.blobstores]
}

module "privileges" {
  source     = "./privileges"
  projects   = var.projects
  depends_on = [module.repositories, module.proxies]
}

module "roles" {
  source     = "./roles"
  projects   = var.projects
  depends_on = [module.privileges]
}

module "users" {
  source       = "./users"
  projects     = var.projects
  repo_address = var.repo_address
  depends_on   = [module.roles]
}
