GITHUB_TOKEN=${1}
GITHUB_REPOSITORY=${2}

CONFIG_FILE=".github/pattern.json"
RESULTS=()
ALL_ARTIFACTS=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/artifacts")

for TEST_TYPE in $(jq -r 'keys[]' $CONFIG_FILE); do
  SCRIPTS=$(jq -r --arg test "$TEST_TYPE" '.[$test].scripts | @json' "$CONFIG_FILE")
  VAR=$(jq -c --arg test "$TEST_TYPE" '.[$test].var // {}' "$CONFIG_FILE")
  if [[ $(jq -r --arg test "$TEST_TYPE" '.[$test].scripts | keys_unsorted | .[0]' "$CONFIG_FILE") =~ /Projects\/(.*)\/Scripts/ ]]; then
    OUTPUT_DIR="Output/${BASH_REMATCH[1]}/${TEST_TYPE}"
  fi
  HASH=$(echo "$SCRIPTS" | jq -r 'keys_unsorted[]' | xargs -I {} find {} -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}')
  LAST_COMMIT=$(git rev-parse HEAD || git rev-parse origin/main)
  GENERAL_HASH=$(git ls-tree -r $LAST_COMMIT -- $GENERAL_PATHS | awk '{print $3}' | xargs -I {} git show {} | sha256sum | awk '{print $1}')

  ARTIFACT_NAME="${TEST_TYPE}-${HASH}-${GENERAL_HASH}"
  SHOULD_RUN=$(echo "$ALL_ARTIFACTS" | jq -e --arg name "$ARTIFACT_NAME" '.artifacts[] | select(.name == $name) | .id' > /dev/null && echo false || echo true)
  ENVS=$(jq -r --arg test "$TEST_TYPE" '.[$test].scripts | to_entries | map(if .value.db then .value.db[] else "mysql" end) | unique | join(",")' "$CONFIG_FILE")

  # Creation of the JSON result
  RESULT=$(jq -n \
  --arg test_type "$TEST_TYPE" \
  --arg scripts "$SCRIPTS" \
  --arg var "$VAR" \
  --arg output_dir "$OUTPUT_DIR" \
  --arg artifact_name "$ARTIFACT_NAME" \
  --arg should_run "$SHOULD_RUN" \
  --arg envs "$ENVS" \
  '{test_type: $test_type, scripts: $scripts, var: $var, output_dir: $output_dir, artifact_name: $artifact_name, should_run: $should_run, envs: $envs}')

  RESULTS+=("$RESULT")
done
CONFIGURATIONS=$(printf '%s\n' "${RESULTS[@]}" | jq -s '.' | jq -c .)
echo "configurations=$CONFIGURATIONS" >> $GITHUB_OUTPUT