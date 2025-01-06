run_benchmark() {
  # For OTHER_ENVIRONMENT_VARIABLES => see demo
  sysbench --db-driver=mysql OTHER_ENVIRONMENT_VARIABLES "$SCRIPT_PATH" "$MODE" >> "$OUTPUT_FILE" 2>&1
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
