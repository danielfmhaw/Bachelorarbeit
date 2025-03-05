for SCRIPT_PATH in $SCRIPT_DIRS; do
  DBMS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].db // ["mysql"]')
  SELECT_QUERIES=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].selects')
  for DB in $(echo "$DBMS" | jq -r '.[]'); do
    prepare_variables "$SCRIPT_PATH" "$DB"
    DB_INFO="$( [ "$DBMS_COUNT" -ne 1 ] && echo "${DB}" )"
    if [[ -n "$EXPORTED_VARS" ]]; then
        IFS=',' read -r -a KEYS <<< "$EXPORTED_VARS"

        COMBINATIONS=$(generate_combinations "" "${KEYS[@]}")
        while IFS=',' read -r combination; do
            # Export key-value pairs for the current combination
            IFS=',' read -ra key_value_pairs <<< "$combination"
            for pair in "${key_value_pairs[@]}"; do
              export "$(echo "${pair%%=*}" | tr '[:lower:]' '[:upper:]')=${pair#*=}"
            done
            COMBINATION_NAME=$(echo "$combination" | sed -E 's/(^|,)num_rows=[^,]*//g;s/^,//;s/,$//' | tr ',' '_' | tr '=' '_')
            LOG_DIR_COMBINATION="$LOG_DIR/$COMBINATION_NAME"
            process_script_benchmark "$DB_INFO" "$SCRIPT_PATH" "$LOG_DIR_COMBINATION" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$COMBINATION_NAME"
        done <<< "$COMBINATIONS"
    else
      process_script_benchmark "$DB_INFO" "$SCRIPT_PATH" "$LOG_DIR" "$INSERT_SCRIPT" "$SELECT_SCRIPT"
    fi
    eval $(jq -r --arg env "$DB" '.[$env] | to_entries | .[] | "unset " + .key' "$ABS_PATH/envs.json")
  done
done
# Combine csv files during runtime and end statistics and generate plots
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$STATISTICS_FILE_TEMP" "$STATISTICS_FILE" --select_columns "$STATS_SELECT_COLUMNS" --insert_columns "$STATS_INSERT_COLUMNS" --prefixes "$PREFIXES"
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$RUNTIME_FILE_TEMP" "$RUNTIME_FILE" --select_columns "$RUNTIME_SELECT_COLUMNS" --insert_columns "$RUNTIME_INSERT_COLUMNS" --prefixes "$PREFIXES"
python3 "$PYTHON_PATH/generatePlot.py" "$RUNTIME_FILE" "$STATISTICS_FILE"