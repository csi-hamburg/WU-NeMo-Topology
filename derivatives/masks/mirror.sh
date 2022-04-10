#!/bin/bash

## mirror lesion volumes to RIGHT

if [[ $1 == 'mirror' ]]; then

	for f in 269/*.nii.gz; do
		echo $f
		fslmaths $f -roi 0 90 0 216 0 180 0 1 ${f}_LEFT
		V=$(fslstats ${f}_LEFT -V | awk -F ' ' '{print $1}')
		echo $V
		if [[ $V == 0 ]]; then
			fslswapdim $f -x y z mirrored/$f
		else
			cp $f mirrored/$f
		fi
		rm ${f}_LEFT.nii.gz
	done
fi

if [[ $1 == 'sum' ]]; then
	cp zero.nii.gz sum.nii.gz
	for f in mirrored/269/*.nii.gz; do
		fslmaths sum.nii.gz -add $f sum_temp
		mv sum_temp.nii.gz sum.nii.gz
	done
fi
