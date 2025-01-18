#!/bin/bash

# create file "gh-secrets.env" in the root directory of the repo with this content: GITHUB_TOKEN=your_personal_access_token
source ../../gh-secrets.env

chmod +x getArtifacts.sh
ARTIFACTS=$(./getArtifacts.sh)

PROCESSED_BASE_NAMES=""

# Sort artifacts by creation time in descending order and process them
echo "$ARTIFACTS" | jq -c '.artifacts | sort_by(.created_at) | reverse | .[]' | while read -r artifact; do
    ARTIFACT_ID=$(echo "$artifact" | jq -r '.id')
    ARTIFACT_NAME=$(echo "$artifact" | jq -r '.name')

    BASE_NAME=$(echo "$ARTIFACT_NAME" | sed -E 's/(-[0-9a-f]{64}){2}$//')

    # Check if the base name is already processed using `grep`
    if echo "$PROCESSED_BASE_NAMES" | grep -q "$BASE_NAME"; then
        echo "Deleting artifact: $ARTIFACT_NAME (ID: $ARTIFACT_ID)"
        DELETE_URL="https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID"
        curl -s -X DELETE -H "Authorization: Bearer $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github+json" \
            "$DELETE_URL"
    else
        PROCESSED_BASE_NAMES+="$BASE_NAME"
    fi
done