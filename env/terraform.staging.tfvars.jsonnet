// Import data and apply template
local data = import 'staging.json';
local template = import 'terraform.template.tfvars.jsonnet';

template(data)
