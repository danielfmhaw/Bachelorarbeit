#!/bin/bash

# create file "pac_gh.env" in this directory with this content: GITHUB_TOKEN=your_personal_access_token
source ../../pac_gh.env

chmod +x getArtifacts.sh
ARTIFACTS=$(./getArtifacts.sh)

NOW=$(date +%s)

# Iterate through each artifact
echo "$ARTIFACTS" | jq -c '.artifacts[]' | while read -r artifact; do
    ARTIFACT_ID=$(echo "$artifact" | jq -r '.id')
    ARTIFACT_NAME=$(echo "$artifact" | jq -r '.name')
    CREATED_AT=$(echo "$artifact" | jq -r '.created_at')

    CREATED_AT_TS=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED_AT" +%s)

    AGE=$(( (NOW - CREATED_AT_TS) / 86400 ))

    if [ "$AGE" -gt 3 ]; then
        DELETE_URL="https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID"
        echo "Deleting artifact: $ARTIFACT_NAME (ID: $ARTIFACT_ID, Age: $AGE days)"
        curl -s -X DELETE -H "Authorization: Bearer $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github+json" \
            $DELETE_URL
    fi
done
