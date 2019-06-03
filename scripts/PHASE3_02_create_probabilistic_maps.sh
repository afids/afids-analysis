#!/bin/bash
# create probabilistic and binarized versions of ROIs in MNI152NLin2009cAsym space from average of all PHASE2 subjects after processing through fMRIPrep
# run locally on rete (graham was down) 20180823: ~/graham/projects/fid_study_bids/
# pre-req: fmriprep output

input_dir=~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/derivatives/fmriprep_1.1.1/fmriprep_PHASE3/
output_dir=~/GitHub/afids-analysis/data/PHASE3_output_maps/
mkdir -p $output_dir

AverageImages 3 $output_dir/MNI152NLin2009cAsym_label-thalamus-L-prob_roi_nlin.nii.gz 0 `find $input_dir/ -name '*_T1w_space-MNI152NLin2009cAsym_label-thalamus-L_roi_nlin.nii.gz'`
AverageImages 3 $output_dir/MNI152NLin2009cAsym_label-thalamus-R-prob_roi_nlin.nii.gz 0 `find $input_dir/ -name '*_T1w_space-MNI152NLin2009cAsym_label-thalamus-R_roi_nlin.nii.gz'`
AverageImages 3 $output_dir/MNI152NLin2009cAsym_label-striatum-L-prob_roi_nlin.nii.gz 0 `find $input_dir/ -name '*_T1w_space-MNI152NLin2009cAsym_label-striatum-L_roi_nlin.nii.gz'`
AverageImages 3 $output_dir/MNI152NLin2009cAsym_label-striatum-R-prob_roi_nlin.nii.gz 0 `find $input_dir/ -name '*_T1w_space-MNI152NLin2009cAsym_label-striatum-R_roi_nlin.nii.gz'`
AverageImages 3 $output_dir/MNI152NLin2009cAsym_label-pallidum-L-prob_roi_nlin.nii.gz 0 `find $input_dir/ -name '*_T1w_space-MNI152NLin2009cAsym_label-pallidum-L_roi_nlin.nii.gz'`
AverageImages 3 $output_dir/MNI152NLin2009cAsym_label-pallidum-R-prob_roi_nlin.nii.gz 0 `find $input_dir/ -name '*_T1w_space-MNI152NLin2009cAsym_label-pallidum-R_roi_nlin.nii.gz'`

fslmaths $output_dir/MNI152NLin2009cAsym_label-thalamus-L-prob_roi_nlin.nii.gz -thr 0.5 -bin $output_dir/MNI152NLin2009cAsym_label-thalamus-L_roi_nlin.nii.gz
fslmaths $output_dir/MNI152NLin2009cAsym_label-thalamus-R-prob_roi_nlin.nii.gz -thr 0.5 -bin $output_dir/MNI152NLin2009cAsym_label-thalamus-R_roi_nlin.nii.gz
fslmaths $output_dir/MNI152NLin2009cAsym_label-striatum-L-prob_roi_nlin.nii.gz -thr 0.5 -bin $output_dir/MNI152NLin2009cAsym_label-striatum-L_roi_nlin.nii.gz
fslmaths $output_dir/MNI152NLin2009cAsym_label-striatum-R-prob_roi_nlin.nii.gz -thr 0.5 -bin $output_dir/MNI152NLin2009cAsym_label-striatum-R_roi_nlin.nii.gz
fslmaths $output_dir/MNI152NLin2009cAsym_label-pallidum-L-prob_roi_nlin.nii.gz -thr 0.5 -bin $output_dir/MNI152NLin2009cAsym_label-pallidum-L_roi_nlin.nii.gz
fslmaths $output_dir/MNI152NLin2009cAsym_label-pallidum-R-prob_roi_nlin.nii.gz -thr 0.5 -bin $output_dir/MNI152NLin2009cAsym_label-pallidum-R_roi_nlin.nii.gz
