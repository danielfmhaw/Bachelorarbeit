import argparse
import pandas as pd
import re
import os

def main():
    parser = argparse.ArgumentParser(description="Process sysbench output CSV file")
    parser.add_argument('input_file', type=str, help="Path to the input CSV file")
    parser.add_argument('output_file', type=str, help="Path to the output CSV file")
    parser.add_argument('--select_columns', type=str, help="Comma-separated list of columns where only the select value is used", default="")
    parser.add_argument('--insert_columns', type=str, help="Comma-separated list of columns where only the insert value is used", default="")

    args = parser.parse_args()
    df = pd.read_csv(args.input_file)
    # os.remove(args.input_file)

    headers = df.columns.tolist()
    select_columns = args.select_columns.split(',') if args.select_columns else []
    insert_columns = args.insert_columns.split(',') if args.insert_columns else []

    df['Base_Script'] = df['Script'].str.extract(r'(.*?)(?:_(insert|select))')[0]
    insert_rows = df[df['Script'].str.endswith('_insert')]
    select_rows = df[df['Script'].str.contains('_select')]

    combined = []

    def merge_rows(insert_row, select_row):
        merged = {'Script': select_row['Script']}

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
            max_time= df.groupby('Script')['Time (s)'].max().min()
            grouped_selects = matching_selects.groupby("Script")
            for script, group in grouped_selects:
                for _, insert_row in insert_data.iterrows():
                    matching_rows = group[group['Time (s)'] == insert_row['Time (s)']]
                    if not matching_rows.empty and insert_row['Time (s)'] <= max_time:
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
