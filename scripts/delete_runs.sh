# GITHUB_TOKEN="your_token_here"
# OWNER="your_org_or_username"
# REPO="your_repo_name"
# WORKFLOW_ID="your_workflow_id"
# PER_PAGE=100

#!/bin/bash

# We don't need to define the variables at the top anymore! 
# Bash automatically inherits them from the GitHub Actions 'env:' block.

# It's good practice to set a default for variables not passed by the YAML
PER_PAGE=100

delete_runs() {
  PAGE=1
  while :; do
    echo "📦 Fetching runs from page ${PAGE}..."
    
    # Notice how we use ${GITHUB_TOKEN}, ${OWNER}, ${REPO}, and ${WORKFLOW_ID} directly
    RUNS=$(curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      "https://api.github.com/repos/fryctze/fryctze/actions/workflows/${WORKFLOW_ID}/runs?per_page=100&page=${PAGE}" \
    | jq -r '.workflow_runs[]?.id')

    if [[ -z "$RUNS" ]]; then
      echo "✅ No more runs to delete. Done."
      break
    fi

    for RUN_ID in $RUNS; do
      echo "🗑️ Deleting run ID: ${RUN_ID}"
      curl -s -X DELETE \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        "https://api.github.com/repos/${OWNER}/${REPO}/actions/runs/${RUN_ID}"
    done

    ((PAGE++))
    sleep 1
  done
}

# Run the function
delete_runs