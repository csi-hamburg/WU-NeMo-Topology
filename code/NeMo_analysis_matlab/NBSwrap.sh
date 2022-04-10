#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR="$DIR/../../.."

OUTDIR="$BASEDIR/derivatives/figures/NBS"
export LC_NUMERIC="en_US.UTF-8"

for suffix in "" vol0 dvol vol0_dvol; do
	matlab -nosplash -nodesktop -nodisplay -r "suffix='$suffix'; wrap"
done