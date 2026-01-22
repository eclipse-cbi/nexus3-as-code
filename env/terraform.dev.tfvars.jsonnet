// Import data and apply template
local data = import 'dev.json';
local template = import 'terraform.template.tfvars.jsonnet';

template(data)
