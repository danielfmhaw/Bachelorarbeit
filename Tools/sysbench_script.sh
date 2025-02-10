which bash

if [ -n "$GITHUB_ACTIONS" ]; then
    ABS_PATH="."
else
    ABS_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Repo"
fi
PYTHON_PATH="${ABS_PATH}/Tools/Python"

# Display usage instructions
usage() {
    echo "Usage: $0 -out <output_dir> [-var <json_variables>] -scripts:<query_info1> <query_info2> ..."
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -out) OUTPUT_DIR="$2"; shift 2 ;;
    -var) JSON_VARIABLES="$2"; shift 2 ;;
    -scripts)
        SCRIPTS=$(echo "$2" | tr -d '\n' | sed 's/[[:space:]]*{/{/g' | sed 's/}[[:space:]]*/}/g' | sed 's/: /:/g' | sed 's/, /,/g')
        SCRIPT_KEYS=$(echo "$SCRIPTS" | jq -r 'keys[]')
        shift 2
        ;;
    *) usage ;;
  esac
done

# Validate required arguments
if [ -z "$OUTPUT_DIR" ] || [ "${#SCRIPTS[@]}" -eq 0 ]; then
    usage
fi

for SCRIPT_KEY in $SCRIPT_KEYS; do
    VARS_VALUE=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_KEY" '.[$key].vars // ""')
    if [[ -n "$VARS_VALUE" ]]; then
        IFS=',' read -ra VARS_LIST <<< "$VARS_VALUE"
        for VAR in "${VARS_LIST[@]}"; do
            if ! echo "$JSON_VARIABLES" | jq -e ".\"$VAR\"" >/dev/null 2>&1; then
                echo "Error: The variable '$VAR' in query '$SCRIPT_KEY' is not defined in JSON_VARIABLES"
            fi
        done
    fi
done

# Define file paths
RUNTIME_FILE="$OUTPUT_DIR/sysbench_runtime.csv"
RUNTIME_FILE_TEMP="$OUTPUT_DIR/sysbench_runtime_temp.csv"
STATISTICS_FILE="$OUTPUT_DIR/sysbench_statistics.csv"
STATISTICS_FILE_TEMP="$OUTPUT_DIR/sysbench_statistics_temp.csv"

# Default values for select_columns and insert_columns
STATS_SELECT_COLUMNS_DEFAULT="Total Time"
STATS_INSERT_COLUMNS_DEFAULT=""
RUNTIME_SELECT_COLUMNS_DEFAULT="Time (s);Threads"
RUNTIME_INSERT_COLUMNS_DEFAULT=""

# Sysbench configuration
TIME=${TIME:-8}
THREADS=${THREADS:-1}
EVENTS=${EVENTS:-0}
REPORT_INTERVAL=${REPORT_INTERVAL:-1}

# Ensure output directories exist
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Prepare CSV headers
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$RUNTIME_FILE_TEMP"
echo "Script,Read (noq),Write (noq),Other (noq),Total (noq),Transactions (per s.),Queries (per s.),Ignored Errors (per s.),Reconnects (per s.),Total Time (s),Total Events,Latency Min (ms),Latency Avg (ms),Latency Max (ms),Latency 95th Percentile (ms),Latency Sum (ms)" > "$STATISTICS_FILE_TEMP"

