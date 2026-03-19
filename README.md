# Nexus3 as Code

The "Nexus3 as Code" project provides assets to manage Sonatype Nexus 3 as code using Terraform. 

This code is based on the Nexus Provider: https://registry.terraform.io/providers/datadrivers/nexus/latest/docs

- [Nexus3 as Code](#nexus3-as-code)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Initial Setup](#initial-setup)
  - [Quick Make Guide](#quick-make-guide)
    - [Available Make Commands](#available-make-commands)
    - [Advanced Make Usage](#advanced-make-usage)
      - [Using Jsonnet Templates](#using-jsonnet-templates)
    - [Environment Variables](#environment-variables)
  - [Adding a New Project](#adding-a-new-project)
    - [Prerequisites: Helm Configuration](#prerequisites-helm-configuration)
    - [Method 1: Using Templates (Recommended)](#method-1-using-templates-recommended)
      - [Example: Add a Project Using Templates](#example-add-a-project-using-templates)
      - [With Optional Parameters](#with-optional-parameters)
      - [Template Examples](#template-examples)
        - [Example 1: maven2Standard Template](#example-1-maven2standard-template)
        - [Example 2: maven2StandardWithStaging Template](#example-2-maven2standardwithstaging-template)
        - [Example 3: helmStandard Template](#example-3-helmstandard-template)
    - [Method 2: Custom Configuration](#method-2-custom-configuration)
      - [Custom Configuration Examples](#custom-configuration-examples)
        - [Example 1: Multi-Repository Project](#example-1-multi-repository-project)
        - [Example 2: Project with Custom Proxy](#example-2-project-with-custom-proxy)
    - [Naming Conventions](#naming-conventions)
  - [Configuring Maven Repositories](#configuring-maven-repositories)
    - [Basic Maven Repository Configuration](#basic-maven-repository-configuration)
      - [Standard Repositories (Releases + Snapshots)](#standard-repositories-releases--snapshots)
    - [Advanced Maven Configuration](#advanced-maven-configuration)
      - [Custom Maven Settings](#custom-maven-settings)
      - [Custom Repository Name](#custom-repository-name)
    - [Maven Groups](#maven-groups)
      - [Automatic Group Creation](#automatic-group-creation)
      - [Manual Group Configuration](#manual-group-configuration)
  - [Setting up Maven Staging Repositories](#setting-up-maven-staging-repositories)
    - [Method 1: Using Templates](#method-1-using-templates)
    - [Method 2: Staging Only](#method-2-staging-only)
    - [Method 3: Manual Configuration](#method-3-manual-configuration)
    - [Staging Group Example](#staging-group-example)
  - [Configuring Other Repository Types](#configuring-other-repository-types)
    - [NPM Repositories](#npm-repositories)
      - [Basic NPM Configuration](#basic-npm-configuration)
      - [Advanced NPM Configuration](#advanced-npm-configuration)
    - [PyPI Repositories](#pypi-repositories)
      - [Basic PyPI Configuration](#basic-pypi-configuration)
      - [Advanced PyPI Configuration](#advanced-pypi-configuration)
    - [Docker Repositories](#docker-repositories)
      - [Basic Docker Configuration](#basic-docker-configuration)
      - [Advanced Docker Configuration](#advanced-docker-configuration)
    - [Helm Repositories](#helm-repositories)
      - [Basic Helm Configuration](#basic-helm-configuration)
      - [Advanced Helm Configuration](#advanced-helm-configuration)
      - [Helm Usage Example](#helm-usage-example)
    - [APT Repositories](#apt-repositories)
      - [Basic APT Configuration](#basic-apt-configuration)
      - [Advanced APT Configuration](#advanced-apt-configuration)
    - [RAW Repositories](#raw-repositories)
      - [Basic RAW Configuration](#basic-raw-configuration)
      - [Advanced RAW Configuration](#advanced-raw-configuration)
    - [Multi-Format Project Example](#multi-format-project-example)
  - [Configuring Proxies](#configuring-proxies)
    - [Global Proxies](#global-proxies)
    - [Project-Specific Proxies](#project-specific-proxies)
    - [Proxy Configuration Options](#proxy-configuration-options)
      - [Cache Settings](#cache-settings)
      - [Docker Proxy Example](#docker-proxy-example)
  - [Advanced Configuration](#advanced-configuration)
    - [Using Jsonnet Templates](#using-jsonnet-templates-1)
    - [Default Values](#default-values)
    - [Global Groups with Auto-Collection](#global-groups-with-auto-collection)
    - [Multiple Repositories of Different Types](#multiple-repositories-of-different-types)
  - [Terraform Best Practices](#terraform-best-practices)
    - [1. Project Renaming and Terraform State](#1-project-renaming-and-terraform-state)
      - [Option A: State Move (Recommended)](#option-a-state-move-recommended)
      - [Option B: Import Existing Resources](#option-b-import-existing-resources)
    - [2. Handling Large Changes](#2-handling-large-changes)
    - [3. Targeting Specific Resources](#3-targeting-specific-resources)
    - [4. Workspace Management](#4-workspace-management)
    - [5. Handling Archived Projects](#5-handling-archived-projects)
    - [6. Blob Store Management](#6-blob-store-management)
    - [7. Handling Terraform Lock Files](#7-handling-terraform-lock-files)
  - [Bot Management](#bot-management)
    - [Sharing Permissions Between Projects (shared\_perms\_from)](#sharing-permissions-between-projects-shared_perms_from)
      - [Use Case](#use-case)
      - [Configuration](#configuration)
      - [What This Creates](#what-this-creates)
    - [Renewing Bot Secrets (force\_token\_update)](#renewing-bot-secrets-force_token_update)
      - [Use Case](#use-case-1)
      - [Procedure](#procedure)
      - [Accessing Updated Credentials](#accessing-updated-credentials)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
      - [1. "Error: workspace doesn't exist"](#1-error-workspace-doesnt-exist)
      - [2. Permission Denied](#2-permission-denied)
      - [3. State Lock Errors](#3-state-lock-errors)
      - [4. Jsonnet Compilation Errors](#4-jsonnet-compilation-errors)
    - [Debugging Tips](#debugging-tips)
      - [Enable Verbose Logging](#enable-verbose-logging)
      - [Verify Resource Configuration](#verify-resource-configuration)


---


## Getting Started

### Prerequisites

1. **Terraform**: Install from [HashiCorp's website](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. **kubectl**: For Kubernetes backend state management
3. **jsonnet** (optional): For using template-based configurations
4. **Access credentials**: Nexus admin credentials and secretsmanager token

### Initial Setup

1. **Set your environment variables** in `.env.sh`:
   ```bash
   export NEXUS_ENV="prod"  # or "dev", "staging"
   ```

2. **Source the environment**:
   ```bash
   . ./.env.sh
   ```

3. **Initialize Terraform**:
   ```bash
   make init
   ```

4. **Select or create workspace**:
   ```bash
   make select
   ```

5. **Plan and apply**:
   ```bash
   make plan
   make apply
   ```
---


## Quick Make Guide

This project uses a `Makefile` to simplify Terraform operations. **Always use `make` commands instead of running `terraform` directly** to ensure proper variable file handling, validation, and compilation.

### Available Make Commands

| Command | Description | What it does |
|---------|-------------|-------------|
| `make help` | Show all available commands | Lists all make targets with descriptions |
| `make init` | Initialize Terraform | Runs `terraform init` with correct backend config |
| `make select` | Select/create workspace | Selects workspace or creates if doesn't exist |
| `make validate` | Validate configuration | Checks Terraform syntax and configuration |
| `make fmt` | Format Terraform files | Auto-formats all `.tf` files |
| `make compile-jsonnet` | Compile Jsonnet to JSON | Converts `.jsonnet` template to `.tfvars.json` |
| `make plan` | Plan changes | Shows what will be changed (dry-run) |
| `make apply` | Apply changes | Applies the configuration to Nexus |
| `make destroy` | Destroy all resources | **DANGEROUS**: Destroys all managed resources |
| `make refresh` | Refresh state | Updates state from actual infrastructure |
| `make outputs` | Show outputs | Displays Terraform outputs |
| `make outputs-json` | Show outputs as JSON | Displays outputs in JSON format |
| `make status` | Show current state | Displays current Terraform state |
| `make clean` | Clean local files | Removes `.terraform/` and lock files |

### Advanced Make Usage

#### Using Jsonnet Templates

```bash
# Edit Jsonnet template
vim env/terraform.prod.tfvars.jsonnet

# Compile and plan (compile happens automatically)
make plan

# Or compile manually
make compile-jsonnet
```

### Environment Variables

The Makefile uses these environment variables:

| Variable | Description | Example |
|----------|-------------|----------|
| `NEXUS_ENV` | Target environment | `prod`, `staging`, `dev` |
| `TF_PARALLELISM` | Terraform parallelism level | `30` (default) |
| `JSONNET_FILE` | Source Jsonnet file | Auto-detected from `$NEXUS_ENV` |
| `TF_VAR_FILE` | Target tfvars JSON file | Auto-detected from `$NEXUS_ENV` |

**Important**: Always set `NEXUS_ENV` before running any `make` commands!

---

## Adding a New Project

There are two approaches to adding a project: **using templates** (recommended) or **custom configuration**.

### Prerequisites: Helm Configuration

**IMPORTANT**: Before creating a project in Terraform, you must first configure the Helm deployment to create the necessary Persistent Volume Claim (PVC) for the project's blob store.

1. **Add the project to the Nexus Helm chart repository**:
   - Repository: https://github.com/eclipse-cbi/sonatype-nexus

2. **Update the `values.yaml` file**:
   - File: https://github.com/eclipse-cbi/sonatype-nexus/blob/master/charts/nexus3/values.yaml
   - Add your project's blob store configuration and quotas if needed to create the PVC

3. **Apply the Helm changes**:
   ```bash
   # Update the Nexus deployment with the new PVC configuration
   ./helm-deploy-nexus3.sh <env>
   ```

4. **Verify PVC creation**:
   ```bash
   # Check that the PVC was created successfully
   kubectl get pvc -n repo3-eclipse-org | grep <your-project>
   ```

Once the PVC is created on the cluster, you can proceed with the Terraform configuration below.

---

### Method 1: Using Templates (Recommended)

Templates provide pre-configured repository sets for common use cases. Available templates:

- `maven2Standard`: Creates releases + snapshots repositories with auto-group
- `maven2StandardWithStaging`: Adds staging repository to maven2Standard
- `maven2StagingOnly`: Only staging repository
- `maven2StandardNoStrictValidation`: Maven2 with permissive layout policy
- `helmStandard`: Helm releases + staging
- `aptStandard`: APT stable + unstable distributions

#### Example: Add a Project Using Templates

Edit `env/<env>.json` and add to the `projects` array:

```json
{
  "id": "technology.myproject",
  "template": "maven2StandardWithStaging"
}
```

This will automatically create:
- `myproject-maven2-releases` repository
- `myproject-maven2-snapshots` repository
- `myproject-maven2-staging` repository
- `myproject-maven2` group (containing all three)
- Bot user: `eclipse-myproject-bot`
- Roles and permissions for the project

#### With Optional Parameters

```json
{
  "id": "technology.myproject",
  "template": "maven2Standard",
  "archived": true,                    // archived do not create bot
  "shortNameOverride": "custom-name",  // Override default short name
  "blobstore_soft_quota_limit": 95     // specific soft quota when set above default size 50G
}
```

#### Template Examples

##### Example 1: maven2Standard Template

```json
{
  "id": "technology.simple",
  "template": "maven2Standard"
}
```

**Created Resources:**

Repositories:
- `simple-maven2-releases`
  - URL: `https://repo.eclipse.org/repository/simple-maven2-releases/`
  - Type: Maven2 (RELEASE)
- `simple-maven2-snapshots`
  - URL: `https://repo.eclipse.org/repository/simple-maven2-snapshots/`
  - Type: Maven2 (SNAPSHOT)

Groups:
- `simple-maven2`
  - URL: `https://repo.eclipse.org/repository/simple-maven2/`
  - Members: simple-maven2-releases, simple-maven2-snapshots

Users:
- `eclipse-simple-bot` (with credentials in the secretsmanager)

Roles & Permissions:
- `simple-repository-admin`
- View and admin permissions for all repositories

##### Example 2: maven2StandardWithStaging Template

```json
{
  "id": "technology.complex",
  "template": "maven2StandardWithStaging",
  "blobstore_soft_quota_limit": 100
}
```

**Created Resources:**

Repositories:
- `complex-maven2-releases`
  - URL: `https://repo.eclipse.org/repository/complex-maven2-releases/`
  - Type: Maven2 (RELEASE)
- `complex-maven2-snapshots`
  - URL: `https://repo.eclipse.org/repository/complex-maven2-snapshots/`
  - Type: Maven2 (SNAPSHOT)
- `complex-maven2-staging`
  - URL: `https://repo.eclipse.org/repository/complex-maven2-staging/`
  - Type: Maven2 (MIXED)

Groups:
- `complex-maven2`
  - URL: `https://repo.eclipse.org/repository/complex-maven2/`
  - Members: complex-maven2-releases, complex-maven2-snapshots, complex-maven2-staging

Blob Store:
- `technology-complex` (with 100GB soft quota limit)

Users:
- `eclipse-complex-bot` (with credentials in the secretsmanager)

Roles & Permissions:
- `complex-repository-admin`
- View and admin permissions for all repositories

##### Example 3: helmStandard Template

```json
{
  "id": "automotive.tractusx",
  "template": "helmStandard"
}
```

**Created Resources:**

Repositories:
- `tractusx-helm-releases`
  - URL: `https://repo.eclipse.org/repository/tractusx-helm-releases/`
  - Type: Helm
- `tractusx-helm-staging`
  - URL: `https://repo.eclipse.org/repository/tractusx-helm-staging/`
  - Type: Helm

Groups:
- `tractusx-helm`
  - URL: `https://repo.eclipse.org/repository/tractusx-helm/`
  - Members: tractusx-helm-releases, tractusx-helm-staging

Users:
- `eclipse-tractusx-bot` (with credentials in secretsmanager)

Roles & Permissions:
- `tractusx-repository-admin`
- View and admin permissions for all repositories

### Method 2: Custom Configuration

For projects with specific requirements, use the `custom` template:

```json
{
  "id": "technology.myproject",
  "template": "custom",
  "config": {
    "project_id": "technology.myproject",
    "repositories": [
      {
        "type": "maven2",
        "env": "releases",
        "maven": {
          "version_policy": "RELEASE",
          "layout_policy": "STRICT"
        }
      },
      {
        "type": "docker",
        "env": "releases",
        "docker": {
          "http_port": 8082,
          "https_port": 8443,
          "force_basic_auth": true
        }
      }
    ],
    "create_group_auto": true
  }
}
```

#### Custom Configuration Examples

##### Example 1: Multi-Repository Project

```json
{
  "id": "technology.multi",
  "template": "custom",
  "config": {
    "project_id": "technology.multi",
    "repositories": [
      { "type": "maven2", "env": "releases" },
      { "type": "maven2", "env": "snapshots" },
      { "type": "docker", "env": "releases" },
      { "type": "npm", "env": "releases" }
    ],
    "create_group_auto": true
  }
}
```

**Created Resources:**

Repositories:
- `multi-maven2-releases`
  - URL: `https://repo.eclipse.org/repository/multi-maven2-releases/`
  - Type: Maven2 (RELEASE)
- `multi-maven2-snapshots`
  - URL: `https://repo.eclipse.org/repository/multi-maven2-snapshots/`
  - Type: Maven2 (SNAPSHOT)
- `multi-docker-releases`
  - URL: `https://repo.eclipse.org/repository/multi-docker-releases/`
  - Type: Docker (requires docker login)
- `multi-npm-releases`
  - URL: `https://repo.eclipse.org/repository/multi-npm-releases/`
  - Type: NPM

Groups (auto-created per type):
- `multi-maven2`
  - URL: `https://repo.eclipse.org/repository/multi-maven2/`
  - Members: multi-maven2-releases, multi-maven2-snapshots
- `multi-docker`
  - URL: `https://repo.eclipse.org/repository/multi-docker/`
  - Members: multi-docker-releases
- `multi-npm`
  - URL: `https://repo.eclipse.org/repository/multi-npm/`
  - Members: multi-npm-releases

Users:
- `eclipse-multi-bot` (with credentials in secretsmanager)

Roles & Permissions:
- `multi-repository-admin`
- View and admin permissions for all repositories and types

##### Example 2: Project with Custom Proxy

```json
{
  "id": "technology.custom",
  "template": "custom",
  "config": {
    "project_id": "technology.custom",
    "repositories": [
      { "type": "maven2", "env": "releases" },
      { "type": "maven2", "env": "snapshots" }
    ],
    "proxies": [
      {
        "type": "maven2",
        "custom_name": "custom-proxy",
        "remote_url": "https://custom.maven.repo/maven2/",
        "proxy": {
          "metadata_max_age": 60
        },
        "negative_cache": {
          "enabled": true,
          "ttl": 10
        }
      }
    ],
    "create_group_auto": true
  }
}
```

**Created Resources:**

Repositories:
- `custom-maven2-releases`
  - URL: `https://repo.eclipse.org/repository/custom-maven2-releases/`
  - Type: Maven2 (RELEASE)
- `custom-maven2-snapshots`
  - URL: `https://repo.eclipse.org/repository/custom-maven2-snapshots/`
  - Type: Maven2 (SNAPSHOT)

Proxies:
- `custom-proxy-maven2-proxy`
  - URL: `https://repo.eclipse.org/repository/custom-proxy-maven2-proxy/`
  - Remote: `https://custom.maven.repo/maven2/`
  - Cache: Metadata TTL 60min, Negative cache 10min

Groups:
- `custom-maven2`
  - URL: `https://repo.eclipse.org/repository/custom-maven2/`
  - Members: custom-maven2-releases, custom-maven2-snapshots

Users:
- `eclipse-custom-bot` (with credentials in the secretsmanager)

Roles & Permissions:
- `custom-repository-admin` (for repositories)
- `custom-proxy-admin` (for proxies)
- View and admin permissions for all repositories and proxies

**Usage Example:**

```xml
<!-- pom.xml -->
<repositories>
  <repository>
    <id>custom-maven2</id>
    <url>https://repo.eclipse.org/repository/custom-maven2/</url>
  </repository>
</repositories>
```

### Naming Conventions

- **Default repository name**: `<short-name>-<type>-<env>`
  - Example: `myproject-maven2-releases`
- **Short name extraction**: Last segment of project ID
  - `technology.nebula.nattable` → `nattable`
- **Custom names**: Use `custom_name` attributes to override

---

## Configuring Maven Repositories

> **Terraform Documentation**: [Maven Hosted](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_maven_hosted) | [Maven Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_maven_proxy) | [Maven Group](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_maven_group)

### Basic Maven Repository Configuration

#### Standard Repositories (Releases + Snapshots)

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    {
      "type": "maven2",
      "env": "releases"
    },
    {
      "type": "maven2",
      "env": "snapshots"
    }
  ],
  "create_group_auto": true
}
```

This creates:
- `myproject-maven2-releases`
- `myproject-maven2-snapshots`
- `myproject-maven2` (group containing both)

### Advanced Maven Configuration

#### Custom Maven Settings

```json
{
  "type": "maven2",
  "env": "releases",
  "maven": {
    "version_policy": "RELEASE",      // RELEASE, SNAPSHOT, MIXED
    "layout_policy": "STRICT",        // STRICT, PERMISSIVE
    "content_disposition": "INLINE"   // INLINE, ATTACHMENT
  },
  "storage": {
    "blob_store_name": "custom-blob",
    "strict_content_type_validation": true,
    "write_policy": "ALLOW"           // ALLOW, ALLOW_ONCE, DENY
  }
}
```

#### Custom Repository Name

```json
{
  "type": "maven2",
  "env": "releases",
  "name": "custom-repo-name"  // Overrides default naming
}
```

### Maven Groups

Groups aggregate multiple repositories for simplified access.

#### Automatic Group Creation

Set `create_group_auto: true` to automatically create a group containing all project repositories:

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    { "type": "maven2", "env": "releases" },
    { "type": "maven2", "env": "snapshots" }
  ],
  "create_group_auto": true
}
```

Creates: `myproject-maven2` group with both repositories.

#### Manual Group Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    { "type": "maven2", "env": "releases" },
    { "type": "maven2", "env": "snapshots" }
  ],
  "groups": [
    {
      "type": "maven2",
      "custom_name": "myproject-public",
      "include_type_in_name": false,
      "members": [
        "myproject-maven2-releases",
        "myproject-maven2-snapshots",
        "maven-central-releases-proxy"
      ]
    }
  ]
}
```

---

## Setting up Maven Staging Repositories

Staging repositories are used for release candidate validation before promoting to production.

### Method 1: Using Templates

Use the `maven2StandardWithStaging` template:

```json
{
  "id": "technology.myproject",
  "template": "maven2StandardWithStaging"
}
```

Creates:
- `myproject-maven2-releases`
- `myproject-maven2-snapshots`
- `myproject-maven2-staging`
- `myproject-maven2` group (containing all three)

### Method 2: Staging Only

For projects that only need staging (common for Jakarta EE projects):

```json
{
  "id": "ee4j.myproject",
  "template": "maven2StagingOnly"
}
```

Creates only:
- `myproject-maven2-staging`

### Method 3: Manual Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    { "type": "maven2", "env": "releases" },
    { "type": "maven2", "env": "snapshots" },
    {
      "type": "maven2",
      "env": "staging",
      "maven": {
        "version_policy": "MIXED",     // Allows both releases and snapshots
        "layout_policy": "STRICT"
      }
    }
  ],
  "create_group_auto": true
}
```

### Staging Group Example

For aggregating multiple staging repositories:

```json
{
  "project_id": "ee4j",
  "groups": [
    {
      "type": "maven2",
      "custom_name": "ee4j-staging",
      "include_type_in_name": false,
      "members": [
        "angus-maven2-staging",
        "batch-maven2-staging",
        "cdi-maven2-staging",
        "faces-maven2-staging"
      ]
    }
  ]
}
```

---

## Configuring Other Repository Types

In addition to Maven repositories, Nexus supports multiple repository formats for different package ecosystems.

### NPM Repositories

> **Terraform Documentation**: [NPM Hosted](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_npm_hosted) | [NPM Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_npm_proxy) | [NPM Group](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_npm_group)

NPM repositories store Node.js packages and dependencies.

#### Basic NPM Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    {
      "type": "npm",
      "env": "releases"
    },
    {
      "type": "npm",
      "env": "snapshots"
    }
  ]
}
```

Creates:
- `myproject-npm-releases`
- `myproject-npm-snapshots`

#### Advanced NPM Configuration

```json
{
  "type": "npm",
  "env": "releases",
  "storage": {
    "blob_store_name": "npm-blob",
    "strict_content_type_validation": true,
    "write_policy": "ALLOW_ONCE"
  },
  "component": {
    "proprietary_components": true
  }
}
```

**NPM-specific options:**
- `component.proprietary_components`: Mark packages as proprietary (default: false)

### PyPI Repositories

> **Terraform Documentation**: [PyPI Hosted](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_pypi_hosted) | [PyPI Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_pypi_proxy) | [PyPI Group](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_pypi_group)

PyPI repositories store Python packages.

#### Basic PyPI Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    {
      "type": "pypi",
      "env": "releases"
    }
  ]
}
```

Creates:
- `myproject-pypi-releases`

#### Advanced PyPI Configuration

```json
{
  "type": "pypi",
  "env": "releases",
  "storage": {
    "blob_store_name": "pypi-blob",
    "strict_content_type_validation": true,
    "write_policy": "ALLOW"
  },
  "component": {
    "proprietary_components": false
  }
}
```

### Docker Repositories

> **Terraform Documentation**: [Docker Hosted](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_docker_hosted) | [Docker Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_docker_proxy) | [Docker Group](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_docker_group)

Docker repositories store container images.

IMPORTANT: we won't support Docker repositories for projects, alternative options: dockerhub, GitLab container registry, ghcr.io, quay.io and later harbor. 

#### Basic Docker Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    {
      "type": "docker",
      "env": "releases"
    }
  ]
}
```

Creates: `myproject-docker-releases`

#### Advanced Docker Configuration

```json
{
  "type": "docker",
  "env": "releases",
  "docker": {
    "http_port": 8082,
    "https_port": 8443,
    "force_basic_auth": true,
    "v1_enabled": false
  },
  "storage": {
    "blob_store_name": "docker-blob",
    "write_policy": "ALLOW"
  }
}
```

### Helm Repositories

> **Terraform Documentation**: [Helm Hosted](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_helm_hosted) | [Helm Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_helm_proxy)

Helm repositories store Kubernetes Helm charts.

#### Basic Helm Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    {
      "type": "helm",
      "env": "releases"
    },
    {
      "type": "helm",
      "env": "staging"
    }
  ]
}
```

Creates:
- `myproject-helm-releases`
- `myproject-helm-staging`

#### Advanced Helm Configuration

```json
{
  "type": "helm",
  "env": "releases",
  "storage": {
    "blob_store_name": "helm-blob",
    "strict_content_type_validation": true,
    "write_policy": "ALLOW_ONCE"
  }
}
```

#### Helm Usage Example

```bash
# Add repository
helm repo add myproject https://repo.eclipse.org/repository/myproject-helm-releases/

# Update repos
helm repo update

# Install chart
helm install my-release myproject/my-chart
```

### APT Repositories

> **Terraform Documentation**: [APT Hosted](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_apt_hosted) | [APT Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_apt_proxy)

APT repositories store Debian/Ubuntu packages.

#### Basic APT Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    {
      "type": "apt",
      "distribution": "stable"
    },
    {
      "type": "apt",
      "env": "dev",
      "distribution": "unstable"
    }
  ]
}
```

Creates:
- `myproject-apt` (for stable)
- `myproject-apt-dev` (for unstable)

#### Advanced APT Configuration

```json
{
  "type": "apt",
  "distribution": "stable",
  "storage": {
    "blob_store_name": "apt-blob",
    "strict_content_type_validation": true,
    "write_policy": "ALLOW"
  },
  "apt_signing": {
    "keypair": "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
    "passphrase": "secret-passphrase"
  },
  "component": {
    "proprietary_components": false
  }
}
```

**APT-specific options:**

| Option | Description | Required |
|--------|-------------|----------|
| `distribution` | Debian distribution name (e.g., stable, testing, unstable) | Yes |
| `apt_signing.keypair` | GPG private key for signing packages | Yes* |
| `apt_signing.passphrase` | Passphrase for GPG key | Yes* |

*Signing credentials are typically stored in the secretsmanager and auto-retrieved.

**Important Notes:**
- APT repositories require GPG signing for package integrity
- The system automatically retrieves GPG keys from the secretsmanager at path: `cbi/<project_id>/gpg`

### RAW Repositories

> **Terraform Documentation**: [RAW Hosted](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_raw_hosted) | [RAW Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_raw_proxy) | [RAW Group](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_raw_group)

RAW repositories store arbitrary files (binaries, archives, etc.).

#### Basic RAW Configuration

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    {
      "type": "raw",
      "env": "releases"
    }
  ]
}
```

Creates: `myproject-raw-releases`

#### Advanced RAW Configuration

```json
{
  "type": "raw",
  "env": "releases",
  "storage": {
    "blob_store_name": "raw-blob",
    "strict_content_type_validation": false,
    "write_policy": "ALLOW"
  }
}
```


### Multi-Format Project Example

A complete project with multiple repository types:

```json
{
  "id": "technology.multiformat",
  "template": "custom",
  "config": {
    "project_id": "technology.multiformat",
    "repositories": [
      {
        "type": "maven2",
        "env": "releases",
        "maven": {
          "version_policy": "RELEASE",
          "layout_policy": "STRICT"
        }
      },
      {
        "type": "docker",
        "env": "releases",
        "docker": {
          "http_port": 8090,
          "force_basic_auth": true
        }
      },
      {
        "type": "npm",
        "env": "releases"
      },
      {
        "type": "pypi",
        "env": "releases"
      },
      {
        "type": "helm",
        "env": "releases"
      },
      {
        "type": "raw",
        "env": "releases"
      }
    ],
    "create_group_auto": true
  }
}
```

This creates:
- `multiformat-maven2-releases`
- `multiformat-docker-releases`
- `multiformat-npm-releases`
- `multiformat-pypi-releases`
- `multiformat-helm-releases`
- `multiformat-raw-releases`
- Auto-generated groups per type

---

## Configuring Proxies

> **Terraform Documentation**: Proxy resources are type-specific - see [Maven Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_maven_proxy), [Docker Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_docker_proxy), [NPM Proxy](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs/resources/repository_npm_proxy), etc.

Proxies cache artifacts from external repositories.

### Global Proxies

Global proxies are shared across all projects. Configure in the `global_proxies` section:

```json
{
  "config": {
    "global_proxies": [
      {
        "type": "maven2",
        "custom_name": "maven-central-releases",
        "include_type_in_name": false,
        "remote_url": "https://repo1.maven.org/maven2/",
        "maven": {
          "version_policy": "RELEASE",
          "layout_policy": "STRICT"
        },
        "storage": {
          "blob_store_name": "blobs-proxy-maven2"
        },
        "negative_cache": {
          "enabled": true,
          "ttl": 10
        },
        "proxy": {
          "content_max_age": 1440,
          "metadata_max_age": 60
        }
      }
    ]
  }
}
```

### Project-Specific Proxies

Add proxies to individual projects:

```json
{
  "project_id": "technology.myproject",
  "proxies": [
    {
      "type": "maven2",
      "remote_url": "https://custom-maven-repo.com/maven2/",
      "proxy": {
        "content_max_age": 1440,
        "metadata_max_age": 1440
      },
      "storage": {
        "blob_store_name": "custom-blob"
      }
    }
  ]
}
```

### Proxy Configuration Options

#### Cache Settings

```json
{
  "negative_cache": {
    "enabled": true,
    "ttl": 10        // Minutes to cache 404 responses
  },
  "proxy": {
    "content_max_age": 1440,   // Minutes to cache content
    "metadata_max_age": 60      // Minutes to cache metadata
  }
}
```

#### Docker Proxy Example

```json
{
  "type": "docker",
  "custom_name": "docker-hub",
  "include_type_in_name": false,
  "remote_url": "https://registry-1.docker.io",
  "docker": {
    "force_basic_auth": true,
    "v1_enabled": false
  },
  "docker_proxy": {
    "index_type": "HUB"   // HUB, REGISTRY, CUSTOM
  },
  "storage": {
    "blob_store_name": "blobs-proxy-docker"
  }
}
```

---

## Advanced Configuration

### Using Jsonnet Templates

For complex, repetitive configurations, use Jsonnet templates.

1. **Edit the Jsonnet file**: `env/terraform.<env>.tfvars.jsonnet`
2. **Compile to JSON**:
   ```bash
   make compile-jsonnet
   ```
   Or manually:
   ```bash
   jsonnet env/terraform.prod.tfvars.jsonnet > terraform.prod.tfvars.json
   ```

### Default Values

Set defaults for all repositories/proxies of a specific type:

```json
{
  "config": {
    "defaults": {
      "repositories": {
        "maven2": {
          "storage": {
            "blob_store_name": "default-maven-blob"
          },
          "maven": {
            "layout_policy": "STRICT"
          }
        }
      },
      "proxies": {
        "docker": {
          "docker": {
            "force_basic_auth": true
          },
          "storage": {
            "blob_store_name": "default-docker-blob"
          }
        }
      }
    }
  }
}
```

### Global Groups with Auto-Collection

Automatically collect repositories across projects:

```json
{
  "global_groups": [
    {
      "type": "maven2",
      "custom_name": "maven2-releases",
      "include_type_in_name": false,
      "auto_collect": {
        "env": "releases",
        "type": "maven2"
      },
      "additional_members": ["maven-central-releases-proxy"]
    }
  ]
}
```

This automatically adds all `maven2` repositories with `env: "releases"` to the group.

### Multiple Repositories of Different Types

```json
{
  "project_id": "technology.myproject",
  "repositories": [
    { "type": "maven2", "env": "releases" },
    { "type": "docker", "env": "releases" },
    { "type": "npm", "env": "releases" },
    { "type": "pypi", "env": "releases" }
  ]
}
```

---

## Terraform Best Practices

### 1. Project Renaming and Terraform State

When renaming a project, Terraform will destroy and recreate all resources unless you manage the state.

#### Option A: State Move (Recommended)

If changing the project ID from `old.project` to `new.project`:

```bash
# List current state
make status | grep old-project
# Or directly with terraform
terraform state list | grep old-project

# Move each resource (requires direct terraform command)
terraform state mv \
  'nexus_repository_maven_hosted.maven-repositories["old-project-maven2-releases"]' \
  'nexus_repository_maven_hosted.maven-repositories["new-project-maven2-releases"]'

# Verify changes
make plan
```

#### Option B: Import Existing Resources

If resources already exist in Nexus:

```bash
# Import repository (requires direct terraform command)
terraform import \
  'nexus_repository_maven_hosted.maven-repositories["project-maven2-releases"]' \
  project-maven2-releases

# Verify changes
make plan
```

### 2. Handling Large Changes

For projects with many resources:

```bash
# Increase parallelism (default: 30)
TF_PARALLELISM=50 make apply
```

### 3. Targeting Specific Resources

To apply changes to specific resources only:

```bash
# Target specific resources (requires direct terraform command)
# Note: Make doesn't support -target flag, use terraform directly
terraform apply -var-file=terraform.${NEXUS_ENV}.tfvars.json \
  -target=module.blobstores

# Or target specific resources
terraform apply -var-file=terraform.${NEXUS_ENV}.tfvars.json \
  -target='nexus_repository_maven_hosted.maven-repositories["myproject-maven2-releases"]'
```

### 4. Workspace Management

Always work in the correct workspace:

```bash
# List workspaces (requires direct terraform command)
terraform workspace list

# Select workspace (use make instead)
make select  # Uses $NEXUS_ENV variable

# Or select manually
terraform workspace select prod

# Verify current workspace
terraform workspace show
```

### 5. Handling Archived Projects

To mark a project as archived without deleting:

```json
{
  "id": "old.project",
  "template": "maven2Standard",
  "archived": true
}
```

The `archived` flag is metadata only and doesn't affect Terraform resources.

### 6. Blob Store Management

When changing blob stores, data must be manually migrated:

1. Create new blob store (https://github.com/eclipse-cbi/sonatype-nexus)
2. Update repository configuration
3. Apply changes (creates new repo or updates existing)
4. Manually migrate data in Nexus UI
5. Delete old blob store when empty


### 7. Handling Terraform Lock Files

When encountering lock issues:

```bash
# Force unlock (use with caution!) - requires direct terraform command
terraform force-unlock <lock-id>

# Verify workspace is clean
make status
# Or list resources
terraform state list
```

---

## Bot Management

### Sharing Permissions Between Projects (shared_perms_from)

When you have multiple related projects that need access to the same repositories but require separate bot accounts, use the `shared_perms_from` feature. This allows projects to share repository resources and permissions without duplicating Nexus resources.

#### Use Case

Projects `eclipse.platform` and `eclipse.platform.releng` both need access to the same Maven repositories, but each requires its own bot account with similar permissions.

#### Configuration

In the environment configuration file (e.g., `env/<env>.json`):

```json
{
  "projects": [
    {
      "id": "eclipse.platform.releng",
      "template": "maven2StandardWithStaging",
      "config": {
        "project_id": "eclipse.platform.releng"
      }
    },
    {
      "id": "eclipse.platform",
      "template": "custom",
      "config": {
        "project_id": "eclipse.platform",
        "shared_perms_from": "eclipse.platform.releng"
      }
    }
  ]
}
```

#### What This Creates

**For `eclipse.platform.releng`** (main project):
- Blobstore: `eclipse-platform-releng`
- Repositories:
  - `eclipse-releng-maven2-releases`
  - `eclipse-releng-maven2-snapshots`
  - `eclipse-releng-maven2-staging`
- Repository group: `eclipse-releng-maven2`
- Bot: `eclipse-releng-bot`
- Role: `releng-repository-bot-role` (with permissions to all repositories)

**For `eclipse.platform`** (shared permissions project):
- Bot: `eclipse-platform-bot`
- Role: `platform-repository-bot-role` (with same permissions as releng role)
- **No duplicate resources**: Uses existing repositories from `eclipse.platform.releng`

NOTE:

- The referenced project (specified in `shared_perms_from`) must be defined **before** the sharing project in the configuration
- Bot credentials are stored separately in Vault: `repo.eclipse.org/bot/<bot-userid>`
- Both bots can publish to the same repositories simultaneously

---

### Renewing Bot Secrets (force_token_update)

When you need to regenerate bot credentials (e.g., for security rotation or when credentials are compromised), use the `force_token_update` flag.

#### Use Case

The bot password for `eclipse.platform.releng` needs to be regenerated and updated in Vault.

#### Procedure

1. **Add force_token_update flag** to your project configuration:

```json
{
  "id": "eclipse.platform.releng",
  "template": "maven2StandardWithStaging",
  "config": {
    "project_id": "eclipse.platform.releng",
    "force_token_update": true
  }
}
```

2. **Apply the configuration**:

```bash
make generate
make apply
```

This will:
- Generate a new random password for the bot
- Update the bot's password in Nexus
- Store the new credentials in Vault at: `cbi/eclipse.platform.releng/repo.eclipse.org`

3. **Remove the flag** after successful update:

```json
{
  "id": "eclipse.platform.releng",
  "template": "maven2StandardWithStaging",
  "config": {
    "project_id": "eclipse.platform.releng"
  }
}
```

4. **Apply again** to persist the clean configuration:

```bash
make generate
make apply
```

#### Important Notes

- **Temporary Flag**: The `force_token_update` flag should only be present during the credential renewal operation
- **Automatic Cleanup**: Always remove the flag after credentials are successfully updated
- **Vault Integration**: New credentials are automatically stored in Vault
- **Secret Protection**: The `ignore_changes` lifecycle rule prevents accidental credential updates
- **Required for Username Changes**: Also use this flag when bot usernames change (e.g., after refactoring project structure)

#### Common Scenarios

**Scenario 1: Renew Bot Password**
```json
// Step 1: Add flag
{ "id": "myproject", "template": "maven2Standard", "force_token_update": true }
// Step 2: Apply → password regenerated
// Step 3: Remove flag
{ "id": "myproject", "template": "maven2Standard" }
// Step 4: Apply → configuration cleaned
```

**Scenario 2: Update Bot Username After Refactoring**

If bot userid changes (e.g., from `eclipse-platform-bot` to `eclipse-releng-bot`), the Vault secret must be updated:

```json
// Before: eclipse.platform with bot eclipse-platform-bot
// After: Renamed to eclipse.platform.releng, bot should be eclipse-releng-bot

// Step 1: Add force_token_update to trigger Vault secret update
{
  "id": "eclipse.platform.releng",
  "template": "maven2StandardWithStaging",
  "force_token_update": true
}

// Step 2: Apply → Vault secret updated with new username
// Step 3: Remove flag and apply again
```

The `force_token_update` flag bypasses Terraform's `ignore_changes` protection on the Vault secret, allowing the username and other fields to be updated.

#### Accessing Updated Credentials

After renewal, retrieve credentials from Vault:

```bash
# Using Vault CLI
vault kv get -mount="cbi" "eclipse.platform.releng/repo.eclipse.org"

# Or use the fetch script
./users/fetch_user_token.sh eclipse-releng-bot
```

---

## Troubleshooting

### Common Issues

#### 1. "Error: workspace doesn't exist"

**Cause**: Terraform workspace not initialized.

**Solution**:
```bash
# Set environment and use make
export NEXUS_ENV="prod"
make select

# Or manually with terraform
terraform workspace new prod
# or
terraform workspace select prod
```

#### 2. Permission Denied

**Cause**: Invalid Nexus or credentials.

**Solution**:
```bash
# Check environment variables
echo $VAULT_TOKEN
echo $NEXUS_URL

vaultctl status

# Re-source environment
. ./.env.sh
```

#### 3. State Lock Errors

**Cause**: Previous operation didn't complete properly.

**Solution**:
```bash

# Force unlock (last resort)
terraform force-unlock <lock-id>
```

#### 4. Jsonnet Compilation Errors

**Cause**: Syntax errors in `.jsonnet` file.

**Solution**:
```bash
# Test jsonnet compilation
jsonnet env/terraform.prod.tfvars.jsonnet

# Check for syntax errors
jsonnetfmt --test env/terraform.prod.tfvars.jsonnet
```

### Debugging Tips

#### Enable Verbose Logging

```bash
# Enable debug logging
export TF_LOG=DEBUG
make apply
```

#### Verify Resource Configuration

```bash
# Show specific resource (requires direct terraform command)
terraform state show 'nexus_repository_maven_hosted.maven-repositories["myproject-maven2-releases"]'

# List all resources
terraform state list

# Get outputs
make outputs
# Or in JSON format
make outputs-json
```
