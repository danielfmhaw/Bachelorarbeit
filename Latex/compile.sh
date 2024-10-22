#!/bin/bash

filename="VorlageBA"

lualatex "$filename.tex"
biber "$filename"
lualatex "$filename.tex"
lualatex "$filename.tex"

output_dir="./Out"
if [ ! -d "$output_dir" ]; then
  mkdir "$output_dir"
fi

mv "$filename.pdf" "$output_dir/"
rm "$filename".aux "$filename".log "$filename".bcf "$filename".bbl "$filename".blg "$filename".run.xml
rm "$filename".lof "$filename".lot "$filename".out "$filename".toc
rm appendix.aux benchmarks.aux chap1.aux chap2.aux chap3.aux title.aux toc.aux
echo "Finished"