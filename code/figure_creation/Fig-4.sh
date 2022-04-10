#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR="$DIR/../.."

OUTDIR="$BASEDIR/derivatives/figures/NBS"
export LC_NUMERIC="en_US.UTF-8"

convert \( $BASEDIR/derivatives/matlab_processing/backbone.png -trim +repage -border 0x0 -resize 66% \) \( $BASEDIR/derivatives/figures/R/TbyEBC_qb.png \) -gravity east +append ${OUTDIR}/Fig-4-AB.png

convert \( ${OUTDIR}/Fig-4-AB.png \)\
       	\( $BASEDIR/derivatives/figures/R/polyfit.png \)\
       	-geometry +15+15 -append\
       	-gravity northwest -fill black -pointsize 80 -annotate +10+10 "A)"\
       	-gravity northwest -fill black -pointsize 80 -annotate +1100+10 "B)"\
       	-gravity northwest -fill black -pointsize 80 -annotate +10+950 "D)"\
	${OUTDIR}/Fig-4-ABD.png


convert ${OUTDIR}/Fig-4-ABD.png\
       	\( $BASEDIR/derivatives/matlab_processing/EBCbyref.png -trim \)\
	+append\
       	-gravity northwest -fill black -pointsize 80 -annotate +2050+10 "C)"\
	${OUTDIR}/Fig-4.png



