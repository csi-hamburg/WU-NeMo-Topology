#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR="$DIR/../.."

OUTDIR="$BASEDIR/derivatives/figures/NBS"
export LC_NUMERIC="en_US.UTF-8"

tt=(1.0 1.5 2.1)
for suffix in vol0_dvol; do
if true; then
for t in ${tt[@]}; do
	for proj in ax cor sag; do
		echo $t
		echo $proj
		f=$BASEDIR//code/NeMo_analysis_matlab/NBSplot/NBSplot-$(printf "%.06f" $t)_${proj}_${suffix}.png
		echo $f
		filename=$(basename -- "$f")
		extension="${filename##*.}"
		filename="${filename%.*}"
		convert $f -trim +repage ${OUTDIR}/${filename}_trim.${extension}
	done
done
fi
montage ${OUTDIR}/*_${suffix}_trim* -geometry +3+100 ${OUTDIR}/Fig-3-C_${suffix}.png

done