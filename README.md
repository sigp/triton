# SIGP Triton Repository

This repository contains reusable infrastructure automation components including Ansible collections and GitHub workflows.

## Ansible Collections

The repository hosts the `sigp.microk8s` Ansible collection which provides roles for managing MicroK8s clusters:

- `install`: Installs MicroK8s with configurable options
- `configure`: Configures MicroK8s with addons and settings
- `deploy`: Deploys applications to the MicroK8s cluster
- `reset`: Resets the MicroK8s cluster to a clean state

## GitHub Workflows

Reusable GitHub workflows for Kubernetes operations:

- `kubectl.yml`: Workflow for running kubectl commands in CI/CD pipelines

## Usage

To use the Ansible collection:
```bash
ansible-galaxy collection install git+https://github.com/sigp/triton.git
```

To reference the GitHub workflows in your repository:
```yaml
uses: sigp/triton/workflows/k8s/kubectl.yml@main