process_script_benchmark() {
  local SCRIPT_PATH="$1" LOG_DIR="$2" INSERT_SCRIPT="$3" SELECT_SCRIPT="$4" COMBINATION="$5"
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
      local SCRIPT_NAME
      if [ -n "$COMBINATION" ]; then
        if $IS_FROM_SELECT_DIR && [[ "$SCRIPT" == "$SELECT_SCRIPT"/* ]]; then
          SCRIPT_NAME="${SCRIPT_PATH##*/}_comb_${COMBINATION}_select_$(basename "$SCRIPT" .lua)"
        else
          SCRIPT_NAME="${SCRIPT_PATH##*/}_comb_${COMBINATION}_$(basename "$SCRIPT" .lua | sed "s/^${SCRIPT_PATH##*/}_//")"
        fi
      else
        if $IS_FROM_SELECT_DIR && [[ "$SCRIPT" == "$SELECT_SCRIPT"/* ]]; then
          SCRIPT_NAME="$(basename "$SELECT_SCRIPT")_$(basename "$SCRIPT" .lua)"
        else
          SCRIPT_NAME=$(basename "$SCRIPT" .lua)
        fi
      fi
      local RAW_RESULTS_FILE="$LOG_DIR/${SCRIPT_NAME}.log"
      run_benchmark "$SCRIPT" "run" "$RAW_RESULTS_FILE" "$SCRIPT_NAME" "$COMBINATION"
    fi
  done

  #Cleanup benchmark
  run_benchmark "$MAIN_SCRIPT" "cleanup" "$LOG_DIR/$(basename "$SCRIPT_PATH")${COMBINATION:+_${COMBINATION}}_cleanup.log"
}


run_benchmark() {
  local SCRIPT_PATH="$1" MODE="$2" OUTPUT_FILE="$3" SCRIPT_NAME="${4:-}" COMBINATION="${5:-}"

  if [[ -n "$SCRIPT_NAME" ]] && [ -z "$DB_PORTS" ]; then
    echo "Running $(basename "$SCRIPT_PATH") for $TIME seconds ..."
  fi
  if [[ "$MODE" == "prepare" ]]; then
    echo "Preparing database for $(basename "$SCRIPT_PATH")${COMBINATION:+ with $COMBINATION}"
  fi
  [[ "$MODE" == "cleanup" ]] && echo -e "Cleaning up database for $(basename "$SCRIPT_PATH")\n"

  # Check if mode is run, script contains '_select' and DB_PORTS is set
  if [[ "$MODE" == "run" && $(basename "$SCRIPT_PATH") == *_select* && -n "$DB_PORTS" ]]; then
    OUTPUT_BASE_FILE="${OUTPUT_FILE%.log}"
    for PORT in $DB_PORTS; do
      echo "Running $(basename "$SCRIPT_PATH") on port $PORT for $TIME seconds ..."
      local CUSTOM_SCRIPT_NAME="${SCRIPT_NAME%_select}_select_port_${PORT}"
      OUTPUT_FILE="${OUTPUT_BASE_FILE%.log}_port_${PORT}.log"

      run_sysbench "$SCRIPT_PATH" "$MODE" "$OUTPUT_FILE" "$PORT" || { echo "Benchmark failed for script $SCRIPT_PATH on port $PORT"; exit 1; }

      extract_run_data "$OUTPUT_FILE" "$CUSTOM_SCRIPT_NAME"
      extract_statistics "$OUTPUT_FILE" "$CUSTOM_SCRIPT_NAME"
    done
  else
    run_sysbench "$SCRIPT_PATH" "$MODE" "$OUTPUT_FILE" || { echo "Benchmark failed for script $SCRIPT_PATH"; exit 1; }

    if [ "$MODE" == "run" ]; then
      extract_run_data "$OUTPUT_FILE" "$SCRIPT_NAME"
      extract_statistics "$OUTPUT_FILE" "$SCRIPT_NAME"
    fi
  fi
}

# Helper function to run sysbench with specified Lua script and mode
run_sysbench() {
  local LUA_SCRIPT_PATH="$1" MODE="$2" LOG_FILE="$3" CUSTOM_PORT="${4:-$DB_PORT}"

  sysbench \
    --db-driver="$DRIVER" \
    --${DRIVER}-host="$DB_HOST" \
    --${DRIVER}-port="$CUSTOM_PORT" \
    --${DRIVER}-user="$DB_USER" \
    --${DRIVER}-password="$DB_PASS" \
    --${DRIVER}-db="$DB_NAME" \
    --time=$TIME \
    --threads=$THREADS \
    --events=$EVENTS \
    --report-interval=$REPORT_INTERVAL \
    "$LUA_SCRIPT_PATH" "$MODE" >> "$LOG_FILE" 2>&1

  return $?
}

# Function to extract and save run data
extract_run_data() {
  local RAW_RESULTS_FILE="$1" SCRIPT_NAME="$2"

  grep '^\[ ' "$RAW_RESULTS_FILE" | while read -r line; do
    time=$(echo "$line" | awk '{print $2}' | sed 's/s//')
    threads=$(echo "$line" | awk -F 'thds: ' '{print $2}' | awk '{print $1}')
    tps=$(echo "$line" | awk -F 'tps: ' '{print $2}' | awk '{print $1}')
    qps=$(echo "$line" | awk -F 'qps: ' '{print $2}' | awk '{print $1}')
    read_write_other=$(echo "$line" | sed -E 's/.*\(r\/w\/o: ([0-9.]+)\/([0-9.]+)\/([0-9.]+)\).*/\1,\2,\3/')
    reads=$(echo "$read_write_other" | cut -d',' -f1)
    writes=$(echo "$read_write_other" | cut -d',' -f2)
    other=$(echo "$read_write_other" | cut -d',' -f3)
    latency=$(echo "$line" | awk -F 'lat \\(ms,95%\\): ' '{print $2}' | awk '{print $1}')
    err_per_sec=$(echo "$line" | awk -F 'err/s: ' '{print $2}' | awk '{print $1}')
    reconn_per_sec=$(echo "$line" | awk -F 'reconn/s: ' '{print $2}' | awk '{print $1}')

    echo "$SCRIPT_NAME,$time,$threads,$tps,$qps,$reads,$writes,$other,$latency,$err_per_sec,$reconn_per_sec" >> "$RUNTIME_FILE_TEMP"
  done
}

# Function to extract statistics from sysbench results
extract_statistics() {
  local RAW_RESULTS_FILE="$1" SCRIPT_NAME="$2"

  # Extract SQL statistics and append to statistics_inofficial.csv
  read=$(awk '/read:/ {print $2}' "$RAW_RESULTS_FILE")
  write=$(awk '/write:/ {print $2}' "$RAW_RESULTS_FILE")
  other=$(awk '/other:/ {print $2}' "$RAW_RESULTS_FILE")
  total=$(awk '/total:/ {print $2}' "$RAW_RESULTS_FILE")
  transactions=$(awk '/transactions:/ {print $2}' "$RAW_RESULTS_FILE")
  queries=$(awk '/queries:/ {print $2}' "$RAW_RESULTS_FILE")
  ignored_errors=$(awk '/ignored errors:/ {print $3}' "$RAW_RESULTS_FILE")
  reconnects=$(awk '/reconnects:/ {print $2}' "$RAW_RESULTS_FILE")
  total_time=$(awk '/total time:/ {print $3}' "$RAW_RESULTS_FILE")
  total_events=$(awk '/total number of events:/ {print $5}' "$RAW_RESULTS_FILE")
  latency_min=$(awk '/min:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_avg=$(awk '/avg:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_max=$(awk '/max:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_95th=$(awk '/95th percentile:/ {print $3}' "$RAW_RESULTS_FILE")
  latency_sum=$(awk '/sum:/ {print $2}' "$RAW_RESULTS_FILE")

  # Append the extracted data to the statistics output file
  echo "$SCRIPT_NAME,$read,$write,$other,$total,$transactions,$queries,$ignored_errors,$reconnects,$total_time,$total_events,$latency_min,$latency_avg,$latency_max,$latency_95th,$latency_sum" >> "$STATISTICS_FILE_TEMP"
}

prepare_variables(){
  local SCRIPT_PATH="$1" ENV="$2"
  # shellcheck disable=SC2046
  eval $(jq -r --arg env "$ENV" '.[$env] | to_entries | .[] | "export " + .key + "=" + (.value | @sh)' "$ABS_PATH/envs.json")
  [ -n "$REPLICAS_COUNT" ] && DB_PORTS=$(seq -s' ' $DB_PORT $((DB_PORT + REPLICAS_COUNT))) || unset DB_PORTS

  EXPORTED_VARS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].vars // ""')
  STATS_SELECT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].stats_select_columns // ""')
  STATS_INSERT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].stats_insert_columns // ""')
  RUNTIME_SELECT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].runtime_select_columns // ""')
  RUNTIME_INSERT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].runtime_insert_columns // ""')

  STATS_SELECT_COLUMNS=${STATS_SELECT_COLUMNS:-$STATS_SELECT_COLUMNS_DEFAULT}
  STATS_INSERT_COLUMNS=${STATS_INSERT_COLUMNS:-$STATS_INSERT_COLUMNS_DEFAULT}
  RUNTIME_SELECT_COLUMNS=${RUNTIME_SELECT_COLUMNS:-$RUNTIME_SELECT_COLUMNS_DEFAULT}
  RUNTIME_INSERT_COLUMNS=${RUNTIME_INSERT_COLUMNS:-$RUNTIME_INSERT_COLUMNS_DEFAULT}

  MAIN_SCRIPT="${SCRIPT_PATH}/$(basename "$SCRIPT_PATH").lua"
  INSERT_SCRIPT="${SCRIPT_PATH}/$(basename "$SCRIPT_PATH")_insert.lua"
  SELECT_SCRIPT="${SCRIPT_PATH}/$(basename "$SCRIPT_PATH")_select"
  LOG_DIR="$OUTPUT_DIR/logs/$(basename "$SCRIPT_PATH")"
}

generate_combinations() {
    local current_combination="$1"
    shift
    local keys=("$@")

    if [ ${#keys[@]} -eq 0 ]; then
        echo "$current_combination"
        return
    fi

    local key="${keys[0]}"
    local values=$(echo "$JSON_VARIABLES" | jq -r ".\"$key\"[]")
    local remaining_keys=("${keys[@]:1}")

    for value in $values; do
        generate_combinations "${current_combination:+$current_combination,}${key}=$value" "${remaining_keys[@]}"
    done
}

# Main benchmark loop
for SCRIPT_PATH in $SCRIPT_KEYS; do
  DBMS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].db // ["mysql"]')
  DBMS_LENGTH=$(echo "$DBMS" | jq length)
  for DB in $(echo "$DBMS" | jq -r '.[]'); do
    prepare_variables "$SCRIPT_PATH" "$DB"
    if [[ -n "$EXPORTED_VARS" ]]; then
        IFS=',' read -r -a KEYS <<< "$EXPORTED_VARS"

        # Generate all combinations of key-value pairs
        COMBINATIONS=$(generate_combinations "" "${KEYS[@]}")
        # Process each combination
        while IFS=',' read -r combination; do
            # Export key-value pairs for the current combination
            IFS=',' read -ra key_value_pairs <<< "$combination"
            for pair in "${key_value_pairs[@]}"; do
              export "$(echo "${pair%%=*}" | tr '[:lower:]' '[:upper:]')=${pair#*=}"
            done

            # Create a directory name for the combination
            COMBINATION_NAME="$( [ "$DB" != "mysql" ] || [ "$DBMS_LENGTH" -ne 1 ] && echo "${DB}_" )$(echo "$combination" | sed -E 's/(^|,)num_rows=[^,]*//g;s/^,//;s/,$//' | tr ',' '_' | tr '=' '_')"
            LOG_DIR_COMBINATION="$LOG_DIR/$COMBINATION_NAME"

            process_script_benchmark "$SCRIPT_PATH" "$LOG_DIR_COMBINATION" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$COMBINATION_NAME"
        done <<< "$COMBINATIONS"
    else
      COMBINATION_NAME="$( [ "$DB" != "mysql" ] || [ "$DBMS_LENGTH" -ne 1 ] && echo "${DB}" )"
      LOG_DIR_COMBINATION="$LOG_DIR/$COMBINATION_NAME"
      process_script_benchmark "$SCRIPT_PATH" "$LOG_DIR_COMBINATION" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$COMBINATION_NAME"
    fi
    # shellcheck disable=SC2046
    eval $(jq -r --arg env "$DB" '.[$env] | to_entries | .[] | "unset " + .key' "$ABS_PATH/envs.json")
  done
done

# Statistics csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$STATISTICS_FILE_TEMP" "$STATISTICS_FILE" --select_columns "$STATS_SELECT_COLUMNS" --insert_columns "$STATS_INSERT_COLUMNS"
echo "Combined CSV file created at $STATISTICS_FILE"

# Outputfile csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$RUNTIME_FILE_TEMP" "$RUNTIME_FILE" --select_columns "$RUNTIME_SELECT_COLUMNS" --insert_columns "$RUNTIME_INSERT_COLUMNS"
echo "Combined CSV file created at $RUNTIME_FILE"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$PYTHON_PATH/generatePlot.py" "$RUNTIME_FILE" "$STATISTICS_FILE"