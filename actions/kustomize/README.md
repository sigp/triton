# Kubernetes Kustomize Deployment Action

A composite GitHub Action for deploying applications using Kustomize with Helm support.

## Inputs

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `environment` | Yes | - | Deployment environment (dev/prod) |
| `app` | Yes | - | Application name to deploy |
| `protocol` | No | `https` | Preferred connection protocol (https/http) |
| `skip_tls_verify` | No | `false` | Skip TLS verification (true/false) |

## Example Usage

```yaml
- name: Deploy with Kustomize+Helm
  uses: sigp/triton/actions/kustomize@main
  with:
    environment: 'prod'
    app: 'lynx'
    protocol: 'https'
    skip_tls_verify: 'false'
  env:
    KUBE_HOST: ${{ secrets.KUBE_HOST }}
    KUBE_CERTIFICATE: ${{ secrets.KUBE_CERTIFICATE }}
    KUBE_TOKEN: ${{ secrets.KUBE_TOKEN }}
```

## Notes

This action performs the following steps:
1. Configures kubectl with the provided credentials
2. Validates Kustomize manifests with Helm support
3. Deploys the application using `kubectl apply`
4. Verifies the deployment status

Required environment secrets:
- `KUBE_HOST`: Kubernetes API server host
- `KUBE_CERTIFICATE`: Base64 encoded cluster CA certificate
- `KUBE_TOKEN`: Service account token for authentication