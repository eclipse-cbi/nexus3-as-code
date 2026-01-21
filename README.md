# Nexus3 as code

The "Nexus3 as Code" project provides assets to manage Sonatype Nexus 3 as code using Terraform. 

This code is based on the Nexus Provider: https://registry.terraform.io/providers/datadrivers/nexus/latest/docs
 
- [Nexus3 as code](#nexus3-as-code)
  - [Quick start!](#quick-start)
    - [Install terraform](#install-terraform)
    - [ENV preparation](#env-preparation)
    - [Init project](#init-project)
      - [Advanced Maven2 Example with Custom Configuration](#advanced-maven2-example-with-custom-configuration)
    - [Advance Repository Configuration](#advance-repository-configuration)
      - [Docker Repository Example](#docker-repository-example)
      - [Available Storage Options](#available-storage-options)
      - [Available Maven Options](#available-maven-options)
      - [Available Docker Options](#available-docker-options)
    - [Configure Proxies](#configure-proxies)
    - [Advance Proxy Configuration](#advance-proxy-configuration)
    - [Bot user, Role And Permission](#bot-user-role-and-permission)
      - [Role](#role)
    - [Default values](#default-values)


## Quick start!

### Install terraform

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-cli

### ENV preparation

Change values in `.env.sh`

```shell
kubectx okd-cX
. ./.env.sh
```

### Init project

```shell
terraform init -backend-config=./backend/backend.${NEXUS_ENV}.hcl
```

or 

```shell
make init
``

### Init workspace

```shell
tf workspace new "${NEXUS_ENV}"
```

or 

```shell
tf workspace select "${NEXUS_ENV}"
```

or 

```shell
make select
``

### Plan and apply

```shell
tf plan -var-file="terraform.${NEXUS_ENV}.tfvars.json"
tf apply -var-file="terraform.${NEXUS_ENV}.tfvars.json"
```

or 

```shell
make plan
make apply
``

## Configuring Nexus instance per env

All data are stored in file `terraform.${NEXUS_ENV}.tfvars.json`.

### Project global properties

| Variable Name | Description | Value |
| --- | --- | --- |
| `repo_address` | Nexus3 instance to target | `"https://repo3.eclipse.org"` |
| `repo_insecure` | Nexus3 mode insecure | `true` |
| `secretsmanager_address` | Secrets manager address. | `https://secretsmanager-staging.eclipse.org` |
| `secretsmanager_path` | Secrets manager path. | `repo.eclipse.org` |

### Configure Projects

Configure the `projects` Terraform variable list:

This allows to define the `project_id` and to configure: 
* project repositories
* project proxies
  
| Property Name | Description | Value |
| --- | --- | --- |
| `project_id` | Id of the project. | `technology.cbi` |

### Configure Repositories 

Configure the `repositories` Terraform variable:
  
The default repository name is based on this convention: `<project_short_name>-<type>-<env>`
E.g: `cbi-maven2-releases`
But can be overridden by the name attribute.

| Property Name | Description | Example Value |
| --- | --- | --- |
| `type` | The type of the repository. Possible values: `maven2`, `docker`, `pypi`, `npm`, `helm` | `"maven2"` |
| `env` | Define the env for the repository. E.g: `releases`, `staging`, `production`, `snapshots`, ... | `"releases"` |
| `name` | Optional: The name of the repository, this don't use `type` and `env` definition, by default see naming convention above. | `"my_test_repo"` |

#### Basic Example

```json
{
  "project_id": "technology.cbi",
  "repositories": [
      {
          "type": "maven2",
          "env": "releases"
      },
      {
          "type": "maven2",
          "env": "snapshots"
      },
      {
          "type": "maven2",
          "env": "staging"
      }
  ]
}
```

#### Advanced Maven2 Example with Custom Configuration

```json
{
  "project_id": "technology.cbi",
  "repositories": [
      {
          "type": "maven2",
          "env": "releases",
          "maven": {
              "version_policy": "RELEASE",
              "layout_policy": "STRICT",
              "content_disposition": "INLINE"
          },
          "storage": {
              "blob_store_name": "technology-cbi",
              "strict_content_type_validation": true,
              "write_policy": "ALLOW"
          }
      },
      {
          "type": "maven2",
          "env": "snapshots",
          "maven": {
              "version_policy": "SNAPSHOT"
          }
      }
  ]
}
```

### Advance Repository Configuration

All repository configurations can be overridden in the configuration file with their corresponding terraform resource values.

#### Docker Repository Example

See `nexus_repository_docker_hosted` resource: 
https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_docker_hosted

```json
{
  "project_id": "technology.cbi",
  "repositories": [
      {
          "type": "docker",
          "docker": {
              "force_basic_auth": true,
              "v1_enabled": true,
              "http_port": 8080,
              "https_port": 8443
          },
          "storage": {
              "write_policy": "ALLOW"
          }
      }
  ]
}
```

#### Available Storage Options

| Property | Description | Values | Default |
| --- | --- | --- | --- |
| `blob_store_name` | Blob store to use | string | project blobstore (auto) |
| `strict_content_type_validation` | Validate content types | true/false | true |
| `write_policy` | Write policy | "ALLOW", "ALLOW_ONCE", "DENY" | "ALLOW" |

#### Available Maven Options

| Property | Description | Values | Default |
| --- | --- | --- | --- |
| `version_policy` | Version policy | "RELEASE", "SNAPSHOT", "MIXED" | "MIXED" |
| `layout_policy` | Layout policy | "STRICT", "PERMISSIVE" | "STRICT" |
| `content_disposition` | Content disposition | "INLINE", "ATTACHMENT" | - |

#### Available Docker Options

| Property | Description | Values | Default |
| --- | --- | --- | --- |
| `force_basic_auth` | Force basic auth | true/false | false |
| `v1_enabled` | Enable Docker V1 API | true/false | false |
| `http_port` | HTTP port | number | - |
| `https_port` | HTTPS port | number | - |

### Configure Proxies 

Configure the `proxies` Terraform variable:
  
The default proxy name is based on this convention: `<project_short_name>-<type>-proxy`
E.g: `cbi-maven2-proxy`
But can be overridden by the name attribute.

| Property Name | Description | Example Value |
| --- | --- | --- |
| `type` | The type of the repository. Possible values: `maven2`, `docker`, `pypi`, `npm`, `helm` | `"maven2"` |
| `name` | Optional: The name of the repository, this don't use `type` definition, by default see naming convention above. | `"my_test_proxy"` |

```json
{
  "project_id": "technology.cbi",
  "proxies": [
      {
          "type": "maven2"
      }
  ],
```
### Advance Proxy Configuration

All proxy configurations can be overridden in the configuration file with their corresponding terraform resource values.

E.g for the `nexus_repository_docker_proxy` resource. 

https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_docker_proxy

```yaml
{
  "project_id": "technology.cbi",
  "proxies": [
      {
          "type": "docker"
          
          "proxy" {
            "remote_url"       = "https://registry-1.docker.io"
            "content_max_age"  = 1440
          }

      }
  ],
}
```

Here, `remote_url` and `content_max_age` have been changed. 

### Bot user, Role And Permission

Bot users, Roles and permissions are created automatically according to `projects` configuration. 

#### Bot users

For each `project_id` a dedicated bot user is created, with this convention: `eclipse-<short_name>-bot`.
Credentials are added to the secrets manager during creation. 

#### Permissions

For each repository and proxy defined in the configure file, permissions are created following this format: 

Repository permission naming convention:
* `nx-repository-view-<type>-<short_name>-<type>-*`
* `nx-repository-admin-<type>-<short_name>-<type>-*`

Proxy permission naming convention:
* `nx-repository-admin-<type>-<short_name>-<type>-proxy-*`
* `nx-repository-view-<type>-<short_name>-<type>-proxy-*`

#### Role

Role configuration allows defining a set of permissions that can be added to users.

Repository Role naming convention:
* `<short_name>-repository-admin`

Proxy Role naming convention:
* `<short_name>-proxy-admin`

### Default values

If default values ​​should be set up in all configurations.  

```json
"defaults":
  "groups": {
    "docker": {
        "docker": {
            "force_basic_auth": false,
            "http_port": 8080,
            "https_port": 8433,
            "v1_enabled": true
        },
        "storage": {
            "blob_store_name": "docker",
            "strict_content_type_validation": true
        }
    },
    "helm": {
    },
    "maven2": {
    },
    "npm": {
    },
    "pypi": {
    }
  },
  "repositories": {
    "docker": {
        "docker": {
            "force_basic_auth": false,
            "http_port": 8080,
            "https_port": 8433,
            "v1_enabled": true
        },
        "storage": {
            "blob_store_name": "docker",
            "strict_content_type_validation": true
        }
    },
    "helm": {
    },
    "maven2": {
    },
    "npm": {
    },
    "pypi": {
    }
  },
  "proxies": {
    "docker": {
        "docker": {
            "force_basic_auth": false,
            "http_port": 8080,
            "https_port": 8433,
            "v1_enabled": true
        },
        "storage": {
            "blob_store_name": "docker",
            "strict_content_type_validation": true
        }
    },
    "helm": {
    },
    "maven2": {
    },
    "npm": {
    },
    "pypi": {
    }
  }
} 

```