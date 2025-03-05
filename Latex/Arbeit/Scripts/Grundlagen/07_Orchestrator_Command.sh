./sysbench_script.sh \
  -out "YOUR_PATH_TO_DIRECTORY/Output" \
  -var '{"length":[4, 16]}' \
  -scripts '{
    "YOUR_PATH_TO_DIRECTORY/Scripts/varchar_queries": {
      "vars": "length"
    },
    "YOUR_PATH_TO_DIRECTORY/Scripts/int_queries": {
      "vars": "length"
    }
  }'