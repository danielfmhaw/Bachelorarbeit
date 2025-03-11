#!/bin/bash

filename="Bachelorarbeit_Daniel_Freire_Mendes"

rm "$filename".{aux,log,bcf,lof,lot,out,toc,pdf}
rm *.aux

lualatex "$filename.tex"
biber "$filename"
lualatex "$filename.tex"
lualatex "$filename.tex"

output_dir="./Out"
if [ ! -d "$output_dir" ]; then
  mkdir "$output_dir"
fi

mv "$filename.pdf" "$output_dir/"
rm "$filename".{aux,log,bcf,bbl,blg,run.xml,lof,lot,out,toc}
rm *.aux
echo "Finished"