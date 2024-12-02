import pandas as pd
import argparse

# Argument Parser
parser = argparse.ArgumentParser(description="Process sysbench output CSV file")
parser.add_argument('input_file', type=str, help="Path to the input CSV file")
parser.add_argument('output_file', type=str, help="Path to the output CSV file")

args = parser.parse_args()

# Load and preprocess data
df = pd.read_csv(args.input_file)
df['Base_Script'] = df['Script'].str.replace(r'_(insert|select)$', '', regex=True)

insert_rows = df[df['Script'].str.endswith('_insert')].assign(WriteOnly=lambda x: x['QPS'])
select_rows = df[df['Script'].str.endswith('_select')]
combined = pd.merge(
    insert_rows,
    select_rows,
    on=['Base_Script', 'Time (s)'],
    suffixes=('_insert', '_select')
)

# Aggregate metrics
metrics = ['TPS', 'QPS', 'Reads', 'Writes', 'Other', 'Latency (ms;95%)', 'ErrPs', 'ReconnPs']
combined = combined.assign(**{m: combined[f'{m}_insert'] + combined[f'{m}_select'] for m in metrics})

output_df = combined.rename(columns={'Base_Script': 'Script', 'Threads_insert': 'Threads'})[
    ['Script', 'Time (s)', 'Threads', 'TPS', 'QPS', 'Reads', 'Writes',
     'Other', 'Latency (ms;95%)', 'ErrPs', 'ReconnPs', 'WriteOnly']
]

float_columns = ['TPS', 'QPS', 'Reads', 'Writes', 'Other', 'Latency (ms;95%)', 'ErrPs', 'ReconnPs', 'WriteOnly']
output_df[float_columns] = output_df[float_columns].apply(lambda x: x.map(lambda y: f"{y:.2f}" if isinstance(y, float) else y))

output_df.to_csv(args.output_file, index=False)