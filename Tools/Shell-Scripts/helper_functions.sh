# Parses the arguments and checks if each var is really defined
parse_arguments() {
    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -out) OUTPUT_DIR="$2"; shift 2 ;;
            -var) JSON_VARIABLES="$2"; shift 2 ;;
            -scripts)
                SCRIPTS=$(echo "$2" | tr -d '\n' | sed 's/[[:space:]]*{/{/g' | sed 's/}[[:space:]]*/}/g' | sed 's/: /:/g' | sed 's/, /,/g')
                SCRIPT_DIRS=$(echo "$SCRIPTS" | jq -r 'keys[]')
                shift 2
                ;;
            *) usage ;;
        esac
    done

    # Validate required arguments
    if [ -z "$OUTPUT_DIR" ] || [ -z "$SCRIPT_DIRS" ]; then
        usage
    fi

    # Validate variables in JSON
    for SCRIPT_DIR in $SCRIPT_DIRS; do
        VARS_VALUE=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_DIR" '.[$key].vars // ""')
        if [[ -n "$VARS_VALUE" ]]; then
            IFS=',' read -ra VARS_LIST <<< "$VARS_VALUE"
            for VAR in "${VARS_LIST[@]}"; do
                if ! echo "$JSON_VARIABLES" | jq -e ".\"$VAR\"" >/dev/null 2>&1; then
                    echo "Error: The variable '$VAR' for dir '$SCRIPT_DIR' is not defined in JSON_VARIABLES"
                    exit 1
                fi
            done
        fi
    done
}

# Helper function to print a hint
usage() {
    echo "Usage: $0 -out <output_dir> [-var <json_variables>] -scripts <script_info>"
    echo
    echo "Options:"
    echo "  -out <output_dir>      Specify the output directory for the results."
    echo "  -var <json_variables>  Optional. JSON string containing variables (in key-value pairs) to be used in scripts."
    echo "  -scripts <script_info> JSON data specifying the scripts and their configurations, including variables."
    echo
    echo "Example:"
    echo "  $0 -out /path/to/output -var '{\"var1\": \"value1\", \"var2\": \"value2\"}' -scripts '{\"script1\": {\"vars\": \"var1,var2\"}}'"
    exit 1
}

# Helper function to initialize variables for all dbs
initialize_variables() {
  local OUTPUT_DIR="$1" ABS_PATH="$2"
  TIME="${3:-8}"
  THREADS="${4:-1}"
  EVENTS="${5:-0}"
  REPORT_INTERVAL="${6:-1}"

  # Define file paths
  PYTHON_PATH="${ABS_PATH}/Tools/Python"
  RUNTIME_FILE="$OUTPUT_DIR/sysbench_runtime.csv"
  RUNTIME_FILE_TEMP="$OUTPUT_DIR/sysbench_runtime_temp.csv"
  STATISTICS_FILE="$OUTPUT_DIR/sysbench_statistics.csv"
  STATISTICS_FILE_TEMP="$OUTPUT_DIR/sysbench_statistics_temp.csv"

  # Default values for select_columns and insert_columns
  STATS_SELECT_COLUMNS_DEFAULT="Total Time"
  STATS_INSERT_COLUMNS_DEFAULT=""
  RUNTIME_SELECT_COLUMNS_DEFAULT="Time (s);Threads"
  RUNTIME_INSERT_COLUMNS_DEFAULT=""

  # Ensure output directories exist
  rm -rf "$OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR"

  # Prepare CSV headers
  echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$RUNTIME_FILE_TEMP"
  echo "Script,Read (noq),Write (noq),Other (noq),Total (noq),Transactions (per s.),Queries (per s.),Ignored Errors (per s.),Reconnects (per s.),Total Time (s),Total Events,Latency Min (ms),Latency Avg (ms),Latency Max (ms),Latency 95th Percentile (ms),Latency Sum (ms)" > "$STATISTICS_FILE_TEMP"
}

