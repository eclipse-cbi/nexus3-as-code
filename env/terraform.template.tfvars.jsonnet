// Reusable template logic
// This file must be imported with a 'data' parameter

function(data)

local utils = {
  // Eg: "technology.jgit" → "jgit", "technology.nebula.nattable" → "nattable"
  shortName(projectId):: 
    local parts = std.split(projectId, '.');
    if std.length(parts) > 1 then parts[std.length(parts) - 1]
    else projectId,

  repo(type, env):: {
    type: type,
    env: env,
  } + (
    if type == 'maven2' && env == 'releases' then {
      maven: { version_policy: 'RELEASE', layout_policy: 'STRICT' }
    } else if type == 'maven2' && env == 'snapshots' then {
      maven: { version_policy: 'SNAPSHOT', layout_policy: 'STRICT' }
    } else if type == 'maven2' && env == 'staging' then {
      maven: { version_policy: 'MIXED', layout_policy: 'STRICT' }
    } else {}
  ),

  customRepo(type, env, customName):: {
    type: type,
    env: env,
    custom_name: customName,
  },

  customGroup(type, customName, members):: {
    type: type,
    custom_name: customName,
    members: members,
  },
};

// Project template
local projectTemplates = {
    
  maven2Standard(projectId, archived=false, shortNameOverride=null):: 
    local shortName = if shortNameOverride != null then shortNameOverride else utils.shortName(projectId);
    {
      project_id: projectId,
      repositories: [
        utils.repo('maven2', 'releases'),
        utils.repo('maven2', 'snapshots'),
      ],
      create_group_auto: true,
    } + (if archived then { archived: true } else {}),

  maven2LegacyStandard(projectId, archived=false, shortNameOverride=null):: 
    local shortName = if shortNameOverride != null then shortNameOverride else utils.shortName(projectId);
    {
      project_id: projectId,
      repositories: [
        utils.repo('maven2', 'releases') + (if shortNameOverride != null then { name: shortNameOverride } else {}),
        utils.repo('maven2', 'snapshots') + (if shortNameOverride != null then { name: shortNameOverride } else {}),
      ],
      create_group_auto: true,
      groups: [
        utils.customGroup('maven2', shortName + '-releases', [shortName + '-maven2-releases']),
        utils.customGroup('maven2', shortName + '-snapshots', [shortName + '-maven2-snapshots']),
      ],
    } + (if archived then { archived: true } else {}),

  maven2LegacyStandardWithStaging(projectId, archived=false, shortNameOverride=null):: 
    local base = self.maven2LegacyStandard(projectId, archived, shortNameOverride);
    local shortName = if shortNameOverride != null then shortNameOverride else utils.shortName(projectId);
    base + {
      repositories: base.repositories + [
        utils.repo('maven2', 'staging'),
      ],
      groups: base.groups + [
        utils.customGroup('maven2', shortName + '-staging', [shortName + '-maven2-staging']),
      ],
    },

  // Maven2 Legacy with custom group names
  maven2LegacyCustomGroupName(projectId, customGroupPrefix, archived=false):: 
    local shortName = utils.shortName(projectId);
    {
      project_id: projectId,
      repositories: [
        utils.repo('maven2', 'releases'),
        utils.repo('maven2', 'snapshots'),
      ],
      create_group_auto: true,
      groups: [
        utils.customGroup('maven2', customGroupPrefix + '-releases', [shortName + '-maven2-releases']),
        utils.customGroup('maven2', customGroupPrefix + '-snapshots', [shortName + '-maven2-snapshots']),
      ],
    } + (if archived then { archived: true } else {}),

  // Helm Template : releases + staging
  helmStandard(projectId, archived=false):: {
    project_id: projectId,
    repositories: [
      utils.repo('helm', 'releases'),
      utils.repo('helm', 'staging'),
    ],
  } + (if archived then { archived: true } else {}),

  // APT Template: stable + dev/unstable
  aptStandard(projectId, blobstoreName=null, archived=false):: {
    project_id: projectId,
    blobstore_name: blobstoreName,
    repositories: [
      {
        type: 'apt',
        distribution: 'stable',
      } + (if blobstoreName != null then { storage: { blob_store_name: blobstoreName } } else {}),
      {
        env: 'dev',
        type: 'apt',
        distribution: 'unstable',
      } + (if blobstoreName != null then { storage: { blob_store_name: blobstoreName } } else {}),
    ],
  } + (if archived then { archived: true } else {}),

  // Maven2 template with staging only (e.g: ee4j.*)
  maven2StagingOnly(projectId, archived=false):: {
    project_id: projectId,
    repositories: [
      {
        type: 'maven2',
        env: 'staging',
        maven: {
          version_policy: 'MIXED',
          layout_policy: 'STRICT',
        },
      },
    ],
  } + (if archived then { archived: true } else {}),

  // Custom template for special cases
  custom(config):: config,
};

// Generate projects from data
local generatedProjects = [
  local p = data.projects[i];
  local template = p.template;
  local archived = if std.objectHas(p, 'archived') then p.archived else false;
  
  if template == 'maven2Standard' then
    projectTemplates.maven2Standard(p.id, archived)
  else if template == 'maven2LegacyStandard' then
    projectTemplates.maven2LegacyStandard(
      p.id, 
      archived,
      if std.objectHas(p, 'shortNameOverride') then p.shortNameOverride else null
    )
  else if template == 'maven2LegacyStandardWithStaging' then
    projectTemplates.maven2LegacyStandardWithStaging(p.id, archived)
  else if template == 'maven2LegacyCustomGroupName' then
    projectTemplates.maven2LegacyCustomGroupName(p.id, p.customGroupPrefix, archived)
  else if template == 'helmStandard' then
    projectTemplates.helmStandard(p.id, archived)
  else if template == 'aptStandard' then
    projectTemplates.aptStandard(p.id, p.blobstoreName, archived)
  else if template == 'maven2StagingOnly' then
    projectTemplates.maven2StagingOnly(p.id, archived)
  else if template == 'custom' then
    projectTemplates.custom(p.config)
  else
    error 'Unknown template: ' + template
  for i in std.range(0, std.length(data.projects) - 1)
];

// Helper function to merge arrays (for repositories, proxies, groups)
local mergeArrays(arr1, arr2) = 
  if arr1 == null && arr2 == null then null
  else if arr1 == null then arr2
  else if arr2 == null then arr1
  else arr1 + arr2;

// Group projects by project_id and merge them
local projectsGroupedById = std.foldl(
  function(acc, project)
    local id = project.project_id;
    local existing = if std.objectHas(acc, id) then acc[id] else null;
    acc + {
      [id]: if existing == null then project else
        existing + project + {
          repositories: mergeArrays(
            if std.objectHas(existing, 'repositories') then existing.repositories else [],
            if std.objectHas(project, 'repositories') then project.repositories else []
          ),
          proxies: mergeArrays(
            if std.objectHas(existing, 'proxies') then existing.proxies else [],
            if std.objectHas(project, 'proxies') then project.proxies else []
          ),
          groups: mergeArrays(
            if std.objectHas(existing, 'groups') then existing.groups else [],
            if std.objectHas(project, 'groups') then project.groups else []
          ),
        }
    },
  generatedProjects,
  {}
);

// Convert grouped object back to array
local projects = std.objectValues(projectsGroupedById);

// Final configuration
data.config + {
  projects: projects,
}
