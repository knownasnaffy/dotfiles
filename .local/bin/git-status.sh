#!/bin/bash

# Define the path to search for git repositories
SEARCH_PATH="$HOME/code"

# Colors for output formatting
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Scanning for git repositories in: $SEARCH_PATH"
echo ""

# Find all directories containing .git folders
git_repos=()
while IFS= read -r -d '' dir; do
    # Remove the /.git suffix to get the repository root
    repo_path="${dir%/.git}"
    git_repos+=("$repo_path")
done < <(find "$SEARCH_PATH" -name ".git" -type d -print0 2>/dev/null)

if [ ${#git_repos[@]} -eq 0 ]; then
    echo "No git repositories found in $SEARCH_PATH"
    exit 0
fi

echo "Found ${#git_repos[@]} git repositories"
echo ""

# Arrays to store repositories with different statuses
unstaged_repos=()
unpushed_repos=()
staged_repos=()

# Function to check git status
check_git_status() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")

    # Change to repository directory
    cd "$repo_path" || return 1

    # Get git status output
    status_output=$(git status 2>/dev/null)

    # Check for unstaged changes
    if echo "$status_output" | grep -q "Changes not staged for commit:"; then
        unstaged_repos+=("$repo_name")
        return
    fi

    # Check for staged changes (uncommitted)
    if echo "$status_output" | grep -q "Changes to be committed:"; then
        staged_repos+=("$repo_name")
        return
    fi

    # Check for unpushed changes
    if echo "$status_output" | grep -q "(use \"git push\" to publish your local commits)"; then
        unpushed_repos+=("$repo_name")
        return
    fi
}

# Check each repository
echo "Checking repository statuses..."
for repo in "${git_repos[@]}"; do
    if [ -d "$repo" ]; then
        check_git_status "$repo"
    fi
done

echo ""
echo "=== GIT REPOSITORY STATUS REPORT ==="

# Display results in table format (only if repos exist)
if [ ${#unstaged_repos[@]} -gt 0 ]; then
    echo ""
    printf "%-30s %-20s\n" "Repository" "Status"
    printf "%-30s %-20s\n" "----------" "------"
fi

# Show repositories with unstaged changes
for repo in "${unstaged_repos[@]}"; do
    printf "%-30s ${RED}%-20s${NC}\n" "$repo" "Unstaged Changes"
done

# Show repositories with staged but uncommitted changes
for repo in "${staged_repos[@]}"; do
    printf "%-30s ${YELLOW}%-20s${NC}\n" "$repo" "Staged Changes"
done

# Show repositories with unpushed commits
for repo in "${unpushed_repos[@]}"; do
    printf "%-30s ${YELLOW}%-20s${NC}\n" "$repo" "Unpushed Commits"
done

echo ""
echo "Summary:"
echo "- Repositories with unstaged changes: ${#unstaged_repos[@]}"
echo "- Repositories with staged changes: ${#staged_repos[@]}"
echo "- Repositories with unpushed commits: ${#unpushed_repos[@]}"

total_issues=$((${#unstaged_repos[@]} + ${#staged_repos[@]} + ${#unpushed_repos[@]}))
total_repos=${#git_repos[@]}
synced_repos=$((total_repos - total_issues))

echo "- Synced repositories: $synced_repos"
echo "- Total repositories: $total_repos"
