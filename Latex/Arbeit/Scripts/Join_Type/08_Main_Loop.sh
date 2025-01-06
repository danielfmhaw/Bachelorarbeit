# Main benchmark loop
for INFO in "${QUERY_INFO[@]}"; do
  IFS=: read -r QUERY_PATH MULTIPLE_KEYS <<< "$INFO"

  MAIN_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH").lua"
  INSERT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_insert.lua"
  SELECT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_select"
  LOG_DIR="$OUTPUT_DIR/logs/$(basename "$QUERY_PATH")"

  if [[ -n "$MULTIPLE_KEYS" ]]; then
    IFS=',' read -r -a KEYS <<< "$MULTIPLE_KEYS"

    combinations=$(generate_combinations "" "${KEYS[@]}")

    # Process each combination
    while IFS=',' read -r combination; do
        # Export key-value pairs for the current combination
        IFS=',' read -ra key_value_pairs <<< "$combination"
        for pair in "${key_value_pairs[@]}"; do
            key="${pair%%=*}"
            value="${pair#*=}"
            export "$(echo "$key" | tr '[:lower:]' '[:upper:]')=$value"
        done

        COMBINATION_NAME=$(echo "$combination" | tr ',' '_' | tr '=' '_')
        LOG_DIR_KEY_VALUE="$LOG_DIR/$COMBINATION_NAME"
        mkdir -p "$LOG_DIR_KEY_VALUE"

        RAW_RESULTS_FILE="${LOG_DIR_KEY_VALUE}/$(basename "$QUERY_PATH")_${COMBINATION_NAME}_prepare.log"
        run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE" "" "$COMBINATION_NAME"

        process_script_benchmark "$QUERY_PATH" "$LOG_DIR_KEY_VALUE" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$COMBINATION_NAME"

        RAW_RESULTS_FILE="${LOG_DIR_KEY_VALUE}/$(basename "$QUERY_PATH")_${COMBINATION_NAME}_cleanup.log"
        run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
    done <<< "$combinations"
  else
    # Process normally when no keys specified
    mkdir -p "$LOG_DIR"
    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_prepare.log"
    run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE"

    process_script_benchmark "$QUERY_PATH" "$LOG_DIR" "$INSERT_SCRIPT" "$SELECT_SCRIPT"

    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_cleanup.log"
    run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
  fi
done