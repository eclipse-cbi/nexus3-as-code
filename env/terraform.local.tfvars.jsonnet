// Import data and apply template
local data = import 'local.json';
local template = import 'terraform.template.tfvars.jsonnet';

template(data)
