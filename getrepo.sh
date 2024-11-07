#!/bin/bash

# Replace with your Bitbucket workspace ID and API token
WORKSPACE="your_workspace_id"  # e.g., 'myworkspace'
API_TOKEN="your_api_token"     # Replace with your actual API token

# Base URL for Bitbucket API
BASE_URL="https://api.bitbucket.org/2.0/repositories/${WORKSPACE}"

# Function to retrieve all repositories in the workspace
get_repositories() {
    curl -s -u "x-token-auth:${API_TOKEN}" "${BASE_URL}?pagelen=100" | jq -r '.values[] | .slug'
}

# Function to retrieve repository variables
get_repository_variables() {
    local repo_slug=$1
    curl -s -u "x-token-auth:${API_TOKEN}" "https://api.bitbucket.org/2.0/repositories/${WORKSPACE}/${repo_slug}/pipelines_config/variables/" | \
    jq -r '.values[] | "\(.key): \(.value)"'
}

# Main script
echo "Fetching repositories and their variables..."

# Fetch all repositories
repositories=$(get_repositories)

for repo in $repositories; do
    echo -e "\nRepository: $repo"
    echo "Variables:"
    
    # Fetch and print repository variables
    variables=$(get_repository_variables "$repo")
    if [ -z "$variables" ]; then
        echo "  No variables found."
    else
        echo "$variables" | while read -r variable; do
            echo "  - $variable"
        done
    fi
done
