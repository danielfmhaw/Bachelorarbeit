import pandas as pd
import argparse
import re

# Argument Parser
parser = argparse.ArgumentParser(description="Process sysbench output CSV file")
parser.add_argument('input_file', type=str, help="Path to the input CSV file")
parser.add_argument('output_file', type=str, help="Path to the output CSV file")

args = parser.parse_args()
df = pd.read_csv(args.input_file)

df['Base_Script'] = df['Script'].str.extract(r'(.*?)(?:_(insert|select))')[0]
insert_rows = df[df['Script'].str.endswith('_insert')].assign(WriteOnly=lambda x: x['QPS'])
select_rows = df[df['Script'].str.contains('_select')]

combined = []

# Multiple selects
for base_script in insert_rows['Base_Script'].unique():
    insert_data = insert_rows[insert_rows['Base_Script'] == base_script]
    matching_selects = select_rows[select_rows['Base_Script'] == base_script]

    for select_script in matching_selects['Script'].unique():
        select_data = matching_selects[matching_selects['Script'] == select_script]
        merged = pd.merge(insert_data, select_data, on=['Base_Script', 'Time (s)'], suffixes=('_insert', '_select'))

        if not merged.empty:
            metrics = ['TPS', 'QPS', 'Reads', 'Writes', 'Other', 'Latency (ms;95%)', 'ErrPs', 'ReconnPs']
            merged = merged.assign(
                **{m: merged[f'{m}_insert'] + merged[f'{m}_select'] for m in metrics}
            )

        # 1) no multiple selects and no multiple lens => ex.: int_queries_select => int_queries
        # 2) multiple selects but no multiple lens => ex.: query_differences_select_column_prefix => column_prefix
        # 3) multiple lens but no multiple selects => ex.: with_index_500_select => with_index_500
        # 4) multiple selects and multiple lens => ex.: null_2_select_default_null_count_null => default_null_count_null_2
        match = re.match(r'^(?:(?:[a-zA-Z]*_)*?(\d+)_select_)?(.*?)(?:_select)?$', select_script)
        if match:
            group1 = match.group(1)
            group2 = match.group(2)

            if group1 is not None:
                script_name = f"{group2}_{group1}"
            else:
                parts = group2.split("_select")
                script_name = parts[-1].lstrip("_") if parts else group2

            merged['Script'] = script_name
            merged = merged.drop(columns=['Base_Script'])
            combined.append(merged)
        else:
            raise ValueError(f"Failed to parse script name from '{select_script}'")
# One select per insert
if combined:
    final_combined_df = pd.concat(combined)
    output_df = final_combined_df.rename(columns={'Threads_insert': 'Threads'})[
        ['Script', 'Time (s)', 'Threads', 'TPS', 'QPS', 'Reads', 'Writes',
         'Other', 'Latency (ms;95%)', 'ErrPs', 'ReconnPs', 'WriteOnly']
    ]
    float_columns = ['TPS', 'QPS', 'Reads', 'Writes', 'Other', 'Latency (ms;95%)', 'ErrPs', 'ReconnPs', 'WriteOnly']
    for col in float_columns:
        output_df[col] = output_df[col].map(lambda x: f"{x:.2f}" if isinstance(x, float) else x)
    output_df.to_csv(args.output_file, index=False)