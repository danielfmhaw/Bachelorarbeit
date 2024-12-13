#!/bin/bash

filename="VorlageBA"

lualatex "$filename.tex"
biber "$filename"
lualatex "$filename.tex"
lualatex "$filename.tex"

mv "$filename.pdf" "../VorlageBA_gen.pdf"
rm "$filename".aux "$filename".log "$filename".bcf "$filename".bbl "$filename".blg "$filename".run.xml
rm "$filename".lof "$filename".lot "$filename".out "$filename".toc
rm appendix.aux chap1.aux chap2.aux chap3.aux title.aux toc.aux
echo "Finished"