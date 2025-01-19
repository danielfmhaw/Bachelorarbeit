OUTPUT_FILE="$OUTPUT_DIR/sysbench_output.csv"

# Gnuplot
GNUPLOT_SCRIPT="YOUR_PATH_TO_PROJECT/plot_sysbench.gp"
gnuplot $GNUPLOT_SCRIPT
echo "Plots generated with gnuplot"

# Python with Library Pandas
PYTHON_SCRIPT="YOUR_PATH_TO_PROJECT/generatePlot.py"
python3 "$PYTHON_SCRIPT" "$OUTPUT_FILE"
echo "Plots generated with pandas"