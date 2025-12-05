module "types" {
  source   = "./types"
  projects = var.projects
  defaults = var.defaults
}

module "repositories" {
  source   = "./repositories"
  defaults = var.defaults
  projects = var.projects
}

module "proxies" {
  source   = "./proxies"
  defaults = var.defaults
  projects = var.projects
}

module "repositories-group" {
  source     = "./repositories-group"
  defaults   = var.defaults
  projects   = var.projects
  depends_on = [module.repositories, module.proxies]
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
  source   = "./users"
  projects = var.projects
  repo_address = var.repo_address
  depends_on = [module.roles]
}
