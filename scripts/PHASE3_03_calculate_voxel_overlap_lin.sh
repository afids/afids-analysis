#!/bin/bash
# Compute voxel overlap metrics (lin)
# run locally on rete (graham was down) 20180823: ~/graham/projects/fid_study_bids/
# pre-req: fmriprep output

function usage {
 echo ""
 echo "Compute voxel overlap metrics"
 echo ""
 echo "Required args:"
 echo "  -i input_csv with subject names (e.g. sub-C020)"
 echo ""
}

if [ "$#" -lt 2 ]
then
 usage
 exit 1
fi

while getopts "i:" options; do
 case $options in
     i ) 
         in_csv=$OPTARG;;

    * ) usage
        exit 1;;
 esac
done

input_dir=~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/derivatives/fmriprep_1.1.1/fmriprep_PHASE3/
maps_dir=~/GitHub/afids-analysis/data/PHASE3_output_maps/
output_dir=~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/derivatives/fmriprep_1.1.1/fmriprep_PHASE3_voxel_overlap_lin/

printf "subject,roi,side,intersection,union,id_vol,truth_vol\n"

mkdir -p $output_dir
{
  read
while read SUBJ; do
#  echo "---------"
#  echo $SUBJ
#  echo "---------"

  mkdir -p ${output_dir}/${SUBJ}/anat/

  input_label_MNI152_thalamusL=${input_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-L_roi_lin.nii.gz
  input_label_MNI152_thalamusR=${input_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-R_roi_lin.nii.gz
  input_label_MNI152_striatumL=${input_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-L_roi_lin.nii.gz
  input_label_MNI152_striatumR=${input_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-R_roi_lin.nii.gz
  input_label_MNI152_pallidumL=${input_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-L_roi_lin.nii.gz
  input_label_MNI152_pallidumR=${input_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-R_roi_lin.nii.gz

  output_label_MNI152_thalamusL_intersection=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-L_roi_lin_intersection.nii.gz
  output_label_MNI152_thalamusL_union=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-L_roi_lin_union.nii.gz
  output_label_MNI152_thalamusR_intersection=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-R_roi_lin_intersection.nii.gz
  output_label_MNI152_thalamusR_union=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-R_roi_lin_union.nii.gz
  output_label_MNI152_striatumL_intersection=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-L_roi_lin_intersection.nii.gz
  output_label_MNI152_striatumL_union=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-L_roi_lin_union.nii.gz
  output_label_MNI152_striatumR_intersection=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-R_roi_lin_intersection.nii.gz
  output_label_MNI152_striatumR_union=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-R_roi_lin_union.nii.gz
  output_label_MNI152_pallidumL_intersection=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-L_roi_lin_intersection.nii.gz
  output_label_MNI152_pallidumL_union=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-L_roi_lin_union.nii.gz
  output_label_MNI152_pallidumR_intersection=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-R_roi_lin_intersection.nii.gz
  output_label_MNI152_pallidumR_union=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-R_roi_lin_union.nii.gz

  fslmaths $input_label_MNI152_thalamusL -mul $maps_dir/MNI152NLin2009cAsym_label-thalamus-L_roi_nlin.nii.gz $output_label_MNI152_thalamusL_intersection
  fslmaths $input_label_MNI152_thalamusL -add $maps_dir/MNI152NLin2009cAsym_label-thalamus-L_roi_nlin.nii.gz -bin $output_label_MNI152_thalamusL_union

  curr_intersection=`fslstats $output_label_MNI152_thalamusL_intersection -V | cut -d' ' -f1 | xargs` 
  curr_union=`fslstats $output_label_MNI152_thalamusL_union -V | cut -d' ' -f1 | xargs` 
  curr_vol=`fslstats $input_label_MNI152_thalamusL -V | cut -d' ' -f1 | xargs` 
  curr_truth=`fslstats $maps_dir/MNI152NLin2009cAsym_label-thalamus-L_roi_nlin.nii.gz -V | cut -d' ' -f1 | xargs` 
  printf "$SUBJ,thalamus,left,$curr_intersection,$curr_union,$curr_vol,$curr_truth\n"

  fslmaths $input_label_MNI152_thalamusR -mul $maps_dir/MNI152NLin2009cAsym_label-thalamus-R_roi_nlin.nii.gz $output_label_MNI152_thalamusR_intersection
  fslmaths $input_label_MNI152_thalamusR -add $maps_dir/MNI152NLin2009cAsym_label-thalamus-R_roi_nlin.nii.gz -bin $output_label_MNI152_thalamusR_union

  curr_intersection=`fslstats $output_label_MNI152_thalamusR_intersection -V | cut -d' ' -f1 | xargs` 
  curr_union=`fslstats $output_label_MNI152_thalamusR_union -V | cut -d' ' -f1 | xargs` 
  curr_vol=`fslstats $input_label_MNI152_thalamusR -V | cut -d' ' -f1 | xargs` 
  curr_truth=`fslstats $maps_dir/MNI152NLin2009cAsym_label-thalamus-R_roi_nlin.nii.gz -V | cut -d' ' -f1 | xargs` 
  printf "$SUBJ,thalamus,right,$curr_intersection,$curr_union,$curr_vol,$curr_truth\n"

  fslmaths $input_label_MNI152_striatumL -mul $maps_dir/MNI152NLin2009cAsym_label-striatum-L_roi_nlin.nii.gz $output_label_MNI152_striatumL_intersection
  fslmaths $input_label_MNI152_striatumL -add $maps_dir/MNI152NLin2009cAsym_label-striatum-L_roi_nlin.nii.gz -bin $output_label_MNI152_striatumL_union

  curr_intersection=`fslstats $output_label_MNI152_striatumL_intersection -V | cut -d' ' -f1 | xargs` 
  curr_union=`fslstats $output_label_MNI152_striatumL_union -V | cut -d' ' -f1 | xargs` 
  curr_vol=`fslstats $input_label_MNI152_striatumL -V | cut -d' ' -f1 | xargs` 
  curr_truth=`fslstats $maps_dir/MNI152NLin2009cAsym_label-striatum-L_roi_nlin.nii.gz -V | cut -d' ' -f1 | xargs` 
  printf "$SUBJ,striatum,left,$curr_intersection,$curr_union,$curr_vol,$curr_truth\n"

  fslmaths $input_label_MNI152_striatumR -mul $maps_dir/MNI152NLin2009cAsym_label-striatum-R_roi_nlin.nii.gz $output_label_MNI152_striatumR_intersection
  fslmaths $input_label_MNI152_striatumR -add $maps_dir/MNI152NLin2009cAsym_label-striatum-R_roi_nlin.nii.gz -bin $output_label_MNI152_striatumR_union

  curr_intersection=`fslstats $output_label_MNI152_striatumR_intersection -V | cut -d' ' -f1 | xargs` 
  curr_union=`fslstats $output_label_MNI152_striatumR_union -V | cut -d' ' -f1 | xargs` 
  curr_vol=`fslstats $input_label_MNI152_striatumR -V | cut -d' ' -f1 | xargs` 
  curr_truth=`fslstats $maps_dir/MNI152NLin2009cAsym_label-striatum-R_roi_nlin.nii.gz -V | cut -d' ' -f1 | xargs` 
  printf "$SUBJ,striatum,right,$curr_intersection,$curr_union,$curr_vol,$curr_truth\n"

  fslmaths $input_label_MNI152_pallidumL -mul $maps_dir/MNI152NLin2009cAsym_label-pallidum-L_roi_nlin.nii.gz $output_label_MNI152_pallidumL_intersection
  fslmaths $input_label_MNI152_pallidumL -add $maps_dir/MNI152NLin2009cAsym_label-pallidum-L_roi_nlin.nii.gz -bin $output_label_MNI152_pallidumL_union

  curr_intersection=`fslstats $output_label_MNI152_pallidumL_intersection -V | cut -d' ' -f1 | xargs` 
  curr_union=`fslstats $output_label_MNI152_pallidumL_union -V | cut -d' ' -f1 | xargs` 
  curr_vol=`fslstats $input_label_MNI152_pallidumL -V | cut -d' ' -f1 | xargs` 
  curr_truth=`fslstats $maps_dir/MNI152NLin2009cAsym_label-pallidum-L_roi_nlin.nii.gz -V | cut -d' ' -f1 | xargs` 
  printf "$SUBJ,pallidum,left,$curr_intersection,$curr_union,$curr_vol,$curr_truth\n"

  fslmaths $input_label_MNI152_pallidumR -mul $maps_dir/MNI152NLin2009cAsym_label-pallidum-R_roi_nlin.nii.gz $output_label_MNI152_pallidumR_intersection
  fslmaths $input_label_MNI152_pallidumR -add $maps_dir/MNI152NLin2009cAsym_label-pallidum-R_roi_nlin.nii.gz -bin $output_label_MNI152_pallidumR_union

  curr_intersection=`fslstats $output_label_MNI152_pallidumR_intersection -V | cut -d' ' -f1 | xargs` 
  curr_union=`fslstats $output_label_MNI152_pallidumR_union -V | cut -d' ' -f1 | xargs` 
  curr_vol=`fslstats $input_label_MNI152_pallidumR -V | cut -d' ' -f1 | xargs` 
  curr_truth=`fslstats $maps_dir/MNI152NLin2009cAsym_label-pallidum-R_roi_nlin.nii.gz -V | cut -d' ' -f1 | xargs` 
  printf "$SUBJ,pallidum,right,$curr_intersection,$curr_union,$curr_vol,$curr_truth\n"

done
} < "$in_csv"
