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

def plot_metrics(data, measures, output_dir, detailed_pngs_dir):
    has_script_column = 'Script' in data.columns

    if has_script_column:
        scripts = data['Script'].unique()
    else:
        scripts = [None]

    try:
        plt.figure(figsize=(10, 6))

        for measure in measures:
            if has_script_column:
                # Plot each script as a separate line for each measure if 'Script' column exists
                for script in scripts:
                    script_data = data[data['Script'] == script]
                    plt.plot(script_data['Time (s)'], script_data[measure], label=f"{script} - {measure}")
            else:
                # Plot only the measure if no 'Script' column exists
                plt.plot(data['Time (s)'], data[measure], label=measure)

        plt.title('Metrics over Time' + (' by Script' if has_script_column else ''))
        plt.xlabel('Time (s)')
        plt.ylabel('Values')
        plt.legend(title="Script and Measure" if has_script_column else "Measure")
        plt.grid(True)

        # Save the combined plot
        output_final_path = os.path.join(output_dir, 'output_final.png')
        plt.savefig(output_final_path)
        plt.close()

        for measure in measures:
            plt.figure(figsize=(10, 6))
            if has_script_column:
                # Plot each script as a separate line for each measure if 'Script' column exists
                for script in scripts:
                    script_data = data[data['Script'] == script]
                    plt.plot(script_data['Time (s)'], script_data[measure], label=f"{script} - {measure}")
            else:
                # Plot only the measure if no 'Script' column exists
                plt.plot(data['Time (s)'], data[measure], label=measure)

            # Plot settings for individual figures
            plt.title(f'{measure} over Time by Script')
            plt.xlabel('Time (s)')
            plt.ylabel(measure)
            plt.legend(title="Script")
            plt.grid(True)

            # Save the detailed plot to a PNG file in the specified output directory
            detailed_output_file_path = os.path.join(detailed_pngs_dir, f"{measure}.png")
            plt.savefig(detailed_output_file_path)
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

    # Define output directory for plots
    output_dir = os.path.dirname(datafile)
    detailed_pngs_dir = os.path.join(output_dir, 'detailed_pngs')

    # Create output directories if they don't exist
    os.makedirs(detailed_pngs_dir, exist_ok=True)
    plot_metrics(data, measures, output_dir, detailed_pngs_dir)

    print("Plots generated successfully.")
    sys.exit(0)

if __name__ == '__main__':
    main()
