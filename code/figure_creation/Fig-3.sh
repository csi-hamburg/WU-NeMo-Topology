#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR="$DIR/../.."

OUTDIR="$BASEDIR/derivatives/figures/NBS"
export LC_NUMERIC="en_US.UTF-8"

montage \( $BASEDIR/derivatives/figures/R/NBS_p_n_vert.png  -gravity northwest -fill black -pointsize 80 -annotate +10+10 "A)"  \) \( $BASEDIR/derivatives/matlab_processing/NBStstatsmall_vert.png -trim +repage -gravity northwest -fill black -pointsize 80 -annotate +0+0 "B)" \)  \( ${OUTDIR}/Fig-3-C_vol0_dvol.png -resize 50% -gravity northwest -fill black -pointsize 80 -annotate +10+0 "C)" \) -geometry +15+15 -tile 3x1 ${OUTDIR}/Fig-3.png

