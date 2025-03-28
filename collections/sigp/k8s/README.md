# Ansible Collection - sigp.k8s

A collection of Kubernetes administration roles and playbooks.

## Roles

### github-actions

Configures Kubernetes permissions for GitHub Actions workflows.

#### Configuration

All configuration is done through variables in `defaults/main.yml`:

```yaml
# Namespace configuration
github_actions_namespace: github-actions
github_actions_service_account: github-actions-sa

# Role configuration
github_actions_role_name: pod-reader
github_actions_role_binding_name: github-actions-pod-reader

# Target namespaces for RoleBindings
github_actions_target_namespaces:
  - default
  - lynx
  - rbuilder

# ClusterRoleBinding configuration
github_actions_cluster_role_binding_name: github-actions-cluster-admin
github_actions_cluster_role_name: cluster-admin
github_actions_enable_cluster_admin: false
```

#### Example Playbook

```yaml
- hosts: localhost
  connection: local
  roles:
    - role: sigp.k8s.github-actions
      vars:
        github_actions_namespace: my-github-actions
        github_actions_service_account: my-sa
        github_actions_target_namespaces:
          - default
          - staging
          - production
        github_actions_enable_cluster_admin: true
```

#### Usage

1. Include the role in your playbook
2. Override any default variables as needed
3. Run the playbook against your Kubernetes cluster
