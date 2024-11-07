#!/bin/bash

# Set your API token, workspace, and project
API_TOKEN="your_app_password"
WORKSPACE="test-salma"
PROJECT_KEY="test-repo"
BASE_URL="https://api.bitbucket.org/2.0/repositories/${WORKSPACE}"

echo "Fetching repositories and their variables..."

# Function to get all repositories in the specified project
get_repositories() {
    local next_url="${BASE_URL}?q=project.key=\"${PROJECT_KEY}\"&pagelen=100"
    while [[ -n "$next_url" ]]; do
        response=$(curl -s -u "x-token-auth:${API_TOKEN}" "$next_url")
        
        # Check if the response contains an error message
        if echo "$response" | jq -e '.error' > /dev/null; then
            echo "Error in API response:"
            echo "$response" | jq '.error.message'
            exit 1
        fi

        # Loop through each repository in the response
        echo "$response" | jq -r '.values[] | .slug' | while read -r repo_slug; do
            echo "Repository: $repo_slug"
            get_repo_variables "$repo_slug"
            echo ""
        done

        # Get the next page URL, if it exists
        next_url=$(echo "$response" | jq -r '.next // empty')
    done
}

# Function to get repository variables for a specific repository
get_repo_variables() {
    local repo_slug=$1
    local variables_url="https://api.bitbucket.org/2.0/repositories/${WORKSPACE}/${repo_slug}/pipelines_config/variables/"
    variables_response=$(curl -s -u "x-token-auth:${API_TOKEN}" "$variables_url")
    
    echo "Variables:"
    if [[ $(echo "$variables_response" | jq '.values | length') -eq 0 ]]; then
        echo "  No variables found."
    else
        echo "$variables_response" | jq -r '.values[] | "  Name: \(.key), Value: \(.value)"'
    fi
}

# Call the function to get repositories and their variables
get_repositories
