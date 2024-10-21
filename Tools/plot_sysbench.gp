set datafile separator ","
set title "TPS, Latency und Queries über Zeit"
set xlabel "Time (s)"
set ylabel "Wert"
set grid
set key outside
set terminal pngcairo enhanced font 'Arial,10'
set output "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Tools/results_plot.png"

set yrange [0:*]  # Y-Achse auf einen automatischen Bereich setzen, der bei 0 beginnt

plot "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Tools/results.csv" using 1:2 title "TPS" lt 7 lc rgb "green" with lines,\
     "" using 1:3 title "Latency (ms)" lt 1 lc rgb "blue" with lines,\
     "" using 1:4 title "Queries" lt 2 lc rgb "red" with lines
