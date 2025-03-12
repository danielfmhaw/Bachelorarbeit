which bash

if [ -n "$GITHUB_ACTIONS" ]; then
    ABS_PATH="."
else
    ABS_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Repo"
fi
source ${ABS_PATH}/Tools/Shell-Scripts/helper_functions.sh

parse_arguments "$@"
initialize_variables "$OUTPUT_DIR" "$ABS_PATH" "$TIME" "$THREADS" "$EVENTS" "$REPORT_INTERVAL"

process_script_benchmark() {
  local DB_INFO="$1" SCRIPT_PATH="$2" LOG_DIR="$3" INSERT_SCRIPT="$4" SELECT_SCRIPT="$5" COMBINATION="$6"
  local SCRIPTS=()
  local IS_FROM_SELECT_DIR=false
  mkdir -p "$LOG_DIR"

  if [ -f "$SELECT_SCRIPT.lua" ]; then
    # SELECT_SCRIPT is a Lua file
    SCRIPTS=("$INSERT_SCRIPT" "$SELECT_SCRIPT.lua")
  else
    # SELECT_SCRIPT is a directory
    SCRIPTS=("$INSERT_SCRIPT" "$SELECT_SCRIPT"/*)
    IS_FROM_SELECT_DIR=true
  fi

  # Prepare benchmark
  PREPARE_LOG_FILE="$LOG_DIR/$(basename "$SCRIPT_PATH")${COMBINATION:+_${COMBINATION}}_prepare.log"
  run_benchmark "$MAIN_SCRIPT" "prepare" "$PREPARE_LOG_FILE" "" "${COMBINATION:-}"

  # Select and Insert benchmark
  for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
      generate_script_name "$SCRIPT" "$DB_INFO" "$COMBINATION" "$SCRIPT_PATH" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$IS_FROM_SELECT_DIR"
      local RAW_RESULTS_FILE="$LOG_DIR/${SCRIPT_NAME}.log"

      # Call run_benchmark if SELECT_QUERIES is empty or the script is part of SELECT_QUERIES
      if ! $IS_SELECT || [ "$SELECT_QUERIES" == "null" ] || echo "$SELECT_QUERIES" | grep -qw "${BASE_NAME%.lua}"; then
          run_benchmark "$SCRIPT" "run" "$RAW_RESULTS_FILE" "$SCRIPT_NAME" "$COMBINATION"
      fi
    fi
  done

  #Cleanup benchmark
  run_benchmark "$MAIN_SCRIPT" "cleanup" "$LOG_DIR/$(basename "$SCRIPT_PATH")${COMBINATION:+_${COMBINATION}}_cleanup.log"
}

run_benchmark() {
  local SCRIPT_PATH="$1" MODE="$2" OUTPUT_FILE="$3" SCRIPT_NAME="${4:-}" COMBINATION="${5:-}"

  if [[ -n "$SCRIPT_NAME" && ( -z "$DB_PORTS" || ( "$IS_SELECT" == "false" && -n "$DB_PORTS" ) ) ]]; then
    echo "Running $(basename "$SCRIPT_PATH") for $TIME seconds ..."
  fi
  if [[ "$MODE" == "prepare" ]]; then
    echo "Preparing database for $(basename "$SCRIPT_PATH")${COMBINATION:+ with $COMBINATION}${DB_INFO:+ and database $DB}"
  fi
  [[ "$MODE" == "cleanup" ]] && echo -e "Cleaning up database for $(basename "$SCRIPT_PATH")\n"

  if [[ "$SCRIPT_PATH" == *select* && -n $SEL_THR ]]; then
     local CUSTOM_THREADS=$((SEL_THR / $(echo ${DB_PORTS:-0} | wc -w)))
     CUSTOM_THREADS=${CUSTOM_THREADS:-$SEL_THR}
  else
     local CUSTOM_THREADS="$THREADS"
  fi

  # Check if mode is run, script contains '_select' and DB_PORTS is set
  if [[ "$MODE" == "run" && $(basename "$SCRIPT_PATH") == *_select* && -n "$DB_PORTS" ]]; then
    run_sysbench_for_each_port "$DB_PORTS" "$SCRIPT_PATH" "$SCRIPT_NAME" "$MODE" "$CUSTOM_THREADS"
  else
    run_sysbench "$SCRIPT_PATH" "$MODE" "$OUTPUT_FILE" "$DB_PORT" "$CUSTOM_THREADS" || { echo "Benchmark failed for script $SCRIPT_PATH"; exit 1; }

    if [ "$MODE" == "run" ]; then
      extract_run_data "$OUTPUT_FILE" "$SCRIPT_NAME"
      extract_statistics "$OUTPUT_FILE" "$SCRIPT_NAME"
    fi
  fi
}

# Get number of DBMS used in all scripts
DBMS_SET=()
for SCRIPT_PATH in $SCRIPT_DIRS; do
  for db in $(jq -r --arg key "$SCRIPT_PATH" '.[$key].db // ["mysql"] | .[]' <<< "$SCRIPTS"); do
    [[ ! " ${DBMS_SET[*]} " =~ (^|[[:space:]])$db($|[[:space:]]) ]] && DBMS_SET+=("$db")
  done
done
DBMS_COUNT=${#DBMS_SET[@]}

# Main benchmark loop
for SCRIPT_PATH in $SCRIPT_DIRS; do
  DBMS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].db // ["mysql"]')
  SELECT_QUERIES=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].selects')
  for DB in $(echo "$DBMS" | jq -r '.[]'); do
    prepare_variables "$SCRIPT_PATH" "$DB"
    DB_INFO="$( [ "$DBMS_COUNT" -ne 1 ] && echo "${CUSTOM_DB_NAME}" )"
    if [[ -n "$EXPORTED_VARS" ]]; then
      IFS=',' read -r -a KEYS <<< "$EXPORTED_VARS"

      # Process each combination
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
    # shellcheck disable=SC2046
    eval $(jq -r --arg env "$DB" '.[$env] | to_entries | .[] | "unset " + .key' "$ABS_PATH/envs.json")
  done
done

# Extracting the count value from logs
${ABS_PATH}/Tools/Shell-Scripts/extract_count_from_logs.sh "$OUTPUT_DIR"

# Statistics csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$STATISTICS_FILE_TEMP" "$STATISTICS_FILE" --select_columns "$STATS_SELECT_COLUMNS" --insert_columns "$STATS_INSERT_COLUMNS" --prefixes "$PREFIXES"
echo "Combined CSV file created at $STATISTICS_FILE"

# Outputfile csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$RUNTIME_FILE_TEMP" "$RUNTIME_FILE" --select_columns "$RUNTIME_SELECT_COLUMNS" --insert_columns "$RUNTIME_INSERT_COLUMNS" --prefixes "$PREFIXES"
echo "Combined CSV file created at $RUNTIME_FILE"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$PYTHON_PATH/generatePlot.py" "$RUNTIME_FILE" "$STATISTICS_FILE"