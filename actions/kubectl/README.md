# Kubectl Composite Action

This action provides pre-configured kubectl commands with authentication setup.

## Usage

### Basic Example
```yaml
steps:
  - uses: actions/checkout@v3
  
  - name: Apply kustomize configuration
    uses: ./actions/kubectl
    with:
      working_directory: 'k8s/overlays/dev'
      command: 'kustomize'
      args: '--enable-helm | kubectl apply -f -'
      skip_tls_verify: 'true'
```

### Required Secrets
You must configure these secrets in your repository:
```yaml
env:
  KUBE_CERTIFICATE: ${{ secrets.KUBE_CERTIFICATE }}
  KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
  KUBE_HOST: ${{ secrets.KUBE_HOST }}
  KUBE_TOKEN: ${{ secrets.KUBE_TOKEN }}
```

### Full Example with Secrets
```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy application
        uses: ./actions/kubectl
        with:
          working_directory: 'k8s/overlays/prod'
          command: 'apply'
          args: '-f deployment.yaml'
        env:
          KUBE_CERTIFICATE: ${{ secrets.KUBE_CERTIFICATE }}
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
          KUBE_HOST: ${{ secrets.KUBE_HOST }}
          KUBE_TOKEN: ${{ secrets.KUBE_TOKEN }}
```

## Inputs
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| working_directory | No | '' | Directory to run command from |
| command | Yes | - | Main kubectl command (apply, delete, get, etc.) |
| args | No | '' | Additional command arguments |
| skip_tls_verify | No | 'false' | Skip TLS verification ('true'/'false') |