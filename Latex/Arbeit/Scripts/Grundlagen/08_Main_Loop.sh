# Main benchmark loop
for INFO in "${QUERY_INFO[@]}"; do
  # Definition of the variables comes here

  if [[ -n "$EXPORTED_VARS" ]]; then
    IFS=';' read -r -a KEYS <<< "$EXPORTED_VARS"
    combinations=$(generate_combinations "" "${KEYS[@]}")
    # Process each combination
    while IFS=',' read -r combination; do
        IFS=',' read -ra key_value_pairs <<< "$combination"
        for pair in "${key_value_pairs[@]}"; do
          export "$(echo "${pair%%=*}" | tr '[:lower:]' '[:upper:]')=${pair#*=}"
        done
        COMBINATION_NAME=$(echo "$combination" | sed -E 's/(^|,)num_rows=[^,]*//g;s/^,//;s/,$//' | tr ',' '_' | tr '=' '_')
        LOG_DIR_KEY_VALUE="$LOG_DIR/$COMBINATION_NAME"
        mkdir -p "$LOG_DIR_KEY_VALUE"

        process_script_benchmark "$QUERY_PATH" "$LOG_DIR_KEY_VALUE" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$COMBINATION_NAME"
    done <<< "$combinations"
  else
    # Process normally when no keys specified
    mkdir -p "$LOG_DIR"
    process_script_benchmark "$QUERY_PATH" "$LOG_DIR" "$INSERT_SCRIPT" "$SELECT_SCRIPT"
  fi
done