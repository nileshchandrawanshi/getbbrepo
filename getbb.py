import requests

# Set your Bitbucket workspace and API token
workspace = 'your_workspace_id'  # Replace with your actual workspace ID
token = 'your_api_token'  # Replace with your actual API token

# Base URL for the Bitbucket API
base_url = f'https://api.bitbucket.org/2.0/repositories/{workspace}'

# Headers for authentication
headers = {
    'Authorization': f'Bearer {token}'
}

def get_repositories():
    repositories = []
    url = base_url
    while url:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            data = response.json()
            repositories.extend(data['values'])
            url = data.get('next')  # Handle pagination
        else:
            print(f"Failed to retrieve repositories: {response.status_code}")
            return []
    return repositories

def get_repository_variables(repo_slug):
    url = f'https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/pipelines_config/variables/'
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json().get('values', [])
    else:
        print(f"Failed to retrieve variables for {repo_slug}: {response.status_code}")
        return []

def main():
    repositories = get_repositories()
    if repositories:
        for repo in repositories:
            repo_slug = repo['slug']
            repo_name = repo['name']
            print(f"\nRepository: {repo_name} (Slug: {repo_slug})")
            
            # Retrieve variables for each repository
            variables = get_repository_variables(repo_slug)
            if variables:
                print("Variables:")
                for var in variables:
                    print(f"  - {var['key']}: {var['value']}")
            else:
                print("No variables found.")

if __name__ == "__main__":
    main()
