#!/bin/bash

# create file "gh-secrets.env" in the root directory of the repo with this content: GITHUB_TOKEN=your_personal_access_token
source ../../gh-secrets.env

chmod +x getArtifacts.sh
ARTIFACTS=$(./getArtifacts.sh)

echo "$ARTIFACTS" | jq -c '.artifacts | .[]' | while read -r artifact; do
    ARTIFACT_ID=$(echo "$artifact" | jq -r '.id')
    ARTIFACT_NAME=$(echo "$artifact" | jq -r '.name')

    echo "Deleting artifact: $ARTIFACT_NAME (ID: $ARTIFACT_ID)"
    DELETE_URL="https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID"
    curl -s -X DELETE -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "$DELETE_URL"
done