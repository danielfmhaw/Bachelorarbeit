import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import argparse
import sys

def parse_arguments():
    parser = argparse.ArgumentParser(description='Generate plots from CSV data.')
    parser.add_argument('runtime_file', type=str, help='Path to the input CSV data file for runtime data')
    parser.add_argument('statistic_file', type=str, nargs='?', default=None, help='Path to the input CSV data file for statistics (optional)')
    parser.add_argument('metrics', type=str, nargs='*', help='List of metrics to plot (e.g., QPS Reads Writes). If empty, all metrics will be used.')
    return parser.parse_args()

def _get_label(scripts_size, names_list):
    if len(names_list) == scripts_size:
        cleaned_script_names = {
            script.split("_db_")[0] if "_db_" in script else
            script.split("_comb_")[0] if "_comb_" in script else
            script.split("_select")[0]
            for script in names_list
        }
        if cleaned_script_names:
            cleaned_names_list = list(cleaned_script_names)
            label = ", ".join(cleaned_names_list[:-1]) + " and " + cleaned_names_list[-1] if len(cleaned_names_list) > 1 else cleaned_names_list[0]
        else:
            label = ""
    elif len(names_list) > 1:
        label = set()
        for script in names_list:
            if "_db_" in script:
                _, script_name = script.split("_db_")
            elif "_comb_" in script:
                _, script_name = script.split("_comb_")
            else:
                script_name = script

            script_name = script_name.replace("_comb_", "_")
            cleaned_name = script_name.split("_select")[0]
            label.add(cleaned_name)
    else:
        label = _get_individual_label(names_list)
    return label

# Label from script-examples
# 1. int_queries_select => int_queries
# 2. varchar_queries_comb_length_1_select => varchar_queries_length_1
# 3. query_differences_select_column_prefix => column_prefix
# 4. mat_view_comb_length_1000_refresh_every_select_query_table_mat => query_table_mat_length_1000_refresh_every
def _get_individual_label(scripts_list):
    script_name = scripts_list[0]
    dir_name = ""
    with_comb = "_comb_" in script_name
    with_db = "_db_" in script_name

    if with_db:
        dir_name, script_name = script_name.split("_db_")
        script_name = script_name.replace("_comb_", "_")
    elif with_comb:
        dir_name, script_name = script_name.split("_comb_")

    if len(scripts_list) == 1:
        if "_select_" in script_name:
            group1, group2 = script_name.split("_select_")
            return f"{group1}_{group2}" if with_db else f"{group2}_{group1}" if with_comb else f"{group2}"
        elif "_select" in script_name:
            base_name = script_name.split("_select")[0]
            return f"{base_name}_{dir_name}" if with_db and dir_name else f"{dir_name}_{base_name}" if dir_name else base_name
        return script_name

    base_name = script_name.split('_select_')[0]
    return f"{dir_name}_{base_name}" if dir_name else base_name

def plot_metrics(args, datafile, detailed_pngs_dir, combined_pngs_dir):
    data = pd.read_csv(datafile)
    scripts = data['Script'].unique()
    scripts_size = len(scripts)

    # Determine metrics to plot
    if args.metrics:
        measures = args.metrics
    else:
        # Use all columns except 'Time (s)' and 'Script' as metrics
        measures = [col for col in data.columns if col not in ['Time (s)', 'Script']]

    try:
        for measure in measures:
            # Detailed plots for each measure
            plt.figure(figsize=(10, 6))
            script_data_dict = {}
            for script in scripts:
                script_data = data[data['Script'] == script]
                script_data_values = script_data[[measure]].apply(lambda row: ','.join(row.astype(str)), axis=1).str.cat(sep=',')
                if script_data_values in script_data_dict:
                    if script not in script_data_dict[script_data_values]:
                        script_data_dict[script_data_values].append(script)
                else:
                    script_data_dict[script_data_values] = [script]

            for script_data, scripts_list in script_data_dict.items():
                script_data_all = data[data['Script'] == scripts_list[0]]
                label = _get_label(scripts_size, scripts_list)
                if isinstance(label, set):
                    for name in label:
                        plt.plot(script_data_all['Time (s)'], script_data_all[measure], label=name)
                else:
                    plt.plot(script_data_all['Time (s)'], script_data_all[measure], label=label)

            plt.title(f'{measure} over Time by Script')
            plt.xlabel('Time (s)')
            plt.ylabel(measure)
            plt.legend(title="Script")
            plt.grid(True)

            detailed_output_file_path = os.path.join(detailed_pngs_dir, f"{measure}.png")
            plt.savefig(detailed_output_file_path, bbox_inches='tight')
            plt.close()

        # Combined plots for each script
        for script in scripts:
            plt.figure(figsize=(10, 6))
            script_name = _get_individual_label([script])
            script_data = data[data['Script'] == script]
            for measure in measures:
                plt.plot(script_data['Time (s)'], script_data[measure], label=measure)

            plt.title(f'All metrics for {script_name}' if script_name else 'Metrics over Time')
            plt.xlabel('Time (s)')
            plt.ylabel('Values')
            plt.legend(title="Measure")
            plt.grid(True)

            script_path = script_name if script_name else "All_Scripts"
            combined_output_file_path = os.path.join(combined_pngs_dir, f"{script_path}.png")
            plt.savefig(combined_output_file_path, bbox_inches='tight')
            plt.close()

    except Exception as e:
        print(f"Error during plot generation: {e}")
        sys.exit(1)

