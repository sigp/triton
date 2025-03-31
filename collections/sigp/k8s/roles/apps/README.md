# Apps Role

Manages Kubernetes applications via Helm charts with support for multiple Ethereum clients.

## Supported Applications

### Lighthouse (Ethereum Consensus Client)
An Ethereum 2.0 client written in Rust.

#### Variables
- `lighthouse_enabled`: Enable deployment (default: false)
- `lighthouse_mode`: Operation mode (beacon/validator/bootnode)
- `lighthouse_network`: Ethereum network
- `lighthouse_replicas`: Number of replicas
- `lighthouse_persistence_*`: Storage configuration
- `lighthouse_jwt_secret`: JWT secret for execution layer auth

### Reth (Ethereum Execution Client)  
A high-performance Ethereum execution client written in Rust.

#### Variables
- `reth_enabled`: Enable deployment (default: false)  
- `reth_network`: Ethereum network  
- `reth_replicas`: Number of replicas  
- `reth_persistence_*`: Storage configuration  
- `reth_jwt_secret`: JWT secret for consensus layer auth  
- `reth_*_port`: Service port configurations  

## Usage

1. Enable apps in `vars/main.yml`:
```yaml
apps_enabled: ["lighthouse", "reth"]
```

2. Install selected apps:
```bash
ansible-playbook playbook.yml --tags install
```

3. Upgrade selected apps:  
```bash
ansible-playbook playbook.yml --tags upgrade  
```

4. Uninstall selected apps:
```bash
ansible-playbook playbook.yml --tags uninstall
```

## Example Configuration

```yaml
- hosts: localhost
  roles:
    - role: sigp.k8s.apps
      vars:
        apps_enabled: ["lighthouse", "reth"]
        apps_namespace: "ethereum"
        
        # Lighthouse config
        lighthouse_mode: "beacon"
        lighthouse_network: "mainnet"
        lighthouse_persistence_size: "100Gi"
        
        # Reth config
        reth_network: "mainnet" 
        reth_persistence_size: "500Gi"
        reth_extra_args:
          - "--chain=mainnet"
          - "--sync=full"
```