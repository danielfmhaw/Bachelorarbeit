OUTPUT_FILE="$OUTPUT_DIR/sysbench_output.csv"

# Gnuplot
GNUPLOT_SCRIPT="YOUR_PATH_TO_PROJECT/plot_sysbench.gp"
rm -rf "$OUTPUT_DIR/gnuplot"
mkdir -p "$OUTPUT_DIR/gnuplot"
echo "Generating plot with gnuplot..."
gnuplot $GNUPLOT_SCRIPT
echo "Plots generated with gnuplot"

# Python with Library Pandas
PYTHON_SCRIPT="YOUR_PATH_TO_PROJECT/generatePlot.py"
echo "Generating plots with pandas..."
python3 "$PYTHON_SCRIPT" "$OUTPUT_FILE"
echo "Plots generated with pandas"