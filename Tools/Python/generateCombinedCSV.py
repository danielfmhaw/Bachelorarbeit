import argparse
import pandas as pd
import re
import os

def main():
    parser = argparse.ArgumentParser(description="Process sysbench output CSV file")
    parser.add_argument('input_file', type=str, help="Path to the input CSV file")
    parser.add_argument('output_file', type=str, help="Path to the output CSV file")
    parser.add_argument('--select_columns', type=str, help="Comma-separated list of columns where select is used", default="")
    parser.add_argument('--insert_columns', type=str, help="Comma-separated list of columns where insert is used", default="")

    args = parser.parse_args()
    df = pd.read_csv(args.input_file)
    # os.remove(args.input_file)

    headers = df.columns.tolist()
    select_columns = args.select_columns.split(';') if args.select_columns else []
    insert_columns = args.insert_columns.split(';') if args.insert_columns else []

    df['Base_Script'] = df['Script'].str.extract(r'(.*?)(?:_(insert|select))')[0]
    insert_rows = df[df['Script'].str.endswith('_insert')]
    select_rows = df[df['Script'].str.contains('_select')]

    combined = []

    def merge_rows(insert_row, select_row):
        # 1) no multiple selects and no multiple lens => ex.: int_queries_select => int_queries
        # 2) multiple selects but no multiple lens => ex.: query_differences_select_column_prefix => column_prefix
        # 3) multiple lens but no multiple selects => ex.: with_index_500_select => with_index_500
        # 4) multiple selects and multiple lens => ex.: null_2_select_default_null_count_null => default_null_count_null_2
        match = re.match(r'^(?:(?:[a-zA-Z]*_)*?(\d+)_select_)?(.*?)(?:_select)?$', select_row['Script'])
        if match:
            group1 = match.group(1)
            group2 = match.group(2)

            if group1 is not None:
                script_name = f"{group2}_{group1}"
            else:
                parts = group2.split("_select")
                script_name = parts[-1].lstrip("_") if parts else group2

        merged = {'Script': script_name}

        for column in headers:
            if column != 'Script' and column != 'Base_Script':
                if column in select_columns:
                    value = select_row[column]
                elif column in insert_columns:
                    value = insert_row[column]
                else:
                    value = insert_row[column] + select_row[column]

                if column in ['Time (s)', 'Threads'] and isinstance(value, float) and value.is_integer():
                    merged[column] = f"{int(value)}"
                elif isinstance(value, (int, float)):
                    merged[column] = f"{value:.2f}"
                else:
                    merged[column] = value

        return merged

    for base_script in insert_rows['Base_Script'].unique():
        insert_data = insert_rows[insert_rows['Base_Script'] == base_script]
        matching_selects = select_rows[select_rows['Base_Script'] == base_script]

        if "Time (s)" in headers:
            grouped_selects = matching_selects.groupby("Script")
            for script, group in grouped_selects:
                for _, insert_row in insert_data.iterrows():
                    matching_rows = group[group['Time (s)'] == insert_row['Time (s)']]
                    if not matching_rows.empty:
                        for _, select_row in matching_rows.iterrows():
                            combined.append(merge_rows(insert_row, select_row))
        else:
            for _, insert_row in insert_data.iterrows():
                for _, select_row in matching_selects.iterrows():
                    combined.append(merge_rows(insert_row, select_row))

    combined_df = pd.DataFrame(combined)
    combined_df.to_csv(args.output_file, index=False)

if __name__ == "__main__":
    main()