def plot_radar_chart(radar_datafile, output_dir):
    radar_data = pd.read_csv(radar_datafile)

    columns_of_interest = ['Read (noq)', 'Write (noq)', 'Transactions (per s.)', 'Queries (per s.)', 'Total Events', 'Latency Avg (ms)']
    radar_data_of_interest = radar_data[['Script'] + columns_of_interest]

    max_values = {col: radar_data_of_interest[col].max() for col in columns_of_interest}
    radar_data_percentages = radar_data_of_interest.copy()

    for col in columns_of_interest:
        radar_data_percentages[col] = (radar_data_of_interest[col] / max_values[col]) * 100

    metrics = columns_of_interest
    num_metrics = len(metrics)

    angles = np.linspace(0, 2 * np.pi, num_metrics, endpoint=False).tolist()
    angles += angles[:1]

    fig, ax = plt.subplots(figsize=(8, 8), subplot_kw=dict(polar=True))

    for _, row in radar_data_percentages.iterrows():
        script_name = _get_individual_label([row['Script']])
        sample = row[columns_of_interest].values
        sample = np.append(sample, sample[0])

        ax.plot(angles, sample, label={script_name})
        ax.fill(angles, sample, alpha=0.25)

    ax.set_yticks([20, 40, 60, 80, 100])
    ax.set_yticklabels(['20', '40', '60', '80', '100'], color="grey", size=10)
    ax.set_xticks(angles[:-1])

    ax.set_xticklabels([
        f"{metric.split(' ')[0]} (max: {max_values[metric]:,.0f} {metric.split('(')[-1]}" if '(' in metric else f"{metric} (max: {max_values[metric]:,.0f})"
        for metric in columns_of_interest
    ], fontsize=12, color="black")


    # Title and legend
    ax.set_title("Comparison of Metrics", fontsize=16, position=(0.5, 1.1), ha='center')
    ax.legend(loc='upper right', bbox_to_anchor=(1.1, 1.1))
    radar_output_file_path = os.path.join(output_dir, 'statistics.png')
    plt.savefig(radar_output_file_path, bbox_inches='tight')
    plt.close()


def main():
    args = parse_arguments()
    runtime = args.runtime_file

    if not os.path.isfile(runtime):
        print(f"Error: The file {runtime} does not exist.")
        sys.exit(1)

    # Process CSV data for time-based metrics
    png_dir = os.path.join(os.path.dirname(runtime), 'pngs')
    detailed_pngs_dir = os.path.join(png_dir, 'metric_comparison')
    combined_pngs_dir = os.path.join(png_dir, 'script_comparison')
    os.makedirs(detailed_pngs_dir, exist_ok=True)
    os.makedirs(combined_pngs_dir, exist_ok=True)

    plot_metrics(args, runtime, detailed_pngs_dir, combined_pngs_dir)

    # Process radar chart metrics (if radarfile is provided)
    statistic = args.statistic_file
    if statistic:
        if not os.path.isfile(statistic):
            print(f"Error: The radar file {statistic} does not exist.")
            sys.exit(1)
        plot_radar_chart(statistic, png_dir)

    print("Plots generated successfully.")
    sys.exit(0)

if __name__ == '__main__':
    main()