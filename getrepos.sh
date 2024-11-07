#!/bin/bash

USERNAME="your_username"
APP_PASSWORD="your_app_password"
WORKSPACE="your_workspace" # Replace with your Bitbucket workspace ID
BASE_URL="https://api.bitbucket.org/2.0/repositories/${WORKSPACE}"

echo "Fetching repositories and their variables..."

get_repositories() {
    # Fetch all repositories under the workspace
    next_url="${BASE_URL}?pagelen=100"
    while [[ -n "$next_url" ]]; do
        response=$(curl -s -u "${USERNAME}:${APP_PASSWORD}" "$next_url")

        # Debugging output to inspect the response
        echo "API Response:"
        echo "$response"

        # Check if the response has an error
        if echo "$response" | jq -e '.error' > /dev/null; then
            echo "Error in API response:"
            echo "$response" | jq '.error.message'
            exit 1
        fi

        # List repository slugs and fetch their variables
        echo "$response" | jq -r '.values[] | .slug' | while read -r repo_slug; do
            echo "Repository: $repo_slug"
            get_repo_variables "$repo_slug"
            echo ""
        done

        # Check for pagination
        next_url=$(echo "$response" | jq -r '.next // empty')
    done
}

get_repo_variables() {
    local repo_slug=$1
    variables_url="https://api.bitbucket.org/2.0/repositories/${WORKSPACE}/${repo_slug}/pipelines_config/variables/"
    
    # Fetch repository variables
    variables_response=$(curl -s -u "${USERNAME}:${APP_PASSWORD}" "$variables_url")
    
    echo "Variables:"
    if [[ $(echo "$variables_response" | jq '.values | length') -eq 0 ]]; then
        echo "  No variables found."
    else
        echo "$variables_response" | jq -r '.values[] | "  Name: \(.key), Value: \(.value)"'
    fi
}

get_repositories
