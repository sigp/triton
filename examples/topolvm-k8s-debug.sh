#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} kubectl not found in PATH"
        exit 1
    fi
    echo -e "${GREEN}[OK]${NC} kubectl is available"
}

# Check Kubernetes pod statuses
check_k8s_pods() {
    local namespace="topolvm-system"
    echo -e "\n=== Kubernetes Pod Status ==="
    echo -e "Checking pods in namespace: ${YELLOW}$namespace${NC}"
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}[WARN]${NC} jq not found - using basic pod status checks"
        kubectl get pods -n $namespace
        return
    fi

    # Get all pods in namespace with robust JSON handling
    local pod_json=$(kubectl get pods -n $namespace -o json 2>/dev/null)
    if [ -z "$pod_json" ]; then
        echo -e "${RED}[ERROR]${NC} Failed to get pod data from Kubernetes"
        return
    fi

    local pod_count=$(echo "$pod_json" | jq -r '.items | length')
    if [ "$pod_count" -eq 0 ]; then
        echo -e "${YELLOW}[WARN]${NC} No pods found in namespace $namespace"
        return
    fi

    # Process each pod
    for ((i=0; i<$pod_count; i++)); do
        local pod=$(echo "$pod_json" | jq -c ".items[$i]")
        local name=$(echo "$pod" | jq -r '.metadata.name')
        local status=$(echo "$pod" | jq -r '.status.phase')
        local containers=$(echo "$pod" | jq -r '.spec.containers | length')
        local ready=$(echo "$pod" | jq -r '.status.containerStatuses | map(.ready) | join("/")')
        
        echo -e "\nPod: ${YELLOW}$name${NC}"
        echo -e "Status: $status | Containers: $containers | Ready: $ready"
        
        # Check for ContainerCreating
        if [[ "$status" == "Pending" ]]; then
            echo -e "${YELLOW}[WARN]${NC} Pod is in Pending state"
            local events=$(kubectl get events -n $namespace --field-selector involvedObject.name=$name --sort-by=.metadata.creationTimestamp 2>/dev/null)
            if [ -n "$events" ]; then
                echo -e "Recent events:\n$events"
            fi
        fi
        
        # Check for CrashLoopBackOff
        if echo "$pod" | jq -e '.status.containerStatuses[] | select(.state.waiting.reason == "CrashLoopBackOff")' &>/dev/null; then
            echo -e "${RED}[ERROR]${NC} Pod has containers in CrashLoopBackOff"
            local problem_containers=$(echo "$pod" | jq -r '.status.containerStatuses[] | select(.state.waiting.reason == "CrashLoopBackOff") | .name')
            for container in $problem_containers; do
                echo -e "Checking logs for container: $container"
                kubectl logs -n $namespace $name -c $container --previous 2>/dev/null || \
                kubectl logs -n $namespace $name -c $container 2>/dev/null
            done
        fi
    done
}

# Main execution
check_kubectl
check_k8s_pods

echo -e "\nNote: For detailed debugging, use 'kubectl describe pod <name> -n topolvm-system'"