# Helper function to prepare the variables (for each db)
prepare_variables(){
  local SCRIPT_PATH="$1" ENV="$2"

  CUSTOM_DB_NAME="${ENV#*,}"
  ENV="${ENV%%,*}"
  CUSTOM_DB_NAME=${CUSTOM_DB_NAME:-$ENV}
  # shellcheck disable=SC2046
  eval $(jq -r --arg env "$ENV" '.[$env] | to_entries | .[] | "export " + .key + "=" + (.value | @sh)' "$ABS_PATH/envs.json")
  export CUSTOM_DB_NAME DB="$ENV"

  [ -n "$REPLICAS_COUNT" ] && DB_PORTS=$(seq -s' ' $DB_PORT $((DB_PORT + REPLICAS_COUNT))) || unset DB_PORTS

  EXPORTED_VARS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].vars // ""')
  STATS_SELECT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].stats_select_columns // ""')
  STATS_INSERT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].stats_insert_columns // ""')
  RUNTIME_SELECT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].runtime_select_columns // ""')
  RUNTIME_INSERT_COLUMNS=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].runtime_insert_columns // ""')
  PREFIXES=$(echo "$SCRIPTS" | jq -r --arg key "$SCRIPT_PATH" '.[$key].prefixes // ""')

  STATS_SELECT_COLUMNS=${STATS_SELECT_COLUMNS:-$STATS_SELECT_COLUMNS_DEFAULT}
  STATS_INSERT_COLUMNS=${STATS_INSERT_COLUMNS:-$STATS_INSERT_COLUMNS_DEFAULT}
  RUNTIME_SELECT_COLUMNS=${RUNTIME_SELECT_COLUMNS:-$RUNTIME_SELECT_COLUMNS_DEFAULT}
  RUNTIME_INSERT_COLUMNS=${RUNTIME_INSERT_COLUMNS:-$RUNTIME_INSERT_COLUMNS_DEFAULT}

  MAIN_SCRIPT="${SCRIPT_PATH}/$(basename "$SCRIPT_PATH").lua"
  INSERT_SCRIPT="${SCRIPT_PATH}/$(basename "$SCRIPT_PATH")_insert.lua"
  SELECT_SCRIPT="${SCRIPT_PATH}/$(basename "$SCRIPT_PATH")_select"
  LOG_DIR="$OUTPUT_DIR/logs/$(basename "$SCRIPT_PATH")"
}

# Helper function to run sysbench for each port
run_sysbench_for_each_port() {
  local DB_PORTS="$1" SCRIPT_PATH="$2" SCRIPT_NAME="$3" MODE="$4" CUSTOM_THREADS="$5"

  OUTPUT_BASE_FILE="${OUTPUT_FILE%.log}"
  for PORT in $DB_PORTS; do
    echo "Running $(basename "$SCRIPT_PATH") on port $PORT for $TIME seconds ..."
    local CUSTOM_SCRIPT_NAME="${SCRIPT_NAME%_select}_select_with_port_${PORT}"
    OUTPUT_FILE="${OUTPUT_BASE_FILE%.log}_port_${PORT}.log"

    run_sysbench "$SCRIPT_PATH" "$MODE" "$OUTPUT_FILE" "$PORT" "$CUSTOM_THREADS" || { echo "Benchmark failed for script $SCRIPT_PATH on port $PORT"; exit 1; }

    extract_run_data "$OUTPUT_FILE" "$CUSTOM_SCRIPT_NAME"
    extract_statistics "$OUTPUT_FILE" "$CUSTOM_SCRIPT_NAME"
  done
}

# Helper function to run sysbench with specified Lua script and mode
run_sysbench() {
  local LUA_SCRIPT_PATH="$1" MODE="$2" LOG_FILE="$3" CUSTOM_PORT="${4}" CUSTOM_THREADS="${5}"

  sysbench \
    --db-driver="$DRIVER" \
    --${DRIVER}-host="$DB_HOST" \
    --${DRIVER}-port="$CUSTOM_PORT" \
    --${DRIVER}-user="$DB_USER" \
    --${DRIVER}-password="$DB_PASS" \
    --${DRIVER}-db="$DB_NAME" \
    --time=$TIME \
    --threads=$CUSTOM_THREADS \
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

# Function to generate the specific script name
generate_script_name() {
  local SCRIPT="$1" DB_INFO="$2" COMBINATION="$3" SCRIPT_PATH="$4" INSERT_SCRIPT="$5" SELECT_SCRIPT="$6" IS_FROM_SELECT_DIR="$7"

  BASE_NAME=$(basename "$SCRIPT" .lua)
  DB_SUFFIX=$( [ -n "$DB_INFO" ] && echo "_db_${DB_INFO}" )
  IS_SELECT=$([[ "$SCRIPT" == "$INSERT_SCRIPT" ]] && echo false  || echo true)
  if [ -n "$COMBINATION" ]; then
    COMB_SUFFIX="_comb_${COMBINATION}"
    if $IS_FROM_SELECT_DIR && $IS_SELECT; then
      SCRIPT_NAME="${SCRIPT_PATH##*/}${DB_SUFFIX}${COMB_SUFFIX}_select_${BASE_NAME}"
    else
      CLEANED_NAME=$(basename "$SCRIPT" .lua | sed "s/^${SCRIPT_PATH##*/}_//")
      SCRIPT_NAME="${SCRIPT_PATH##*/}${DB_SUFFIX}${COMB_SUFFIX}_${CLEANED_NAME}"
    fi
  else
    if $IS_FROM_SELECT_DIR && $IS_SELECT; then
      BASE_SELECT_NAME=$(basename "$SELECT_SCRIPT" .lua)
      SCRIPT_NAME="${BASE_SELECT_NAME%_*}${DB_SUFFIX}_${BASE_SELECT_NAME##*_}_${BASE_NAME}"
    else
      SCRIPT_NAME="${BASE_NAME%_*}${DB_SUFFIX}_${BASE_NAME##*_}"
    fi
  fi
}

# Function to generate all combinations of the exported vars
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
