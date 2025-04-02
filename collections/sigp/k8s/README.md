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

### admin

Kubernetes administration tasks including dashboard setup.

#### Dashboard Configuration

The dashboard task creates a service account with admin privileges for accessing the Kubernetes dashboard.

Available variables:
```yaml
# kubectl command to use (defaults to 'kubectl')
kubectl_command: "microk8s kubectl"
```

#### Example Playbook

```yaml
- hosts: localhost
  connection: local
  tasks:
    - include_role:
        name: sigp.k8s.admin
        tasks_from: dashboard
      vars:
        kubectl_command: "microk8s kubectl"
```

#### Usage

1. Include the dashboard task in your playbook
2. Set kubectl_command if using microk8s or custom kubectl
3. The dashboard token will be available as `dashboard_token` fact
4. For debugging, run with `-v` to see the token
#### Node Labeling

Applies standard and fact-based labels to Kubernetes nodes.

##### Configuration

```yaml
# Enable/disable node labeling
node_labeling_enabled: true

# Standard labels to apply
standard_labels:
  - "app.kubernetes.io/part-of=ethereum-blockbuilder"
  - "node-role.kubernetes.io/worker=true"

# Enable fact-based labeling
enable_fact_labels: true

# Hardware specs
hardware_specs:
  cpu: "unknown"
  memory: "unknown"
  storage: "unknown"

# Role-specific labels
node_label_dict: {}
```

##### Example Playbook

```yaml
- hosts: k8s_worker
  roles:
    - role: sigp.k8s.admin
      tasks_from: labeling
      vars:
        standard_labels:
          - "app.kubernetes.io/part-of=my-app"
          - "node-role.kubernetes.io/gpu=true"
        hardware_specs:
          cpu: "16"
          memory: "128gb"
```

##### Usage

1. Include the labeling task in your playbook
2. Configure labels through variables
3. Run against worker nodes to apply labels
4. Verify with `kubectl get nodes --show-labels`

