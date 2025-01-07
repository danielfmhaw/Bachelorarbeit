#!/bin/bash
source pac_gh.env

LIST_URL="https://api.github.com/repos/$OWNER/$REPO/actions/artifacts"
ALL_ARTIFACTS=()
PAGE=1

TOTAL_COUNT=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" "$LIST_URL?page=1" | jq '.total_count')

while :; do
    RESPONSE=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" "$LIST_URL?page=$PAGE")
    ARTIFACTS=$(echo "$RESPONSE" | jq '.artifacts')
    ALL_ARTIFACTS=$(echo "$ALL_ARTIFACTS $ARTIFACTS" | jq -s add)

    if [ $(echo "$ARTIFACTS" | jq length) -lt 30 ]; then break; fi
    PAGE=$((PAGE + 1))
done

OUTPUT=$(jq -n --arg total_count "$TOTAL_COUNT" --argjson artifacts "$ALL_ARTIFACTS" '{total_count: ($total_count | tonumber), artifacts: $artifacts}')
echo "$OUTPUT"
