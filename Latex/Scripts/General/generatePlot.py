import pandas as pd
import matplotlib.pyplot as plt
import os
import argparse
import sys

def parse_arguments():
    parser = argparse.ArgumentParser(description='Generate plots from CSV data.')
    parser.add_argument('datafile', type=str, help='Path to the input CSV data file')
    parser.add_argument('metrics', type=str, nargs='*', help='List of metrics to plot (e.g., QPS Reads Writes). If empty, all metrics will be used.')
    return parser.parse_args()

def plot_metrics(data, measures, detailed_pngs_dir, combined_pngs_dir):
    scripts = data['Script'].unique()

    try:
        for measure in measures:
            # Detailed plots for each measure
            plt.figure(figsize=(10, 6))
            for script in scripts:
                script_data = data[data['Script'] == script]
                plt.plot(script_data['Time (s)'], script_data[measure], label=f"{script} - {measure}")

            plt.title(f'{measure} over Time by Script')
            plt.xlabel('Time (s)')
            plt.ylabel(measure)
            plt.legend(title="Script")
            plt.grid(True)

            detailed_output_file_path = os.path.join(detailed_pngs_dir, f"{measure}.png")
            plt.savefig(detailed_output_file_path)
            plt.close()

        # Combined plots for each script
        for script in scripts:
            plt.figure(figsize=(10, 6))
            script_data = data[data['Script'] == script]
            for measure in measures:
                plt.plot(script_data['Time (s)'], script_data[measure], label=measure)

            plt.title(f'All metrics for {script}' if script else 'Metrics over Time')
            plt.xlabel('Time (s)')
            plt.ylabel('Values')
            plt.legend(title="Measure")
            plt.grid(True)

            script_name = script if script else "All_Scripts"
            combined_output_file_path = os.path.join(combined_pngs_dir, f"{script_name}.png")
            plt.savefig(combined_output_file_path)
            plt.close()

    except Exception as e:
        print(f"Error during plot generation: {e}")
        sys.exit(1)

def main():
    args = parse_arguments()

    # Load CSV data
    datafile = args.datafile
    if not os.path.isfile(datafile):
        print(f"Error: The file {datafile} does not exist.")
        sys.exit(1)

    data = pd.read_csv(datafile)

    # Determine metrics to plot
    if args.metrics:
        measures = args.metrics
    else:
        # Use all columns except 'Time (s)' and 'Script' as metrics
        measures = [col for col in data.columns if col not in ['Time (s)', 'Script']]

    output_dir = os.path.dirname(datafile)
    detailed_pngs_dir = os.path.join(output_dir, 'pngs/metric_comparison')
    combined_pngs_dir = os.path.join(output_dir, 'pngs/script_comparison')

    os.makedirs(detailed_pngs_dir, exist_ok=True)
    os.makedirs(combined_pngs_dir, exist_ok=True)

    plot_metrics(data, measures, detailed_pngs_dir, combined_pngs_dir)

    print("Plots generated with pandas")
    sys.exit(0)

if __name__ == '__main__':
    main()