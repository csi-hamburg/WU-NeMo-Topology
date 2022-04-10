#!/bin/bash

## correct lesion volumes based on MNI brain template.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR="$DIR/../.."
INDIR="$BASEDIR"/nemo2_test/lesionmasks
OUTDIR="$BASEDIR"/derivatives/
OUTFILE="$OUTDIR"/volumesMNI.dat


for f in $(ls "$INDIR"); do
  fslinfo "$INDIR/$f"
  fslinfo "$BASEDIR/code/image_preprocessing/r1mm_white.nii"
  fslmaths "$INDIR/$f" -mas "$BASEDIR/code/image_preprocessing/r1mm_white.nii" temp.nii.gz
	vol=$(fslstats temp.nii.gz -V | awk '{print $1}')
  echo "${f%%.nii.gz} $vol" >> "$OUTFILE"	
done
