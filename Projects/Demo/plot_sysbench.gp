# Use the current working directory
WORK_DIR = system("pwd")

set datafile separator ","
set title "Benchmark Results: TPS, Latency, Queries, and More"
set xlabel "Time (s)"
set ylabel "Values"
set grid
set key outside
set terminal pngcairo enhanced font 'Arial,10'
set output WORK_DIR . "/output/gnuplot/sysbench_output.png"
set yrange [0:*]

# Plot each attribute on its own line
plot WORK_DIR . "/output/sysbench_output.csv" using 2:3 title "Threads" lt 1 lc rgb "black" with lines, \
     "" using 2:4 title "TPS" lt 2 lc rgb "green" with lines, \
     "" using 2:5 title "QPS" lt 3 lc rgb "blue" with lines, \
     "" using 2:6 title "Reads" lt 4 lc rgb "red" with lines, \
     "" using 2:7 title "Writes" lt 5 lc rgb "orange" with lines, \
     "" using 2:8 title "Other" lt 6 lc rgb "purple" with lines, \
     "" using 2:9 title "Latency (ms)" lt 7 lc rgb "cyan" with lines, \
     "" using 2:10 title "Err/s" lt 8 lc rgb "magenta" with lines, \
     "" using 2:11 title "Reconn/s" lt 9 lc rgb "brown" with lines