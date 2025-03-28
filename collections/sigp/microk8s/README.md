# Ansible Collection - sigp.microk8s

An Ansible collection for installing, configuring, and managing MicroK8s Kubernetes clusters.

## Table of Contents
- [Roles](#roles)
- [Installation](#installation)
- [Variables](#variables)
- [Usage Examples](#usage-examples)
- [Tags](#tags)

## Roles

### install
Installs MicroK8s and required dependencies (kubectl, helm).

### configure
Configures MicroK8s with specified features and settings.

### deploy
Deploys applications and services to the MicroK8s cluster.

### reset
Resets the MicroK8s cluster (full or partial reset).

## Variables

### install Role Variables
```yaml
# User configuration
microk8s_user: "{{ ansible_user }}"

# Kubectl configuration
kubectl_install_path: /usr/local/bin/kubectl
kubectl_version_url: https://dl.k8s.io/release/stable.txt

# Helm configuration
helm_install_script_url: https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
helm_install_path: /usr/local/bin/helm

# System packages
system_packages:
  - python3-pip
  - python3-kubernetes

# MicroK8s snap configuration
microk8s_snap_channel: stable
microk8s_snap_classic: true
```

### configure Role Variables
```yaml
# Features to enable
microk8s_features:
  - dns
  - storage:size=40Gi
  - dashboard
  - community

# Node management
microk8s_primary: "{{ groups['microk8s_primary'] | first }}"
microk8s_workers: "{{ groups['microk8s_workers'] | default([]) }}"

# Storage configuration
microk8s_storage_size: 40Gi
microk8s_storage_class: standard

# Additional features
microk8s_enable_argocd: false
microk8s_enable_linkerd: false
```

### deploy Role Variables
```yaml
# Namespaces to create
microk8s_namespaces:
  - name: default
  - name: kube-system

# Services to deploy
microk8s_services: []

# Persistent volume claims
microk8s_pvcs: []

# Templates to apply
microk8s_templates: []

# Resource requests
microk8s_default_cpu_request: "100m"
microk8s_default_memory_request: "128Mi"
```

### reset Role Variables
```yaml
# Reset type (full or partial)
microk8s_reset_type: "full"

# Namespaces to remove (for partial reset)
microk8s_namespaces_to_remove: []

# Skip confirmation prompt
microk8s_skip_reset_confirmation: false
```

## Usage Examples

### Install MicroK8s
```yaml
- hosts: k8s_nodes
  roles:
    - role: sigp.microk8s.install
```

### Configure MicroK8s
```yaml
- hosts: k8s_nodes
  roles:
    - role: sigp.microk8s.configure
      vars:
        microk8s_features:
          - dns
          - storage:size=100Gi
          - ingress
```

### Deploy Applications
```yaml
- hosts: k8s_nodes
  roles:
    - role: sigp.microk8s.deploy
      vars:
        microk8s_services:
          - name: nginx
            namespace: default
            image: nginx:latest
            ports:
              - containerPort: 80
```

### Reset Cluster
```yaml
- hosts: k8s_nodes
  roles:
    - role: sigp.microk8s.reset
      vars:
        microk8s_reset_type: "full"
        microk8s_skip_reset_confirmation: true
```

## Tags

- `install`: Run only install tasks
- `configure`: Run only configure tasks
- `deploy`: Run only deploy tasks
- `reset`: Run only reset tasks
- `kubectl`: Tasks related to kubectl installation
- `helm`: Tasks related to helm installation
- `features`: Tasks related to MicroK8s feature configuration
