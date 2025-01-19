./sysbench_script.sh \
  -out "YOUR_PATH_TO_DIRECTORY/Output" \
  -var '{"length":[1,64]}' \
  -scripts:"YOUR_PATH_TO_DIRECTORY/int_queries" \
  "YOUR_PATH_TO_DIRECTORY/varchar_queries:length"