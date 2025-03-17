set datafile separator ","
set title "Benchmark Results: TPS, Latency, Queries, and More"
set xlabel "Time (s)"
set ylabel "Values"
set grid
set key outside
set terminal pngcairo enhanced font 'Arial,10'
set output "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Tools/Output/sysbench_output_plot.png"
set yrange [0:*]

# Plot each attribute on its own line
plot "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Tools/Output/sysbench_output.csv" using 1:2 title "Threads" lt 1 lc rgb "black" with lines, \
     "" using 1:3 title "TPS" lt 2 lc rgb "green" with lines, \
     "" using 1:4 title "QPS" lt 3 lc rgb "blue" with lines, \
     "" using 1:5 title "Reads" lt 4 lc rgb "red" with lines, \
     "" using 1:6 title "Writes" lt 5 lc rgb "orange" with lines, \
     "" using 1:7 title "Other" lt 6 lc rgb "purple" with lines, \
     "" using 1:8 title "Latency (ms)" lt 7 lc rgb "cyan" with lines, \
     "" using 1:9 title "Err/s" lt 8 lc rgb "magenta" with lines, \
     "" using 1:10 title "Reconn/s" lt 9 lc rgb "brown" with lines
