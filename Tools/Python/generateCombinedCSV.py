import argparse
import pandas as pd

def parse_arguments():
    parser = argparse.ArgumentParser(description="Process sysbench output CSV file")
    parser.add_argument('input_file', type=str, help="Path to the input CSV file")
    parser.add_argument('output_file', type=str, help="Path to the output CSV file")
    parser.add_argument('--select_columns', type=str, default="", help="Comma-separated list of columns where only the select value is used")
    parser.add_argument('--insert_columns', type=str, default="", help="Comma-separated list of columns where only the insert value is used")
    parser.add_argument('--prefixes', type=str, default="", help="Comma-separated list of prefixes for merging rows")
    return parser.parse_args()

def format_value(column, value):
    if column in ['Time (s)', 'Threads'] and isinstance(value, float) and value.is_integer():
        return f"{int(value)}"
    return f"{value:.2f}" if isinstance(value, (int, float)) else value

def merge_rows(insert_row, select_row, headers, select_columns, insert_columns):
    merged_row = {'Script': select_row['Script']}
    for column in headers:
        if column not in ['Script', 'Base_Script']:
            if column in select_columns or column in ['Time (s)', 'Threads']:
                merged_row[column] = format_value(column, select_row[column])
            elif column in insert_columns:
                merged_row[column] = format_value(column, insert_row[column])
            else:
                merged_row[column] = format_value(column, insert_row[column] + select_row[column])

    return merged_row

def merge_select_rows(matching_with_prefix, matching_selects, headers, prefix):
    if matching_with_prefix.empty:
        return matching_selects

    grouped = matching_with_prefix.groupby('Time (s)') if 'Time (s)' in headers else [(None, matching_with_prefix)]
    for time, group in grouped:
        summed_values = {'Script': prefix}
        for col in headers:
            if col not in ['Script']:
                summed_values[col] = group[col].iloc[0] if col in ['Time (s)', 'Base_Script'] else group[col].sum()

        summed_values_df = pd.DataFrame([summed_values])
        mask = (matching_selects['Script'].str.startswith(prefix)) & (matching_selects['Time (s)'] == time if time else True)
        matching_selects = pd.concat([matching_selects[~mask], summed_values_df], ignore_index=True)

    return matching_selects

def process_data(df, select_columns, insert_columns, prefixes):
    headers = df.columns.tolist()
    df['Base_Script'] = df['Script'].str.extract(r'(.*?)(?:_(insert|select))')[0]
    insert_rows = df[df['Script'].str.endswith('_insert')]
    select_rows = df[df['Script'].str.contains('_select')]
    combined = []

    for base_script, insert_data in insert_rows.groupby('Base_Script'):
        matching_selects = select_rows[select_rows['Base_Script'] == base_script]
        for prefix in prefixes:
            matching_with_prefix = matching_selects[matching_selects['Script'].str.startswith(prefix)]
            matching_selects = merge_select_rows(matching_with_prefix, matching_selects, headers, prefix)

        max_time = df.groupby('Script')['Time (s)'].max().min() if 'Time (s)' in headers else None
        for _, insert_row in insert_data.iterrows():
            matching_rows = matching_selects if max_time is None else matching_selects[matching_selects['Time (s)'] == insert_row['Time (s)']]
            for _, select_row in matching_rows.iterrows():
                if max_time is None or insert_row['Time (s)'] <= max_time:
                    combined.append(merge_rows(insert_row, select_row, headers, select_columns, insert_columns))

    return pd.DataFrame(combined, columns=['Script'] + [col for col in headers if col != 'Script'])

def main():
    args = parse_arguments()
    df = pd.read_csv(args.input_file)
    select_columns, insert_columns, prefixes = [x.split(',') if x else [] for x in [args.select_columns, args.insert_columns, args.prefixes]]
    combined_df = process_data(df, select_columns, insert_columns, prefixes)
    combined_df.to_csv(args.output_file, index=False)

if __name__ == "__main__":
    main()
