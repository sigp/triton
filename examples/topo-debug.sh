#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Minimum versions
MIN_KUBERNETES_VERSION="1.30.0"
MIN_LVM_VERSION="2.02.163"

# Check if command exists and get version
check_command() {
    local cmd=$1
    local version_flag=$2
    local version_pattern=$3
    
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} $cmd is not installed"
        return 1
    fi
    
    local version=$($cmd $version_flag 2>&1 | grep -oP "$version_pattern" | head -1)
    echo -e "${GREEN}[OK]${NC} $cmd version: $version"
    echo "$version"
}

# Compare version numbers
version_compare() {
    local version=$1
    local min_version=$2
    
    if [ "$(printf '%s\n' "$min_version" "$version" | sort -V | head -n1)" = "$min_version" ]; then
        return 0
    else
        return 1
    fi
}

# Check Kubernetes version
check_kubernetes() {
    echo -e "\n=== Checking Kubernetes ==="
    local kube_version=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion' | sed 's/^v//')
    
    echo -e "Detected version: ${YELLOW}$kube_version${NC}"
    echo -e "Required minimum: ${YELLOW}$MIN_KUBERNETES_VERSION${NC}"
    if version_compare "$kube_version" "$MIN_KUBERNETES_VERSION"; then
        echo -e "${GREEN}[OK]${NC} Kubernetes version meets minimum requirement"
    else
        echo -e "${RED}[ERROR]${NC} Kubernetes version is below minimum requirement"
    fi
}

# Check LVM tools
check_lvm() {
    echo -e "\n=== Checking LVM ==="
    local lvm_version=$(check_command lvm "--version" "(?<=LVM version: )[\d.]+")
    
    if [ -z "$lvm_version" ]; then
        return
    fi
    
    echo -e "Detected version: ${YELLOW}$lvm_version${NC}"
    echo -e "Required minimum: ${YELLOW}$MIN_LVM_VERSION${NC}"
    if version_compare "$lvm_version" "$MIN_LVM_VERSION"; then
        echo -e "${GREEN}[OK]${NC} LVM version meets minimum requirement"
    else
        echo -e "${RED}[ERROR]${NC} LVM version is below minimum requirement"
    fi
    
    # Check for JSON support
    if lvm -j &> /dev/null; then
        echo -e "${GREEN}[OK]${NC} LVM has JSON output support"
    else
        echo -e "${RED}[ERROR]${NC} LVM does not support JSON output (required)"
    fi
}

# Check kernel version
check_kernel() {
    echo -e "\n=== Checking Kernel ==="
    local kernel_version=$(uname -r | cut -d'-' -f1)
    local min_kernel="4.9.0"
    
    if version_compare "$kernel_version" "$min_kernel"; then
        echo -e "${GREEN}[OK]${NC} Kernel version $kernel_version meets minimum requirement ($min_kernel)"
    else
        echo -e "${RED}[ERROR]${NC} Kernel version $kernel_version is below minimum requirement ($min_kernel)"
    fi
}

# Main function
main() {
    echo "TopoLVM Debug Tool"
    echo "================="
    
    # Check dependencies
    check_command kubectl "version --client" "(?:Client Version: v|GitVersion:\"v)([0-9.]+)"
    check_command jq "--version" "(?<=jq-)[\d.]+"
    
    check_kubernetes
    check_lvm
    check_kernel
    
    echo -e "\n=== System Checks ==="
    check_command lvs "--version" "(?<=LVM version: )[\d.]+"
    check_command vgs "--version" "(?<=LVM version: )[\d.]+"
    check_command pvs "--version" "(?<=LVM version: )[\d.]+"
    
    echo -e "\nNote: Future versions will include container log collection"
}

main "$@"