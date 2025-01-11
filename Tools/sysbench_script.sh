which bash

#!/bin/bash

if [ -n "$GITHUB_ACTIONS" ]; then
    ENV_PATH="./db.env"
    PYTHON_PATH="./Tools/Python"
else
    ENV_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Repo/db.env"
    PYTHON_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Tools/Python"
fi

# Load environment variables
if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_NAME" ]; then
    if [ -f "$ENV_PATH" ]; then
        # shellcheck source=/path/to/your/env/file
        source "$ENV_PATH"
    fi
fi

# Display usage instructions
usage() {
    echo "Usage: $0 -out <output_dir> [-var <json_variables>] -scripts:<query_info1> <query_info2> ..."
    exit 1
}

# Initialize variables
OUTPUT_DIR=""
JSON_VARIABLES=""
QUERY_INFO=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -out) OUTPUT_DIR="$2"; shift 2 ;;
        -var) JSON_VARIABLES="$2"; shift 2 ;;
        -scripts:*)
            QUERY_INFO+=("${1#-scripts:}")
            shift
            while [[ $# -gt 0 && "$1" != -* ]]; do
                QUERY_INFO+=("$1")
                shift
            done
            ;;
        *) usage ;;
    esac
done

# Validate required arguments
if [ -z "$OUTPUT_DIR" ] || [ "${#QUERY_INFO[@]}" -eq 0 ]; then
    usage
fi

# Validate queries against parsed JSON variables
for INFO in "${QUERY_INFO[@]}"; do
    if [[ "$INFO" == *":"* ]]; then
        KEYS_AFTER_COLON=$(echo "$INFO" | awk -F':' '{print $2}' | tr ',' ' ')
        for KEY in $KEYS_AFTER_COLON; do
              if ! echo "$JSON_VARIABLES" | jq -e ".\"$KEY\"" >/dev/null 2>&1; then
                echo "Error: The variable '$KEY' in query '$INFO' is not defined in JSON_VARIABLES"
                exit 1
              fi
        done
    fi
done


# Define file paths
RUNTIME_FILE="$OUTPUT_DIR/sysbench_runtime.csv"
RUNTIME_FILE_TEMP="$OUTPUT_DIR/sysbench_runtime_temp.csv"
STATISTICS_FILE="$OUTPUT_DIR/sysbench_statistics.csv"
STATISTICS_FILE_TEMP="$OUTPUT_DIR/sysbench_statistics_temp.csv"

# Sysbench configuration
TIME=${TIME:-32}
THREADS=${THREADS:-8}
EVENTS=${EVENTS:-0}
REPORT_INTERVAL=${REPORT_INTERVAL:-4}

# Ensure output directories exist
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Prepare CSV headers
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$RUNTIME_FILE_TEMP"
echo "Script,Read (noq),Write (noq),Other (noq),Total (noq),Transactions (per s.),Queries (per s.),Ignored Errors (per s.),Reconnects (per s.),Total Time (s),Total Events,Latency Min (ms),Latency Avg (ms),Latency Max (ms),Latency 95th Percentile (ms),Latency Sum (ms)" > "$STATISTICS_FILE_TEMP"

run_benchmark() {
  local SCRIPT_PATH="$1"
  local MODE="$2"
  local OUTPUT_FILE="$3"
  local SCRIPT_NAME="${4:-}"
  local COMBINATION="${5:-}"

  if [[ -n "$SCRIPT_NAME" ]]; then
    echo "Running $(basename "$SCRIPT_PATH") for $TIME seconds ..."
  fi
  if [[ "$MODE" == "prepare" ]]; then
    echo "Preparing database for $(basename "$SCRIPT_PATH")${COMBINATION:+ with $COMBINATION}"
  fi
  [[ "$MODE" == "cleanup" ]] && echo -e "Cleaning up database for $(basename "$SCRIPT_PATH")\n"

  run_sysbench "$SCRIPT_PATH" "$MODE" "$OUTPUT_FILE"
  if [ $? -ne 0 ]; then
    echo "Benchmark failed for script $SCRIPT_PATH. Exiting."
    exit 1
  fi

  # Only extract data if the mode is "run"
  if [ "$MODE" == "run" ]; then
    extract_run_data "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
    extract_statistics "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
  fi
}

# Helper function to run sysbench with specified Lua script and mode
run_sysbench() {
  local LUA_SCRIPT_PATH="$1"
  local MODE="$2"
  local LOG_FILE="$3"

  sysbench \
    --db-driver=mysql \
    --mysql-host="$DB_HOST" \
    --mysql-port="$DB_PORT" \
    --mysql-user="$DB_USER" \
    --mysql-password="$DB_PASS" \
    --mysql-db="$DB_NAME" \
    --time=$TIME \
    --threads=$THREADS \
    --events=$EVENTS \
    --report-interval=$REPORT_INTERVAL \
    "$LUA_SCRIPT_PATH" "$MODE" >> "$LOG_FILE" 2>&1

  return $?
}

# Function to extract and save run data
extract_run_data() {
  local RAW_RESULTS_FILE="$1"
  local SCRIPT_NAME="$2"

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
  local RAW_RESULTS_FILE="$1"
  local SCRIPT_NAME="$2"

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

process_script_benchmark() {
  local QUERY_PATH="$1"
  local LOG_DIR="$2"
  local INSERT_SCRIPT="$3"
  local SELECT_SCRIPT="$4"
  local COMBINATION="${5:-}"

  local SCRIPTS=()
  local IS_FROM_SELECT_DIR=false

  if [ -f "$SELECT_SCRIPT.lua" ]; then
    # SELECT_SCRIPT is a Lua file
    SCRIPTS=("$INSERT_SCRIPT" "$SELECT_SCRIPT.lua")
  else
    # SELECT_SCRIPT is a directory
    SCRIPTS=("$INSERT_SCRIPT" "$SELECT_SCRIPT"/*)
    IS_FROM_SELECT_DIR=true
  fi

  for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
      local SCRIPT_NAME
      if [ -n "$COMBINATION" ]; then
        if $IS_FROM_SELECT_DIR && [[ "$SCRIPT" == "$SELECT_SCRIPT"/* ]]; then
          SCRIPT_NAME="${QUERY_PATH##*/}_${COMBINATION}_select_$(basename "$SCRIPT" .lua)"
        else
          SCRIPT_NAME="${QUERY_PATH##*/}_${COMBINATION}_$(basename "$SCRIPT" .lua | sed "s/^${QUERY_PATH##*/}_//")"
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
for INFO in "${QUERY_INFO[@]}"; do
  IFS=: read -r QUERY_PATH MULTIPLE_KEYS <<< "$INFO"

  MAIN_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH").lua"
  INSERT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_insert.lua"
  SELECT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_select"
  LOG_DIR="$OUTPUT_DIR/logs/$(basename "$QUERY_PATH")"

  if [[ -n "$MULTIPLE_KEYS" ]]; then
    IFS=',' read -r -a KEYS <<< "$MULTIPLE_KEYS"

    # Generate all combinations of key-value pairs
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

        # Create a directory name for the combination
        COMBINATION_NAME=$(echo "$combination" | sed -E 's/(^|,)num_rows=[^,]*//g;s/^,//;s/,$//' | tr ',' '_' | tr '=' '_')
        LOG_DIR_KEY_VALUE="$LOG_DIR/$COMBINATION_NAME"
        mkdir -p "$LOG_DIR_KEY_VALUE"

        # Prepare benchmark
        RAW_RESULTS_FILE="${LOG_DIR_KEY_VALUE}/$(basename "$QUERY_PATH")_${COMBINATION_NAME}_prepare.log"
        run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE" "" "$COMBINATION_NAME"

        # Process script benchmark
        process_script_benchmark "$QUERY_PATH" "$LOG_DIR_KEY_VALUE" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$COMBINATION_NAME"

        # Cleanup benchmark
        RAW_RESULTS_FILE="${LOG_DIR_KEY_VALUE}/$(basename "$QUERY_PATH")_${COMBINATION_NAME}_cleanup.log"
        run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
    done <<< "$combinations"
  else
    # Process normally when no keys specified
    mkdir -p "$LOG_DIR"
    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_prepare.log"
    run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE"

    process_script_benchmark "$QUERY_PATH" "$LOG_DIR" "$INSERT_SCRIPT" "$SELECT_SCRIPT"

    # Cleanup phase
    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_cleanup.log"
    run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
  fi
done

# Statistics csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$STATISTICS_FILE_TEMP" "$STATISTICS_FILE" --insert_columns "Total Time"
echo "Combined CSV file created at $STATISTICS_FILE"

# Outputfile csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$RUNTIME_FILE_TEMP" "$RUNTIME_FILE" --select_columns "Time (s),Threads"
echo "Combined CSV file created at $RUNTIME_FILE"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$PYTHON_PATH/generatePlot.py" "$RUNTIME_FILE" "$STATISTICS_FILE"