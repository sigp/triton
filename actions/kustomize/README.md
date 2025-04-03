# Kustomize Build Action

A composite GitHub Action that wraps the [kustomize-github-action](https://github.com/marketplace/actions/kustomize-github-action) with standardized configuration.

## Inputs

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `kustomize_version` | No | `3.0.0` | The Kustomize version to use |
| `kustomize_build_dir` | No | `.` | Directory containing kustomization.yaml |
| `kustomize_comment` | No | `false` | Whether to comment on GitHub PRs |
| `kustomize_output_file` | No | - | Path to write build output |
| `kustomize_build_options` | No | - | Additional build options |
| `enable_alpha_plugins` | No | `false` | Enable alpha plugins |
| `working_directory` | No | - | Directory to run command from |

## Outputs

| Parameter | Description |
|-----------|-------------|
| `kustomize_build_output` | The output from kustomize build |

## Example Usage

```yaml
- name: Run Kustomize Build
  uses: ./actions/kustomize
  with:
    kustomize_version: '3.0.0'
    kustomize_build_dir: 'overlays/production'
    kustomize_output_file: 'rendered.yaml'
    enable_alpha_plugins: true
```

## Notes

This action wraps the [karancode/kustomize-github-action](https://github.com/karancode/kustomize-github-action) to provide consistent version management and configuration across projects.