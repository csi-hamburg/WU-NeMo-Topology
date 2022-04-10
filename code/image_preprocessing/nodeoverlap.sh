#!/bin/bash

# compute overlap of stroke lesions with node masks of the Desikan (86) and AAL (116) atlas

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR="$DIR/../.."
INDIR="$BASEDIR"/lesionmasks/
OUTDIR="$BASEDIR"/derivatives/node_overlap

IFS=$'\n' ## allow spaces in file names

for asz in 86; do
	OUTFILE="$OUTDIR/node${asz}.csv"
	echo "lab,ID,visit,maskvol,overlapvol,quotient" > "$OUTFILE"
	for mask in $(ls $INDIR/node_masks/$asz/*.nii.gz); do
		ROI=$(basename -s .nii.gz "$mask")
		Vmask=$(fslstats "$mask" -V | awk '{print $2}')
		
		for visit in V0 V3; do
			for lesion in $(find "$INDIR/derivatives/$visit/" -name "*.nii"); do
				ID=$(basename "$lesion")
				ID=${ID%%-v*}
				fslmaths "$lesion" -mul "$mask" -bin overlap_temp.nii.gz
				Voverlap=$(fslstats overlap_temp.nii.gz -V | awk '{print $2}')
				quotient=$(awk "BEGIN {print $Voverlap / $Vmask }")
				echo "$ROI,$ID,$visit,$Vmask,$Voverlap,$quotient" >> "$OUTFILE"
			done
		done
	done
done
