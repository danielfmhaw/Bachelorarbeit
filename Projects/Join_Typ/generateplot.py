import pandas as pd
import matplotlib.pyplot as plt
import os
import argparse

# Define a function to parse command-line arguments
def parse_arguments():
    parser = argparse.ArgumentParser(description='Generate plots from CSV data.')
    parser.add_argument('datafile', type=str, help='Path to the input CSV data file')
    parser.add_argument('metrics', type=str, nargs='+', help='List of metrics to plot (e.g., QPS Reads Writes)')
    return parser.parse_args()

# Main function to generate plots
def plot_metrics(data, measures, output_dir, detailed_pngs_dir):
    scripts = data['Script'].unique()

    # Create a single figure for all measures
    plt.figure(figsize=(10, 6))

    for measure in measures:
        # Plot each script as a separate line for each measure
        for script in scripts:
            script_data = data[data['Script'] == script]
            plt.plot(script_data['Time (s)'], script_data[measure], label=f"{script} - {measure}")

    # Plot settings for combined figure
    plt.title('Metrics over Time by Script')
    plt.xlabel('Time (s)')
    plt.ylabel('Values')
    plt.legend(title="Script and Measure")
    plt.grid(True)

    # Save the combined plot
    output_final_path = os.path.join(output_dir, 'output_final.png')
    plt.savefig(output_final_path)
    plt.close()  # Close the figure to free up memory

    # Loop through each measure to create separate subplots
    for measure in measures:
        plt.figure(figsize=(10, 6))

        # Plot each script as a separate line in the same plot
        for script in scripts:
            script_data = data[data['Script'] == script]
            plt.plot(script_data['Time (s)'], script_data[measure], label=script)

        # Plot settings for individual figures
        plt.title(f'{measure} over Time by Script')
        plt.xlabel('Time (s)')
        plt.ylabel(measure)
        plt.legend(title="Script")
        plt.grid(True)

        # Save the detailed plot to a PNG file in the specified output directory
        detailed_output_file_path = os.path.join(detailed_pngs_dir, f"{measure}.png")
        plt.savefig(detailed_output_file_path)
        plt.close()  # Close the figure to free up memory

def main():
    # Parse command-line arguments
    args = parse_arguments()

    # Load CSV data
    datafile = args.datafile
    if not os.path.isfile(datafile):
        raise FileNotFoundError(f"The file {datafile} does not exist.")

    data = pd.read_csv(datafile)

    # Define output directory for plots
    output_dir = os.path.dirname(datafile)
    detailed_pngs_dir = os.path.join(output_dir, 'detailed_pngs')

    # Create output directories if they don't exist
    os.makedirs(detailed_pngs_dir, exist_ok=True)  # Create detailed PNGs directory

    # Call the function with specified measures
    plot_metrics(data, args.metrics, output_dir, detailed_pngs_dir)

if __name__ == '__main__':
    main()