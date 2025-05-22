#!/bin/bash

# Script to test TopoLVM with different lvmdEmbedded settings and capture debug output in GitHub gists

# Set inventory variable
inventory="blockprint"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: ansible-playbook is not installed. Please install Ansible first."
    exit 1
fi

# Array to store gist URLs
declare -a gist_urls

# Loop through lvmdEmbedded settings
for lvmd_setting in "true" "false"; do
    echo "Cleaning up previous TopoLVM installation..."
    # Get the first k8s master node from inventory
    master_node=$(ansible-inventory -i inv/$inventory-inventory.yml --list | jq -r '.k8s_master.hosts[0] as $h | ._meta.hostvars[$h].ansible_ssh_host')
    master_port=$(ansible-inventory -i inv/$inventory-inventory.yml --list | jq -r '.k8s_master.hosts[0] as $h | ._meta.hostvars[$h].ansible_port')
    if [ -z "$master_node" ]; then
        echo "Error: Could not determine master node from inventory"
        continue
    fi

    ssh ubuntu@$master_node -p $master_port "microk8s kubectl delete ns topolvm-system"

    echo "Testing with lvmdEmbedded=$lvmd_setting"
    
    # Run ansible-playbook with the current setting
    ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook examples/topolvm.yml -i "inv/${inventory}-inventory.yml" -e "lvmdEmbedded=$lvmd_setting"
    
    
    
    # SSH into master node and run debug script, capture output
    debug_output=$(ssh ubuntu@"$master_node" -p "$master_port" "/usr/local/bin/topolvm-k8s-debug.sh")
    
    # Create gist with meaningful name and description
    gist_url=$(gh gist create -p -d "[$inventory] TopoLVM v15.5.5 Debug Output (lvmdEmbedded=$lvmd_setting) v15.0.0" -f "topolvm-debug-lvmdEmbedded-$lvmd_setting.txt" <<< "$debug_output")
    
    if [ -z "$gist_url" ]; then
        echo "Error: Failed to create gist for lvmdEmbedded=$lvmd_setting"
        continue
    fi
    
    echo "Created gist for lvmdEmbedded=$lvmd_setting: $gist_url"
    gist_urls+=("$gist_url")
done

# Print all gist URLs
echo -e "\nGist URLs created:"
for url in "${gist_urls[@]}"; do
    echo "$url"
done