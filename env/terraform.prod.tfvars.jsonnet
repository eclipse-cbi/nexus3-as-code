// Import data and apply template
local data = import 'prod.json';
local template = import 'terraform.template.tfvars.jsonnet';

template(data)
