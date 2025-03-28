# MicroK8s Ansible Collection

## Collection Structure

```
collections/sigp/microk8s/
├── docs/
├── galaxy.yml
├── meta/
├── plugins/
├── roles/
│   ├── install/
│   ├── configure/
│   ├── deploy/
│   └── reset/
└── README.md
```

## Roles and Tasks

### 1. install Role
- Install kubectl (latest stable version)
- Install Helm (via installation script)
- Install MicroK8s snap package
- Install required system packages (python3-pip, python3-kubernetes)
- Add user to microk8s group

### 2. configure Role
**Core Configuration:**
- Enable MicroK8s features (configurable list):
  - dns
  - storage (with configurable size)
  - dashboard
  - community addons
  - linkerd (optional)
  - argocd (optional)
- Configure git safe directory (workaround for known issue)
- Set up bash aliases (mk, mh)

**Node Management:**
- Add node to cluster:
  - Generate join command
  - Execute join command on new node
  - Verify node joined successfully
- Remove node from cluster:
  - Safely drain node
  - Remove node from cluster
  - Clean up node configuration
- Node status checks

### 3. deploy Role
- Create namespaces (configurable list)
- Deploy services (from templates)
- Create persistent volumes/claims
- Apply configuration:
  - ConfigMaps
  - Secrets
  - StatefulSets
  - Deployments

### 4. reset Role
- Full cluster reset
- Partial resets (by component)
- Cleanup verification

## Configuration Variables

```yaml
# Core configuration
microk8s_features:
  - dns
  - storage:size=40Gi
  - dashboard
microk8s_user: "{{ ansible_user }}"
microk8s_storage_class: "standard"

# Node management
microk8s_nodes:
  primary: "{{ groups['microk8s_primary'] | first }}"
  workers: "{{ groups['microk8s_workers'] | default([]) }}"

# Deployment configuration
microk8s_namespaces:
  - name: default
  - name: kube-system
microk8s_services: []
microk8s_volumes: []
```

## Usage Examples

### Basic Installation
```yaml
- hosts: k8s_servers
  roles:
    - role: sigp.microk8s.install
    - role: sigp.microk8s.configure
```

### Cluster Setup with Workers
```yaml
- hosts: primary
  roles:
    - role: sigp.microk8s.install
    - role: sigp.microk8s.configure

- hosts: workers
  roles:
    - role: sigp.microk8s.configure
      vars:
        microk8s_join_token: "{{ hostvars[groups.primary[0]].microk8s_join_token }}"
```

### Deployment Example
```yaml
- hosts: primary
  roles:
    - role: sigp.microk8s.deploy
      vars:
        microk8s_namespaces:
          - name: my-app
        microk8s_services:
          - name: app-service
            ports:
              - 8080
              - 9000
```

## Next Steps
1. Implement the basic role skeletons
2. Create default variables files
3. Implement core tasks
4. Add node management functionality
5. Write documentation and examples